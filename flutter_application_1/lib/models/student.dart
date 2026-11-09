/// Model Sinh Viên
class Student {
  final int? id;
  final String mssv;
  final String hoTen;
  final String maMonHoc;
  final String tenMonHoc;
  final String coSo;
  final String? hinhAnhCucBo; // Đường dẫn file ảnh lưu cục bộ trên máy
  final String? hinhAnhBase64; // Chuỗi base64 lưu vào database SQL Server
  final DateTime? ngayTao;

  Student({
    this.id,
    required this.mssv,
    required this.hoTen,
    this.maMonHoc = 'FLUTTER01',
    this.tenMonHoc = 'Lập trình di động Flutter',
    this.coSo = 'Nhà Bè',
    this.hinhAnhCucBo,
    this.hinhAnhBase64,
    this.ngayTao,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['Id'] != null ? int.tryParse(json['Id'].toString()) : null,
      mssv: json['MSSV'] ?? json['mssv'] ?? '',
      hoTen: json['HoTen'] ?? json['hoTen'] ?? '',
      maMonHoc: json['MaMonHoc'] ?? json['maMonHoc'] ?? 'FLUTTER01',
      tenMonHoc: json['TenMonHoc'] ?? json['tenMonHoc'] ?? 'Lập trình di động Flutter',
      coSo: json['CoSo'] ?? json['coSo'] ?? 'Nhà Bè',
      hinhAnhCucBo: json['HinhAnhCucBo'] ?? json['hinhAnhCucBo'],
      hinhAnhBase64: json['HinhAnhBase64'] ?? json['hinhAnhBase64'],
      ngayTao: json['NgayTao'] != null
          ? DateTime.tryParse(json['NgayTao'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mssv': mssv,
      'hoTen': hoTen,
      'maMonHoc': maMonHoc,
      'tenMonHoc': tenMonHoc,
      'coSo': coSo,
      'hinhAnhCucBo': hinhAnhCucBo ?? '',
      'hinhAnhBase64': hinhAnhBase64 ?? '',
      'ngayTao': ngayTao?.toIso8601String(),
    };
  }

  Student copyWith({
    int? id,
    String? mssv,
    String? hoTen,
    String? maMonHoc,
    String? tenMonHoc,
    String? coSo,
    String? hinhAnhCucBo,
    String? hinhAnhBase64,
    DateTime? ngayTao,
  }) {
    return Student(
      id: id ?? this.id,
      mssv: mssv ?? this.mssv,
      hoTen: hoTen ?? this.hoTen,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      coSo: coSo ?? this.coSo,
      hinhAnhCucBo: hinhAnhCucBo ?? this.hinhAnhCucBo,
      hinhAnhBase64: hinhAnhBase64 ?? this.hinhAnhBase64,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }
}
