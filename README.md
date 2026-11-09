# BÁO CÁO DỰ ÁN KIỂM TRA GIỮA KỲ FLUTTER - MVC
**Trường:** Đại Học Tài Nguyên và Môi Trường TPHCM  
**Khoa:** Công Nghệ Thông Tin  
**Sinh viên thực hiện:**
- MSSV: **1250080122** - Họ tên: **Trần Hữu Nhân**
- MSSV: **1250080139** - Họ tên: **Trương Gia Phát**

---

## 1. TỔNG QUAN KIẾN TRÚC HỆ THỐNG (MVC DESIGN)

Dự án được thiết kế chuẩn theo mô hình kiến trúc **MVC (Model - View - Controller)** kết hợp tầng **Service**:

```
d:\kiemtra\flutter_application_1\lib\
│
├── models/                     # [MODEL] Quản lý cấu trúc dữ liệu và thực thể
│   ├── student.dart            # Thực thể SinhVien (MSSV, HoTen, MaMon, CoSo, HinhAnhCucBo, HinhAnhBase64)
│   └── subject.dart            # Thực thể MonHoc, CampusLocation (Nhà Bè & Lê Văn Sỹ)
│
├── controllers/                # [CONTROLLER] Xử lý nghiệp vụ (Business Logic) & State Management
│   ├── student_controller.dart # Nghiệp vụ sinh viên, chụp ảnh camera, lưu cục bộ, gọi API, tải PDF
│   ├── subject_controller.dart # Nghiệp vụ chọn cơ sở, lưu thông tin môn học, kích hoạt thông báo giờ học
│   └── map_controller.dart     # Nghiệp vụ định vị GPS, vẽ Marker và Polyline OSRM / OpenStreetMap
│
├── views/                      # [VIEW] Giao diện người dùng theo chuẩn Wireframe đề bài
│   ├── main_navigation_screen.dart # Điều hướng các màn hình
│   ├── info_camera_screen.dart     # MÀN HÌNH 1: ĐH TNMT TP.HCM, thông tin 2 sinh viên & Khung Camera & Nút Nhập SV / Xuất PDF
│   ├── subject_map_screen.dart     # MÀN HÌNH 2: Môn học, Nút chọn Cơ sở, Khung Bản Đồ OSRM & Polyline
│   ├── student_manager_screen.dart # MÀN HÌNH 3: Quản lý CSDL SQL Server & Tải PDF
│   ├── pdf_preview_screen.dart     # Màn hình xem trước bản in và chia sẻ PDF
│   └── widgets/
│       └── campus_map_view.dart    # Widget OpenStreetMap & Tuyến đường OSRM Polyline thực tế
│
└── services/                   # [SERVICE] Tầng hạ tầng kết nối ngoại vi
    ├── api_service.dart            # REST API tự động kết nối SQL Server qua USB adb reverse & Wi-Fi LAN
    ├── osrm_service.dart           # Dịch vụ định tuyến OSRM Polyline thực tế trên đường phố
    ├── local_storage_service.dart  # Lưu ảnh camera vào bộ nhớ máy (path_provider) & Offline Cache
    ├── notification_service.dart   # Thông báo nhắc đến giờ học (flutter_local_notifications)
    └── pdf_service.dart            # Tải trực tiếp file PDF về thư viện máy (Downloads) & xem in ấn
```

---

## 2. CÁC TÍNH NĂNG ĐÃ TRIỂN KHAI THEO YÊU CẦU ĐỀ BÀI

### 1. Màn hình 1 - Thông tin sinh viên & Camera lưu ảnh cục bộ
- Hiển thị đúng chuẩn bố cục yêu cầu:
  - Đại Học Tài Nguyên và Môi Trường TPHCM
  - Khoa CNTT
  - Kiểm tra giữa kì flutter
  - MSSV 1250080122 - Họ tên Trần Hữu Nhân
  - MSSV 1250080139 - Họ tên Trương Gia Phát
