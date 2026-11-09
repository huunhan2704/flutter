import 'package:flutter/material.dart';
import '../controllers/map_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/subject_controller.dart';
import '../models/student.dart';
import 'widgets/campus_map_view.dart';

class SubjectMapScreen extends StatelessWidget {
  final SubjectController subjectController;
  final MapLocationController mapController;
  final StudentController? studentController;

  const SubjectMapScreen({
    super.key,
    required this.subjectController,
    required this.mapController,
    this.studentController,
  });

  void _showAddStudentDialog(BuildContext context) {
    if (studentController == null) return;
    final formKey = GlobalKey<FormState>();
    final mssvController = TextEditingController();
    final hoTenController = TextEditingController();
    String selectedCampus = subjectController.selectedCampus;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Row(
                children: [
                  Icon(Icons.person_add_alt_1, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhập Sinh Viên (Database)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: mssvController,
                        decoration: const InputDecoration(
                          labelText: 'MSSV',
                          hintText: 'Nhập mã số SV',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập MSSV' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: hoTenController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập họ tên sinh viên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCampus,
                        decoration: const InputDecoration(
                          labelText: 'Cơ sở',
                          prefixIcon: Icon(Icons.apartment),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Nhà bè', child: Text('Nhà bè')),
                          DropdownMenuItem(value: 'Lê Văn Sỹ', child: Text('Lê Văn Sỹ')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCampus = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newStudent = Student(
                        mssv: mssvController.text.trim(),
                        hoTen: hoTenController.text.trim(),
                        maMonHoc: subjectController.maMonController.text.trim(),
                        tenMonHoc: subjectController.tenMonController.text.trim(),
                        coSo: selectedCampus,
                      );

                      Navigator.pop(ctx);
                      final ok = await studentController!.addNewStudent(newStudent);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                ? '✅ Đã lưu sinh viên vào Database SQL Server!'
                                : 'Đã lưu cục bộ (SQL Server offline)!',
                            ),
                            backgroundColor: ok ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu Database'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([subjectController, mapController]),
      builder: (context, _) {
        final isNhaBe = subjectController.selectedCampus == 'Nhà bè';
        final isLeVanSy = subjectController.selectedCampus == 'Lê Văn Sỹ';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TIÊU ĐỀ: Môn học (Căn giữa như ảnh 2)
                  const Text(
                    'Môn học',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DÒNG 1: mã môn học   [ nhập mã môn ]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 105,
                        child: Text(
                          'mã môn học',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black87, width: 1.2),
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: subjectController.maMonController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'nhập mã môn',
                              hintStyle: TextStyle(color: Colors.black45, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // DÒNG 2: Tên môn học   [ nhập tên môn ]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 105,
                        child: Text(
                          'Tên môn học',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black87, width: 1.2),
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: subjectController.tenMonController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'nhập tên môn',
                              hintStyle: TextStyle(color: Colors.black45, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // DÒNG 3: cơ sở   [ Nhà bè ]   [ Lê Văn Sỹ ]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 105,
                        child: Text(
                          'cơ sở',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Nút: Nhà bè (Active: nền màu đỏ nhạt/hồng cam như hình phác thảo)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            subjectController.setCampus('Nhà bè');
                            mapController.updateMapElements(subjectController.currentCampusLocation);
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: isNhaBe ? const Color(0xFFF3C4B8) : Colors.white,
                              border: Border.all(
                                color: isNhaBe ? const Color(0xFFC75B46) : Colors.black87,
                                width: isNhaBe ? 1.5 : 1.2,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Nhà bè',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isNhaBe ? FontWeight.bold : FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nút: Lê Văn Sỹ
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            subjectController.setCampus('Lê Văn Sỹ');
                            mapController.updateMapElements(subjectController.currentCampusLocation);
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: isLeVanSy ? const Color(0xFFF3C4B8) : Colors.white,
                              border: Border.all(
                                color: isLeVanSy ? const Color(0xFFC75B46) : Colors.black87,
                                width: isLeVanSy ? 1.5 : 1.2,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Lê Văn Sỹ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isLeVanSy ? FontWeight.bold : FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // KHUNG MAP: OpenStreetMap + OSRM Polyline (100% không bị xám/lỗi key)
                  SizedBox(
                    height: 280,
                    child: CampusMapView(
                      mapController: mapController,
                      selectedCampus: subjectController.currentCampusLocation,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CÁC NÚT TÍNH NĂNG CHÍNH: LƯU SQL SERVER & BÁO GIỜ HỌC
                  Row(
                    children: [
                      // Nút lưu vào SQL Server
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: subjectController.isLoading
                              ? null
                              : () async {
                                  final ok = await subjectController.saveSubjectToDatabase();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(subjectController.message),
                                        backgroundColor: ok ? Colors.green : Colors.orange,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: subjectController.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.cloud_upload_outlined, size: 20),
                          label: const Text(
                            'Lưu SQL Server',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Nút thông báo đến giờ học
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await subjectController.sendClassReminderNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🔔 Đã gửi thông báo đến giờ học môn ${subjectController.tenMonController.text}!',
                                  ),
                                  backgroundColor: Colors.deepPurple,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.notifications_active, size: 20),
                          label: const Text(
                            'Báo Giờ Học',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // HAI NÚT THEO YÊU CẦU MỚI: NHẬP DS SV & XUẤT PDF DS SV HIỆN TẠI
                  if (studentController != null)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAddStudentDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green.shade800,
                              side: BorderSide(color: Colors.green.shade700),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Nhập DS SV', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => studentController!.downloadPdfToDevice(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade800,
                              side: BorderSide(color: Colors.red.shade700),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Xuất PDF DS SV', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
