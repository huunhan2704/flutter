import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/pdf_service.dart';

class StudentController extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String _statusMessage = '';

  // Ảnh chụp camera hiện tại
  File? _capturedImage;
  String? _localImagePath;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  File? get capturedImage => _capturedImage;
  String? get localImagePath => _localImagePath;

  final ImagePicker _picker = ImagePicker();

  StudentController() {
    initData();
  }

  /// Khởi tạo dữ liệu từ cache và SQL Server
  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Tải cache cục bộ trước để giao diện hiện tức thì
    _students = await LocalStorageService.getCachedStudents();
    _isLoading = false;
    notifyListeners();

    // 2. Đồng bộ với database SQL Server
    await syncFromSqlServer();
  }

  /// Tải danh sách sinh viên từ SQL Server
  Future<void> syncFromSqlServer() async {
    try {
      final serverStudents = await ApiService.fetchStudents();
      if (serverStudents.isNotEmpty) {
        _students = serverStudents;
        await LocalStorageService.saveStudents(_students);
        _statusMessage = 'Đã kết nối SQL Server thành công!';
        notifyListeners();
      }
    } catch (e) {
      _statusMessage = 'Đang sử dụng CSDL cục bộ (Offline).';
      notifyListeners();
    }
  }

  /// Chụp ảnh từ camera điện thoại và lưu vào bộ nhớ máy cục bộ
  Future<bool> capturePhotoFromCamera({String? targetMssv}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final originalFile = File(photo.path);

        // Lưu ảnh vào thư mục cục bộ của ứng dụng (Local documents)
        final localPath = await LocalStorageService.saveImageLocally(originalFile);
        _localImagePath = localPath;
        _capturedImage = File(localPath);

        // Chuyển sang Base64 để lưu vào SQL Server
        final base64String = await LocalStorageService.fileToBase64(_capturedImage!);

        // Cập nhật thông tin sinh viên được gắn ảnh (hoặc cả hai sinh viên mặc định)
        for (int i = 0; i < _students.length; i++) {
          if (targetMssv == null || _students[i].mssv == targetMssv) {
            _students[i] = _students[i].copyWith(
              hinhAnhCucBo: localPath,
              hinhAnhBase64: base64String,
            );
          }
        }

        // Lưu lại cache cục bộ
        await LocalStorageService.saveStudents(_students);
        notifyListeners();

        // Gửi upload lên SQL Server API nếu có kết nối
        try {
          final studentToSync = _students.firstWhere(
            (s) => targetMssv == null ? true : s.mssv == targetMssv,
            orElse: () => _students.first,
          );

          await ApiService.uploadStudentPhoto(
            imageFile: _capturedImage!,
            mssv: studentToSync.mssv,
            hoTen: studentToSync.hoTen,
            maMonHoc: studentToSync.maMonHoc,
            tenMonHoc: studentToSync.tenMonHoc,
            coSo: studentToSync.coSo,
            hinhAnhCucBo: localPath,
          );
        } catch (_) {}

        return true;
      }
    } catch (e) {
      debugPrint('Lỗi chụp ảnh camera: $e');
    }
    return false;
  }

  /// Chọn ảnh từ thư viện thiết bị (dành cho giả lập / test không có camera vật lý)
  Future<bool> pickImageFromGallery({String? targetMssv}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final originalFile = File(photo.path);
        final localPath = await LocalStorageService.saveImageLocally(originalFile);
        _localImagePath = localPath;
        _capturedImage = File(localPath);

        final base64String = await LocalStorageService.fileToBase64(_capturedImage!);

        for (int i = 0; i < _students.length; i++) {
          if (targetMssv == null || _students[i].mssv == targetMssv) {
            _students[i] = _students[i].copyWith(
              hinhAnhCucBo: localPath,
              hinhAnhBase64: base64String,
            );
          }
        }

        await LocalStorageService.saveStudents(_students);
        notifyListeners();

        try {
          final studentToSync = _students.first;
          await ApiService.uploadStudentPhoto(
            imageFile: _capturedImage!,
            mssv: studentToSync.mssv,
            hoTen: studentToSync.hoTen,
            maMonHoc: studentToSync.maMonHoc,
            tenMonHoc: studentToSync.tenMonHoc,
            coSo: studentToSync.coSo,
            hinhAnhCucBo: localPath,
          );
        } catch (_) {}

        return true;
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh thư viện: $e');
    }
    return false;
  }

  /// Thêm sinh viên mới vào CSDL Database
  Future<bool> addNewStudent(Student newStudent) async {
    _isLoading = true;
    notifyListeners();

    // 1. Thêm vào danh sách bộ nhớ & lưu cache cục bộ
    _students.removeWhere((s) => s.mssv == newStudent.mssv);
    _students.add(newStudent);
    await LocalStorageService.saveStudents(_students);

    // 2. Gửi lưu lên SQL Server qua REST API
    final success = await ApiService.saveStudent(newStudent);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Tải file PDF lưu thẳng về thư viện / thư mục máy
  Future<File?> downloadPdfToDevice(BuildContext context) async {
    try {
      final file = await PdfService.downloadPdfToDeviceStorage(_students);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tải file PDF về máy:\n${file.path}'),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Xem / In',
              textColor: Colors.white,
              onPressed: () => exportPdf(),
            ),
          ),
        );
      }
      return file;
    } catch (e) {
      debugPrint('Lỗi tải file PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải file PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
    return null;
  }

  /// Xuất file PDF danh sách sinh viên hiện tại và mở bản in / xem trước
  Future<void> exportPdf() async {
    await PdfService.printOrSharePdf(_students);
  }
}
