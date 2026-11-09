-- ==========================================================
-- SCRIPT TẠO CƠ SỞ DỮ LIỆU VÀ CÁC BẢNG: KIỂM TRA FLUTTER
-- Trường: Đại Học Tài Nguyên và Môi Trường TPHCM - Khoa CNTT
-- ==========================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'KiemTraDB')
BEGIN
    CREATE DATABASE KiemTraDB;
    PRINT N'Đã tạo cơ sở dữ liệu KiemTraDB thành công!';
END
GO

USE KiemTraDB;
GO

-- 1. BẢNG SINH VIÊN
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SinhVien' AND xtype='U')
BEGIN
    CREATE TABLE SinhVien (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MSSV NVARCHAR(50) NOT NULL UNIQUE,
        HoTen NVARCHAR(200) NOT NULL,
        MaMonHoc NVARCHAR(50) NULL,
        TenMonHoc NVARCHAR(200) NULL,
        CoSo NVARCHAR(100) NULL,
        HinhAnhCucBo NVARCHAR(MAX) NULL,    -- Đường dẫn lưu ảnh cục bộ trên thiết bị
        HinhAnhBase64 NVARCHAR(MAX) NULL,   -- Dữ liệu ảnh dạng Base64 lưu trực tiếp DB
        NgayTao DATETIME DEFAULT GETDATE()
    );
    PRINT N'Đã tạo bảng SinhVien thành công!';
END
GO

-- 2. BẢNG MÔN HỌC & ĐỊA ĐIỂM HỌC
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='MonHoc' AND xtype='U')
BEGIN
    CREATE TABLE MonHoc (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MaMonHoc NVARCHAR(50) NOT NULL UNIQUE,
        TenMonHoc NVARCHAR(200) NOT NULL,
        CoSo NVARCHAR(100) NOT NULL,        -- 'Nhà Bè' hoặc 'Lê Văn Sỹ'
        NoiHoc NVARCHAR(255) NULL,          -- Địa chỉ chi tiết
        GioHoc NVARCHAR(50) NULL,           -- Ví dụ: '07:30'
        ViTriLat FLOAT NULL,                -- Vĩ độ toạ độ Google Maps
        ViTriLng FLOAT NULL,                -- Kinh độ toạ độ Google Maps
        NgayTao DATETIME DEFAULT GETDATE()
    );
    PRINT N'Đã tạo bảng MonHoc thành công!';
END
GO

-- 3. CHÈN DỮ LIỆU BAN ĐẦU THEO ĐỀ BÀI
IF NOT EXISTS (SELECT * FROM SinhVien WHERE MSSV = '1250080122')
BEGIN
    INSERT INTO SinhVien (MSSV, HoTen, MaMonHoc, TenMonHoc, CoSo)
    VALUES ('1250080122', N'Trần Hữu Nhân', 'FLUTTER01', N'Lập trình di động Flutter', N'Nhà Bè');
END

IF NOT EXISTS (SELECT * FROM SinhVien WHERE MSSV = '1250080139')
BEGIN
    INSERT INTO SinhVien (MSSV, HoTen, MaMonHoc, TenMonHoc, CoSo)
    VALUES ('1250080139', N'Trương Gia Phát', 'FLUTTER01', N'Lập trình di động Flutter', N'Nhà Bè');
END

IF NOT EXISTS (SELECT * FROM MonHoc WHERE MaMonHoc = 'FLUTTER01')
BEGIN
    INSERT INTO MonHoc (MaMonHoc, TenMonHoc, CoSo, NoiHoc, GioHoc, ViTriLat, ViTriLng)
    VALUES ('FLUTTER01', N'Lập trình di động Flutter', N'Nhà Bè', N'236B Lê Văn Lương, Phước Kiển, Nhà Bè', '07:30', 10.71882, 106.70251);
END
GO

SELECT * FROM SinhVien;
SELECT * FROM MonHoc;
GO
