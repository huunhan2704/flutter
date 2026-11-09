import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo hệ thống thông báo cục bộ
  await NotificationService().init();

  runApp(const KiemTraFlutterApp());
}

class KiemTraFlutterApp extends StatelessWidget {
  const KiemTraFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiểm Tra Flutter - Đại Học Tài Nguyên và Môi Trường TPHCM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}