- **Khung Camera:**
  - Chạm vào để mở Camera điện thoại (hoặc chọn thư viện).
  - Ảnh sau khi chụp được **lưu trực tiếp vào bộ nhớ cục bộ** (`getApplicationDocumentsDirectory()`) thành file `.jpg`.
  - Hiển thị ảnh chụp ngay lập tức bên trong khung chữ nhật.
  - Tự động mã hóa ảnh sang Base64 và đồng bộ lên Microsoft SQL Server.
- **Nút Nhập DS SV & Xuất PDF DS SV:** Đặt trực tiếp dưới khung camera để thao tác nhanh.

### 2. Màn hình 2 - Môn học & Bản đồ OSRM + Tuyến đường Polyline
- **Mã môn học:** `FLUTTER01`
- **Tên môn học:** `Lập trình di động Flutter`
- **Chọn cơ sở:**
  - `[ Nhà bè ]`: **Toạ độ chuẩn Google Maps:** `10.685645, 106.689331` (Khu dân cư Nhơn Đức, Xã Nhơn Đức, H. Nhà Bè, TP.HCM). Nút đổi màu hồng cam khi active.
  - `[ Lê Văn Sỹ ]`: Toạ độ: `10.79373, 106.66687` (236 Lê Văn Sỹ, Phường 1, Q. Tân Bình).
- **Bản đồ OpenStreetMap & OSRM Polyline:**
  - Bản đồ đường phố sắc nét, không bị lỗi xám (100% không phụ thuộc Google API Key).
  - Marker vị trí cơ sở Nhà Bè & Marker cơ sở Lê Văn Sỹ.
  - Marker vị trí hiện tại của thiết bị (GPS qua `geolocator`).
  - **Tuyến đường Polyline thực tế bằng OSRM API (Open Source Routing Machine):**
    - Gọi API `https://router.project-osrm.org/route/v1/driving/...`
    - Vẽ đường Polyline uốn lượn chính xác theo mạng lưới giao thông đô thị từ vị trí người dùng đến cơ sở được chọn.
    - Hiển thị khoảng cách thực tế (km) và thời gian ước tính (phút).

### 3. Thông báo đến giờ học (Local Notifications)
- Nút **"Báo Giờ Học"**: Phát âm thanh và hiển thị thông báo Notification trên thanh trạng thái điện thoại với nội dung:
  > *"⏰ ĐẾN GIỜ HỌC: Lập trình di động Flutter - Mã môn: FLUTTER01 | Cơ sở: Nhà Bè | Giờ học: 07:30. Hãy vào lớp đúng giờ!"*

### 4. Cơ sở dữ liệu SQL Server + Backend REST API
- CSDL Microsoft SQL Server (`KiemTraDB`) đang chạy trên dịch vụ `MSSQL$SQLEXPRESS`.
- Kịch bản SQL: `d:\kiemtra\database.sql` gồm bảng `SinhVien` và bảng `MonHoc`.
- Backend REST API Node.js Express tại thư mục `d:\kiemtra\backend_api` (cổng 3000):
  - Hỗ trợ kết nối qua USB: Đã cấu hình `adb reverse tcp:3000 tcp:3000`.
  - Hỗ trợ kết nối qua mạng Wi-Fi: IP LAN `http://192.168.40.25:3000`.
  - Hỗ trợ Android Emulator: `http://10.0.2.2:3000`.

### 5. Nhập danh sách sinh viên & Tải file PDF về máy
- Nút **"Nhập DS SV"**: Mở popup nhập nhanh thông tin sinh viên và lưu thẳng vào CSDL.
- Nút **"Xuất PDF DS SV"**: Tạo tài liệu PDF chuẩn thể thức đào tạo trường ĐH TN&MT TP.HCM và **lưu thẳng vào thư mục Download / Thư viện tài liệu của máy** (`/storage/emulated/0/Download/DanhSach_SV_xxx.pdf`).

---

## 3. HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### Bước 1: Chuyển tiếp cổng cho điện thoại cắm USB
Khi điện thoại cắm dây USB vào máy tính:
```powershell
adb reverse tcp:3000 tcp:3000
```
*(Lệnh này giúp điện thoại kết nối thẳng vào cổng 3000 của SQL Server API trên máy tính).*

### Bước 2: Chạy ứng dụng Flutter
```powershell
cd d:\kiemtra\flutter_application_1
flutter run
```
