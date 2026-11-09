import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student.dart';

class PdfService {
  /// Tạo tài liệu PDF danh sách sinh viên chuẩn Đại Học Tài Nguyên và Môi Trường TPHCM
  static Future<Uint8List> generateStudentListPdf(
    List<Student> students, {
    String subjectName = 'Lập trình di động Flutter',
    String subjectCode = 'FLUTTER01',
    String campus = 'Nhà Bè',
  }) async {
    final pdf = pw.Document();

    // Tải font hỗ trợ tiếng Việt chuẩn
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currentDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'BỘ TÀI NGUYÊN VÀ MÔI TRƯỜNG',
                      style: pw.TextStyle(fontSize: 10, font: fontRegular),
                    ),
                    pw.Text(
                      'ĐẠI HỌC TÀI NGUYÊN VÀ MÔI TRƯỜNG TP.HCM',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        font: fontBold,
                      ),
                    ),
                    pw.Text(
                      'KHOA CÔNG NGHỆ THÔNG TIN',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        font: fontBold,
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 2),
                      width: 140,
                      height: 1,
                      color: PdfColors.black,
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        font: fontBold,
                      ),
                    ),
                    pw.Text(
                      'Độc lập - Tự do - Hạnh phúc',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                        font: fontItalic,
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 2),
                      width: 120,
                      height: 1,
                      color: PdfColors.black,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'DANH SÁCH SINH VIÊN KIỂM TRA GIỮA KỲ',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: fontBold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Học phần: $subjectName (Mã môn: $subjectCode)',
                    style: pw.TextStyle(fontSize: 12, font: fontRegular),
                  ),
                  pw.Text(
                    'Cơ sở học: $campus | Thời gian xuất: $currentDate',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      font: fontItalic,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'STT',
              'MSSV',
              'Họ và Tên',
              'Mã Môn',
              'Tên Môn Học',
              'Cơ Sở',
              'Ghi Chú',
            ],
            data: List.generate(students.length, (index) {
              final student = students[index];
              return [
                '${index + 1}',
                student.mssv,
                student.hoTen,
                student.maMonHoc,
                student.tenMonHoc,
                student.coSo,
                student.hinhAnhCucBo != null && student.hinhAnhCucBo!.isNotEmpty
                    ? 'Đã chụp ảnh'
                    : 'Chưa có ảnh',
              ];
            }),
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              font: fontBold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blue800,
            ),
            cellStyle: pw.TextStyle(fontSize: 9, font: fontRegular),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
            },
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Đại diện sinh viên', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('(Ký và ghi rõ họ tên)', style: pw.TextStyle(font: fontItalic, fontSize: 9)),
                  pw.SizedBox(height: 50),
                  pw.Text('Trần Hữu Nhân - Trương Gia Phát', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('TP. Hồ Chí Minh, ngày .... tháng .... năm 2026',
                      style: pw.TextStyle(font: fontItalic, fontSize: 9)),
                  pw.SizedBox(height: 4),
                  pw.Text('Giảng viên phụ trách môn học',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('(Ký và ghi rõ họ tên)', style: pw.TextStyle(font: fontItalic, fontSize: 9)),
                  pw.SizedBox(height: 50),
                  pw.Text('Khoa CNTT - ĐH TN&MT TP.HCM',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Tải file PDF lưu thẳng vào bộ nhớ máy (Thư viện / Thư mục Download của điện thoại)
  static Future<File> downloadPdfToDeviceStorage(List<Student> students) async {
    final pdfBytes = await generateStudentListPdf(students);
    Directory targetDir;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          targetDir = downloadDir;
        } else {
          targetDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        }
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      targetDir = await getApplicationDocumentsDirectory();
    }

    final String fileName = 'DanhSach_SV_DHTNMT_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    // Kích hoạt chia sẻ / xem file PDF
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } catch (_) {}

    return file;
  }

  /// Mở giao diện xem trước PDF và in / chia sẻ
  static Future<void> printOrSharePdf(List<Student> students) async {
    final pdfBytes = await generateStudentListPdf(students);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'DanhSach_SinhVien_DHTNMT_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
