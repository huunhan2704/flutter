import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SubjectController extends ChangeNotifier {
  final TextEditingController maMonController = TextEditingController(text: 'FLUTTER01');
  final TextEditingController tenMonController = TextEditingController(text: 'Lập trình di động Flutter');

  String _selectedCampus = 'Nhà bè'; // 'Nhà bè' hoặc 'Lê Văn Sỹ'
  String _classTime = '07:30';
  bool _isLoading = false;
  String _message = '';

  String get selectedCampus => _selectedCampus;
  String get classTime => _classTime;
  bool get isLoading => _isLoading;
  String get message => _message;

  CampusLocation get currentCampusLocation =>
      _selectedCampus == 'Nhà bè' ? CampusLocation.nhaBe : CampusLocation.leVanSy;

  SubjectController() {
    NotificationService().init();
  }

  /// Chọn cơ sở học (Nhà bè hoặc Lê Văn Sỹ)
  void setCampus(String campus) {
    _selectedCampus = campus;
    notifyListeners();
  }

  void setClassTime(String time) {
    _classTime = time;
    notifyListeners();
  }

  /// Lưu môn học lên SQL Server
  Future<bool> saveSubjectToDatabase() async {
    _isLoading = true;
    _message = 'Đang lưu vào SQL Server...';
    notifyListeners();

    final subject = Subject(
      maMonHoc: maMonController.text.trim(),
      tenMonHoc: tenMonController.text.trim(),
      coSo: _selectedCampus,
      noiHoc: currentCampusLocation.address,
      gioHoc: _classTime,
      viTriLat: currentCampusLocation.latitude,
      viTriLng: currentCampusLocation.longitude,
    );

    final success = await ApiService.saveSubject(subject);
    _isLoading = false;
    _message = success
        ? 'Lưu môn học và cơ sở vào SQL Server thành công!'
        : 'Đã lưu thông tin cục bộ (SQL Server offline).';
    notifyListeners();
    return success;
  }

  /// Gửi thông báo đến giờ học ngay lập tức
  Future<void> sendClassReminderNotification() async {
    await NotificationService().showClassReminderNow(
      subjectName: tenMonController.text.trim().isNotEmpty
          ? tenMonController.text.trim()
          : 'Lập trình di động Flutter',
      subjectCode: maMonController.text.trim().isNotEmpty
          ? maMonController.text.trim()
          : 'FLUTTER01',
      campus: _selectedCampus,
      classTime: _classTime,
    );
  }

  /// Đặt hẹn giờ thông báo sau 5 giây (demo kiểm tra)
  Future<void> scheduleClassReminderDemo({int seconds = 5}) async {
    await NotificationService().scheduleClassReminderDemo(
      subjectName: tenMonController.text.trim(),
      subjectCode: maMonController.text.trim(),
      campus: _selectedCampus,
      secondsDelay: seconds,
    );
  }

  @override
  void dispose() {
    maMonController.dispose();
    tenMonController.dispose();
    super.dispose();
  }
}
