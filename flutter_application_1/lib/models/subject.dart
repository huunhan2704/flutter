/// Model Môn Học & Nơi Học
class Subject {
  final int? id;
  final String maMonHoc;
  final String tenMonHoc;
  final String coSo; // 'Nhà bè' hoặc 'Lê Văn Sỹ'
  final String noiHoc; // Địa chỉ chi tiết
  final String gioHoc; // Giờ học, ví dụ '07:30'
  final double viTriLat; // Vĩ độ
  final double viTriLng; // Kinh độ

  Subject({
    this.id,
    required this.maMonHoc,
    required this.tenMonHoc,
    this.coSo = 'Nhà bè',
    this.noiHoc = 'MMHR+5Q7 Cơ sở Nhà Bè, Hiệp Phước, Hồ Chí Minh',
    this.gioHoc = '07:30',
    this.viTriLat = 10.677877,
    this.viTriLng = 106.691877,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['Id'] != null ? int.tryParse(json['Id'].toString()) : null,
      maMonHoc: json['MaMonHoc'] ?? json['maMonHoc'] ?? '',
      tenMonHoc: json['TenMonHoc'] ?? json['tenMonHoc'] ?? '',
      coSo: json['CoSo'] ?? json['coSo'] ?? 'Nhà bè',
      noiHoc: json['NoiHoc'] ?? json['noiHoc'] ?? '',
      gioHoc: json['GioHoc'] ?? json['gioHoc'] ?? '07:30',
      viTriLat: (json['ViTriLat'] ?? json['viTriLat'] ?? 10.677877).toDouble(),
      viTriLng: (json['ViTriLng'] ?? json['viTriLng'] ?? 106.691877).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'maMonHoc': maMonHoc,
      'tenMonHoc': tenMonHoc,
      'coSo': coSo,
      'noiHoc': noiHoc,
      'gioHoc': gioHoc,
      'viTriLat': viTriLat,
      'viTriLng': viTriLng,
    };
  }
}

/// Dữ liệu toạ độ chuẩn 2 cơ sở Trường ĐH Tài Nguyên và Môi Trường TPHCM
class CampusLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const CampusLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  // 1. Cơ sở Nhà Bè (Plus Code: MMHR+5Q7, Hiệp Phước / Nhơn Đức, Nhà Bè, TP.HCM)
  static const CampusLocation nhaBe = CampusLocation(
    name: 'Nhà bè',
    address: 'MMHR+5Q7 Trường ĐH Tài nguyên & Môi trường TP.HCM - Cơ sở Nhà Bè, Hiệp Phước, TP.HCM',
    latitude: 10.677877,
    longitude: 106.691877,
  );

  // 2. Cơ sở Lê Văn Sỹ (236B Lê Văn Sỹ, Phường Tân Sơn Hòa / Phường 1, TP. Hồ Chí Minh)
  static const CampusLocation leVanSy = CampusLocation(
    name: 'Lê Văn Sỹ',
    address: '236B Lê Văn Sỹ (Phường Tân Sơn Hòa / P.1), TP. Hồ Chí Minh',
    latitude: 10.79373,
    longitude: 106.66687,
  );
}
