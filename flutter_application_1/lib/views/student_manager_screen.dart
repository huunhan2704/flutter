import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'pdf_preview_screen.dart';

class StudentManagerScreen extends StatefulWidget {
  final StudentController studentController;

  const StudentManagerScreen({
    super.key,
    required this.studentController,
  });

  @override
  State<StudentManagerScreen> createState() => _StudentManagerScreenState();
}

class _StudentManagerScreenState extends State<StudentManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mssvController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _maMonController = TextEditingController(text: 'FLUTTER01');
  final _tenMonController = TextEditingController(text: 'Lập trình di động Flutter');
  String _selectedCampus = 'Nhà Bè';

  @override
  void dispose() {
    _mssvController.dispose();
    _hoTenController.dispose();
    _maMonController.dispose();
    _tenMonController.dispose();
    super.dispose();
  }

  void _showAddStudentDialog() {
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
                  Text('Nhập Sinh Viên Mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _mssvController,
                        decoration: const InputDecoration(
                          labelText: 'MSSV',
                          hintText: 'Nhập mã số SV',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập MSSV' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _hoTenController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập họ tên sinh viên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _maMonController,
                        decoration: const InputDecoration(
                          labelText: 'Mã môn học',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCampus,
                        decoration: const InputDecoration(
                          labelText: 'Cơ sở',
                          prefixIcon: Icon(Icons.apartment),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Nhà Bè', child: Text('Nhà Bè')),
                          DropdownMenuItem(value: 'Lê Văn Sỹ', child: Text('Lê Văn Sỹ')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCampus = val);
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
                    if (_formKey.currentState!.validate()) {
                      final newStudent = Student(
                        mssv: _mssvController.text.trim(),
                        hoTen: _hoTenController.text.trim(),
                        maMonHoc: _maMonController.text.trim(),
                        tenMonHoc: _tenMonController.text.trim(),
                        coSo: _selectedCampus,
                        hinhAnhCucBo: widget.studentController.localImagePath,
                      );

                      Navigator.pop(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await widget.studentController.addNewStudent(newStudent);

                      if (mounted) {
                        messenger.showSnackBar(
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
                      _mssvController.clear();
                      _hoTenController.clear();
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

  void _showApiSettingsDialog() {
    final ipController = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Cấu hình API SQL Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ REST API Server (Node.js kết nối SQL Server):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                hintText: 'http://localhost:3000 hoặc http://10.0.2.2:3000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Android Emulator: http://10.0.2.2:3000\n• Windows App: http://localhost:3000',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.setBaseUrl(ipController.text);
              Navigator.pop(ctx);
              widget.studentController.syncFromSqlServer();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã cập nhật API Base URL: ${ApiService.baseUrl}'),
                ),
              );
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.studentController,
      builder: (context, _) {
        final students = widget.studentController.students;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA),
          appBar: AppBar(
            title: const Text(
              'Cơ Sở Dữ Liệu & Xuất PDF',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Cài đặt IP SQL Server',
                onPressed: _showApiSettingsDialog,
              ),
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: 'Đồng bộ từ CSDL SQL Server',
                onPressed: () => widget.studentController.syncFromSqlServer(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CARD TỔNG QUAN HỆ THỐNG
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đại Học Tài Nguyên & Môi Trường TPHCM',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Khoa Công Nghệ Thông Tin - CSDL SQL Server',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Số lượng sinh viên trong CSDL:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Text(
                                '${students.length} SV',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // NÚT 1: NHẬP DS SINH VIÊN (LƯU DATABASE)
                ElevatedButton.icon(
                  onPressed: _showAddStudentDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.person_add, size: 22),
                  label: const Text(
                    'NHẬP DANH SÁCH SINH VIÊN (DATABASE)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),

                // NÚT 2: TẢI VỀ THƯ VIỆN FILE PDF (XUẤT DS SV HIỆN TẠI)
                ElevatedButton.icon(
                  onPressed: () => widget.studentController.downloadPdfToDevice(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.download_for_offline, size: 24),
                  label: const Text(
                    'TẢI VỀ THƯ VIỆN FILE PDF (XUẤT DS SV HIỆN TẠI)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),

                // NÚT 3: XEM TRƯỚC / IN ẤN PDF (TÙY CHỌN)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => PdfPreviewScreen(
                          students: widget.studentController.students,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.blue.shade800),
                    foregroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.print_outlined, size: 20),
                  label: const Text(
                    'Xem Trước Bản In & Tùy Chọn Chia Sẻ PDF',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 24),

                // GHI CHÚ
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dữ liệu được lưu trữ an toàn trong Microsoft SQL Server (KiemTraDB) và cache máy. Khi cần tải danh sách, hãy bấm nút Tải PDF ở trên để lưu trực tiếp vào thư mục Download của thiết bị.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
