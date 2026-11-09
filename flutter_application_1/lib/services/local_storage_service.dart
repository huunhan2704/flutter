import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class LocalStorageService {
  static const String _studentsKey = 'cached_students_v1';

  /// Lưu file ảnh chụp từ camera vào bộ nhớ cục bộ của ứng dụng
  static Future<String> saveImageLocally(dynamic imageSourceFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = '${directory.path}/$fileName';

      if (imageSourceFile is File) {
        final savedFile = await imageSourceFile.copy(localPath);
        return savedFile.path;
      } else if (kIsWeb) {
        return 'web_stored_${DateTime.now().millisecondsSinceEpoch}';
      }
      return localPath;
    } catch (e) {
      debugPrint('Lỗi lưu ảnh cục bộ: $e');
      return '';
    }
  }

  /// Chuyển file ảnh sang Base64
  static Future<String?> fileToBase64(File file) async {
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }
    } catch (e) {
      debugPrint('Lỗi mã hóa Base64: $e');
    }
    return null;
  }

  /// Lưu danh sách sinh viên vào Local Storage (SharedPreferences)
  static Future<void> saveStudents(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = students.map((s) => s.toJson()).toList();
    await prefs.setString(_studentsKey, jsonEncode(jsonList));
  }

  /// Đọc danh sách sinh viên từ Local Storage
  static Future<List<Student>> getCachedStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_studentsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((item) => Student.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Lỗi đọc cache sinh viên: $e');
      }
    }

    // Dữ liệu mặc định ban đầu theo đúng đề bài kiểm tra
    return [
      Student(
        mssv: '1250080122',
        hoTen: 'Trần Hữu Nhân',
        maMonHoc: 'FLUTTER01',
        tenMonHoc: 'Lập trình di động Flutter',
        coSo: 'Nhà Bè',
      ),
      Student(
        mssv: '1250080139',
        hoTen: 'Trương Gia Phát',
        maMonHoc: 'FLUTTER01',
        tenMonHoc: 'Lập trình di động Flutter',
        coSo: 'Nhà Bè',
      ),
    ];
  }
}
