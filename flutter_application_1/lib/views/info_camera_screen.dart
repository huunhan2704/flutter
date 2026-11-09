import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../models/student.dart';

class InfoCameraScreen extends StatelessWidget {
  final StudentController studentController;

  const InfoCameraScreen({
    super.key,
    required this.studentController,
  });

  void _showAddStudentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final mssvController = TextEditingController();
    final hoTenController = TextEditingController();
    final maMonController = TextEditingController(text: 'FLUTTER01');
    final tenMonController = TextEditingController(text: 'Lập trình di động Flutter');
    String selectedCampus = 'Nhà Bè';

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
                  Text('Nhập Sinh Viên (Database)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          DropdownMenuItem(value: 'Nhà Bè', child: Text('Nhà Bè')),
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
                        maMonHoc: maMonController.text.trim(),
                        tenMonHoc: tenMonController.text.trim(),
                        coSo: selectedCampus,
                        hinhAnhCucBo: studentController.localImagePath,
                      );

                      Navigator.pop(ctx);
                      final ok = await studentController.addNewStudent(newStudent);

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

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chọn phương thức chụp ảnh',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                  title: const Text('Mở Camera trên điện thoại để chụp'),
                  subtitle: const Text('Lưu ảnh cục bộ & gửi lên SQL Server'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final success = await studentController.capturePhotoFromCamera();
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã chụp và lưu ảnh cục bộ: ${studentController.localImagePath}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.purple, size: 28),
                  title: const Text('Chọn ảnh từ thư viện máy'),
                  subtitle: const Text('Dùng khi chạy trên máy ảo hoặc giả lập'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final success = await studentController.pickImageFromGallery();
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã chọn và lưu ảnh cục bộ thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: studentController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TIÊU ĐỀ TRƯỜNG & KHOA (Căn giữa như ảnh thiết kế 1)
                  const Text(
                    'Đại Học Tài Nguyên và Môi Trường TPHCM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Khoa CNTT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // TIÊU ĐỀ KIỂM TRA GIỮA KỲ FLUTTER
                  const Text(
                    'Kiểm tra giữa kì',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // THÔNG TIN SINH VIÊN 1
                  const Text(
                    'MSSV 1250080122',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Họ tên Trần Hữu Nhân',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // THÔNG TIN SINH VIÊN 2
                  const Text(
                    'MSSV 1250080139',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Họ tên Trương Gia Phát',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KHUNG CHỤP ẢNH TỪ CAMERA ĐIỆN THOẠI (Hình 1)
                  Center(
                    child: InkWell(
                      onTap: () => _showCameraOptions(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: studentController.capturedImage != null &&
                                studentController.capturedImage!.existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(1),
                                child: Image.file(
                                  studentController.capturedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 46,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(height: 10),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Ảnh chụp từ camera\n(điện thoại)\nChạm để chụp và hiển thị',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // HAI NÚT BẤM THEO YÊU CẦU: NHẬP DS SV & XUẤT PDF DS SV HIỆN TẠI
                  Row(
                    children: [
                      // Nút 1: Nhập DS SV (Database)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddStudentDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text(
                            'Nhập DS SV',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Nút 2: Xuất PDF danh sách SV hiện tại (Tải về thư viện máy)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => studentController.downloadPdfToDevice(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text(
                            'Xuất PDF DS SV',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
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
