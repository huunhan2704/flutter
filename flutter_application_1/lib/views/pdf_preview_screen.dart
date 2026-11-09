import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/student.dart';
import '../services/pdf_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  final List<Student> students;

  const PdfPreviewScreen({
    super.key,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xem Trước & Xuất PDF Danh Sách SV',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateStudentListPdf(students),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        pdfFileName: 'DanhSach_SinhVien_DHTNMT_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
  }
}
