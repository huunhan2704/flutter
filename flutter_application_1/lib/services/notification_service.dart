import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Xin quyền thông báo trên Android 13+
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
      debugPrint('🔔 NotificationService đã khởi tạo thành công.');
    } catch (e) {
      debugPrint('Lỗi khởi tạo NotificationService: $e');
    }
  }

  /// Phát thông báo nhắc giờ học ngay lập tức
  Future<void> showClassReminderNow({
    required String subjectName,
    required String subjectCode,
    required String campus,
    String? classTime,
  }) async {
    await init();
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'class_reminder_channel',
        'Thông Báo Giờ Học',
        channelDescription: 'Nhắc nhở lịch học và địa điểm các môn học',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final String timeStr = classTime ?? '07:30';
      await _notificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: '⏰ ĐẾN GIỜ HỌC: $subjectName',
        body: 'Mã môn: $subjectCode | Cơ sở: $campus | Giờ học: $timeStr. Hãy vào lớp đúng giờ!',
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint('Lỗi gửi thông báo: $e');
    }
  }

  /// Lên lịch thông báo sau một khoảng thời gian giả lập (ví dụ sau 5 giây hoặc đúng giờ)
  Future<void> scheduleClassReminderDemo({
    required String subjectName,
    required String subjectCode,
    required String campus,
    int secondsDelay = 5,
  }) async {
    await init();
    Future.delayed(Duration(seconds: secondsDelay), () {
      showClassReminderNow(
        subjectName: subjectName,
        subjectCode: subjectCode,
        campus: campus,
      );
    });
  }
}
