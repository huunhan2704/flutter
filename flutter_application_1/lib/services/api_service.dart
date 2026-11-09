import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/subject.dart';

class ApiService {
  // Danh sách các địa chỉ IP dự phòng (adb reverse localhost, Wi-Fi IP máy tính, Emulator loopback)
  static final List<String> _candidateUrls = [
    'http://localhost:3000',      // Dành cho thiết bị thật cắm USB (qua adb reverse) hoặc Windows/Web
    'http://192.168.40.25:3000',  // IP Wi-Fi nội bộ của máy tính chạy server SQL Server
    'http://10.0.2.2:3000',       // IP loopback của Android Emulator
  ];

  static String _baseUrl = 'http://localhost:3000';
  static bool _hasAutoDiscovered = false;

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    if (!_candidateUrls.contains(_baseUrl)) {
      _candidateUrls.insert(0, _baseUrl);
    }
  }

  /// Tự động dò tìm địa chỉ máy chủ API đang chạy hợp lệ
  static Future<String> getWorkingBaseUrl() async {
    if (_hasAutoDiscovered) return _baseUrl;

    for (final candidate in _candidateUrls) {
      try {
        final uri = Uri.parse('$candidate/api/health');
        final res = await http.get(uri).timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          _baseUrl = candidate;
          _hasAutoDiscovered = true;
          debugPrint('✅ Đã kết nối thành công tới SQL Server API tại: $_baseUrl');
          return _baseUrl;
        }
      } catch (_) {}
    }
    return _baseUrl;
  }

  /// 1. Lấy danh sách sinh viên từ SQL Server
  static Future<List<Student>> fetchStudents() async {
    final activeUrl = await getWorkingBaseUrl();
    try {
      final uri = Uri.parse('$activeUrl/api/students');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((json) => Student.fromJson(json)).toList();
        }
      }
    } catch (e) {
      // Thử lại với các URL dự phòng khác
      for (final candidate in _candidateUrls) {
        if (candidate == activeUrl) continue;
        try {
          final uri = Uri.parse('$candidate/api/students');
          final response = await http.get(uri).timeout(const Duration(seconds: 2));
          if (response.statusCode == 200) {
            _baseUrl = candidate;
            _hasAutoDiscovered = true;
            final data = jsonDecode(utf8.decode(response.bodyBytes));
            if (data['success'] == true && data['data'] != null) {
              final List list = data['data'];
              return list.map((json) => Student.fromJson(json)).toList();
            }
          }
        } catch (_) {}
      }
      debugPrint('⚠️ Không thể kết nối SQL Server API ($e), sử dụng dữ liệu cục bộ.');
    }
    return [];
  }

  /// 2. Lưu thông tin sinh viên + ảnh Base64 lên SQL Server
  static Future<bool> saveStudent(Student student) async {
    await getWorkingBaseUrl();
    for (final candidate in [_baseUrl, ..._candidateUrls]) {
      try {
        final uri = Uri.parse('$candidate/api/students');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'mssv': student.mssv,
                'hoTen': student.hoTen,
                'maMonHoc': student.maMonHoc,
                'tenMonHoc': student.tenMonHoc,
                'coSo': student.coSo,
                'hinhAnhCucBo': student.hinhAnhCucBo ?? '',
                'hinhAnhBase64': student.hinhAnhBase64 ?? '',
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['success'] == true) {
            _baseUrl = candidate;
            return true;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  /// 3. Upload ảnh camera và lưu thông tin vào SQL Server
  static Future<Map<String, dynamic>?> uploadStudentPhoto({
    required File imageFile,
    required String mssv,
    required String hoTen,
    String? maMonHoc,
    String? tenMonHoc,
    String? coSo,
    String? hinhAnhCucBo,
  }) async {
    for (final candidate in [_baseUrl, ..._candidateUrls]) {
      try {
        final uri = Uri.parse('$candidate/api/students/upload');
        final request = http.MultipartRequest('POST', uri);

        request.fields['mssv'] = mssv;
        request.fields['hoTen'] = hoTen;
        request.fields['maMonHoc'] = maMonHoc ?? 'FLUTTER01';
        request.fields['tenMonHoc'] = tenMonHoc ?? 'Lập trình di động Flutter';
        request.fields['coSo'] = coSo ?? 'Nhà Bè';
        request.fields['hinhAnhCucBo'] = hinhAnhCucBo ?? imageFile.path;

        final multipartFile = await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        );
        request.files.add(multipartFile);

        final streamedResponse = await request.send().timeout(const Duration(seconds: 8));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          _baseUrl = candidate;
          return data;
        }
      } catch (_) {}
    }
    return null;
  }

  /// 4. Lưu thông tin môn học & cơ sở vào SQL Server
  static Future<bool> saveSubject(Subject subject) async {
    for (final candidate in [_baseUrl, ..._candidateUrls]) {
      try {
        final uri = Uri.parse('$candidate/api/subjects');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(subject.toJson()),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['success'] == true) {
            _baseUrl = candidate;
            return true;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  /// 5. Lấy danh sách môn học từ SQL Server
  static Future<List<Subject>> fetchSubjects() async {
    for (final candidate in [_baseUrl, ..._candidateUrls]) {
      try {
        final uri = Uri.parse('$candidate/api/subjects');
        final response = await http.get(uri).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['success'] == true && data['data'] != null) {
            _baseUrl = candidate;
            final List list = data['data'];
            return list.map((json) => Subject.fromJson(json)).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }
}
