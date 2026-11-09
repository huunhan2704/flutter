import 'package:flutter/material.dart';
import '../controllers/map_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/subject_controller.dart';
import 'info_camera_screen.dart';
import 'student_manager_screen.dart';
import 'subject_map_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final StudentController _studentController;
  late final SubjectController _subjectController;
  late final MapLocationController _mapController;

  @override
  void initState() {
    super.initState();
    _studentController = StudentController();
    _subjectController = SubjectController();
    _mapController = MapLocationController();
  }

  @override
  void dispose() {
    _studentController.dispose();
    _subjectController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      InfoCameraScreen(studentController: _studentController),
      SubjectMapScreen(
        subjectController: _subjectController,
        mapController: _mapController,
        studentController: _studentController,
      ),
      StudentManagerScreen(studentController: _studentController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle_outlined),
            activeIcon: Icon(Icons.person_pin_circle),
            label: 'Hình 1: Sinh Viên',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Hình 2: Môn Học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: 'Database & PDF',
          ),
        ],
      ),
    );
  }
}
