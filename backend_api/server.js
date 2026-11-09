const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sql = require('mssql/msnodesqlv8');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Ensure upload folder exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/uploads', express.static(uploadDir));
app.use(express.static(path.join(__dirname, 'public')));

// Storage configuration for Multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `student_${Date.now()}_${Math.round(Math.random() * 1E9)}${ext}`);
  }
});
const upload = multer({ storage: storage });

// SQL Server connection pool
const connStr = 'Driver={ODBC Driver 18 for SQL Server};Server=.\\SQLEXPRESS;Database=KiemTraDB;Trusted_Connection=yes;TrustServerCertificate=yes;';
const pool = new sql.ConnectionPool({
  connectionString: connStr
});

pool.connect().then(() => {
  console.log('✅ Connected to SQL Server (KiemTraDB) successfully!');
}).catch(err => {
  console.error('❌ SQL Server connection error:', err);
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    server: 'SQL Server API - Đại Học Tài Nguyên và Môi Trường TPHCM',
    timestamp: new Date().toISOString()
  });
});

// ========================
// API: SINH VIÊN
// ========================

// 1. Lấy danh sách tất cả sinh viên
app.get('/api/students', async (req, res) => {
  try {
    const result = await pool.request().query('SELECT * FROM SinhVien ORDER BY Id ASC');
    res.json({
      success: true,
      data: result.recordset
    });
  } catch (error) {
    console.error('Error fetching students:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// 2. Thêm hoặc cập nhật sinh viên
app.post('/api/students', async (req, res) => {
  try {
    const { mssv, hoTen, maMonHoc, tenMonHoc, coSo, hinhAnhCucBo, hinhAnhBase64 } = req.body;

    if (!mssv || !hoTen) {
      return res.status(400).json({ success: false, message: 'MSSV và Họ Tên là bắt buộc!' });
    }

    const request = pool.request();
    request.input('mssv', sql.NVarChar(50), mssv);
    request.input('hoTen', sql.NVarChar(200), hoTen);
    request.input('maMonHoc', sql.NVarChar(50), maMonHoc || 'FLUTTER01');
    request.input('tenMonHoc', sql.NVarChar(200), tenMonHoc || 'Lập trình di động Flutter');
    request.input('coSo', sql.NVarChar(100), coSo || 'Nhà Bè');
    request.input('hinhAnhCucBo', sql.NVarChar(sql.MAX), hinhAnhCucBo || '');
    request.input('hinhAnhBase64', sql.NVarChar(sql.MAX), hinhAnhBase64 || '');

    // Kiểm tra xem sinh viên đã tồn tại chưa
    const checkExist = await pool.request()
      .input('mssv', sql.NVarChar(50), mssv)
      .query('SELECT Id FROM SinhVien WHERE MSSV = @mssv');

    let query;
    if (checkExist.recordset.length > 0) {
      // Cập nhật thông tin
      query = `
        UPDATE SinhVien 
        SET HoTen = @hoTen, 
            MaMonHoc = @maMonHoc, 
            TenMonHoc = @tenMonHoc, 
            CoSo = @coSo, 
            HinhAnhCucBo = COALESCE(NULLIF(@hinhAnhCucBo, ''), HinhAnhCucBo),
            HinhAnhBase64 = COALESCE(NULLIF(@hinhAnhBase64, ''), HinhAnhBase64),
            NgayTao = GETDATE()
        WHERE MSSV = @mssv;
        SELECT * FROM SinhVien WHERE MSSV = @mssv;
      `;
    } else {
      // Thêm mới
      query = `
        INSERT INTO SinhVien (MSSV, HoTen, MaMonHoc, TenMonHoc, CoSo, HinhAnhCucBo, HinhAnhBase64)
        VALUES (@mssv, @hoTen, @maMonHoc, @tenMonHoc, @coSo, @hinhAnhCucBo, @hinhAnhBase64);
        SELECT * FROM SinhVien WHERE Id = SCOPE_IDENTITY();
      `;
    }

    const result = await request.query(query);
    res.json({
      success: true,
      message: 'Lưu thông tin sinh viên thành công!',
      data: result.recordset[0]
    });
  } catch (error) {
    console.error('Error saving student:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// 3. Upload ảnh chụp từ camera kèm thông tin sinh viên
app.post('/api/students/upload', upload.single('photo'), async (req, res) => {
  try {
    const { mssv, hoTen, maMonHoc, tenMonHoc, coSo, hinhAnhCucBo } = req.body;
    let photoUrl = '';
    let base64Data = '';

    if (req.file) {
      photoUrl = `/uploads/${req.file.filename}`;
      // Đọc sang Base64 để lưu vào SQL Server
      const fileBuffer = fs.readFileSync(req.file.path);
      base64Data = fileBuffer.toString('base64');
    }

    if (mssv && hoTen) {
      const request = pool.request();
      request.input('mssv', sql.NVarChar(50), mssv);
      request.input('hoTen', sql.NVarChar(200), hoTen);
      request.input('maMonHoc', sql.NVarChar(50), maMonHoc || 'FLUTTER01');
      request.input('tenMonHoc', sql.NVarChar(200), tenMonHoc || 'Lập trình di động Flutter');
      request.input('coSo', sql.NVarChar(100), coSo || 'Nhà Bè');
      request.input('hinhAnhCucBo', sql.NVarChar(sql.MAX), hinhAnhCucBo || photoUrl);
      request.input('hinhAnhBase64', sql.NVarChar(sql.MAX), base64Data);

      const checkExist = await pool.request()
        .input('mssv', sql.NVarChar(50), mssv)
        .query('SELECT Id FROM SinhVien WHERE MSSV = @mssv');

      let query;
      if (checkExist.recordset.length > 0) {
        query = `
          UPDATE SinhVien 
          SET HoTen = @hoTen,
              MaMonHoc = @maMonHoc,
              TenMonHoc = @tenMonHoc,
              CoSo = @coSo,
              HinhAnhCucBo = @hinhAnhCucBo,
              HinhAnhBase64 = @hinhAnhBase64
          WHERE MSSV = @mssv;
        `;
      } else {
        query = `
          INSERT INTO SinhVien (MSSV, HoTen, MaMonHoc, TenMonHoc, CoSo, HinhAnhCucBo, HinhAnhBase64)
          VALUES (@mssv, @hoTen, @maMonHoc, @tenMonHoc, @coSo, @hinhAnhCucBo, @hinhAnhBase64);
        `;
      }
      await request.query(query);
    }

    res.json({
      success: true,
      message: 'Upload ảnh chụp và lưu vào SQL Server thành công!',
      file: req.file ? req.file.filename : null,
      photoUrl: photoUrl
    });
  } catch (error) {
    console.error('Error uploading student photo:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ========================
// API: MÔN HỌC & CƠ SỞ
// ========================

// 4. Lấy danh sách môn học
app.get('/api/subjects', async (req, res) => {
  try {
    const result = await pool.request().query('SELECT * FROM MonHoc ORDER BY Id DESC');
    res.json({
      success: true,
      data: result.recordset
    });
  } catch (error) {
    console.error('Error fetching subjects:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// 5. Thêm hoặc cập nhật thông tin môn học & cơ sở
app.post('/api/subjects', async (req, res) => {
  try {
    const { maMonHoc, tenMonHoc, coSo, noiHoc, gioHoc, viTriLat, viTriLng } = req.body;

    if (!maMonHoc || !tenMonHoc) {
      return res.status(400).json({ success: false, message: 'Mã môn học và Tên môn học không được để trống!' });
    }

    const request = pool.request();
    request.input('maMonHoc', sql.NVarChar(50), maMonHoc);
    request.input('tenMonHoc', sql.NVarChar(200), tenMonHoc);
    request.input('coSo', sql.NVarChar(100), coSo || 'Nhà Bè');
    request.input('noiHoc', sql.NVarChar(255), noiHoc || (coSo === 'Nhà Bè' ? '236B Lê Văn Lương, Phước Kiển, Nhà Bè' : '236 Lê Văn Sỹ, Phường 1, Tân Bình'));
    request.input('gioHoc', sql.NVarChar(50), gioHoc || '07:30');
    request.input('viTriLat', sql.Float, viTriLat || (coSo === 'Nhà Bè' ? 10.71882 : 10.79373));
    request.input('viTriLng', sql.Float, viTriLng || (coSo === 'Nhà Bè' ? 106.70251 : 106.66687));

    const checkExist = await pool.request()
      .input('maMonHoc', sql.NVarChar(50), maMonHoc)
      .query('SELECT Id FROM MonHoc WHERE MaMonHoc = @maMonHoc');

    let query;
    if (checkExist.recordset.length > 0) {
      query = `
        UPDATE MonHoc
        SET TenMonHoc = @tenMonHoc,
            CoSo = @coSo,
            NoiHoc = @noiHoc,
            GioHoc = @gioHoc,
            ViTriLat = @viTriLat,
            ViTriLng = @viTriLng,
            NgayTao = GETDATE()
        WHERE MaMonHoc = @maMonHoc;
        SELECT * FROM MonHoc WHERE MaMonHoc = @maMonHoc;
      `;
    } else {
      query = `
        INSERT INTO MonHoc (MaMonHoc, TenMonHoc, CoSo, NoiHoc, GioHoc, ViTriLat, ViTriLng)
        VALUES (@maMonHoc, @tenMonHoc, @coSo, @noiHoc, @gioHoc, @viTriLat, @viTriLng);
        SELECT * FROM MonHoc WHERE Id = SCOPE_IDENTITY();
      `;
    }

    const result = await request.query(query);
    res.json({
      success: true,
      message: 'Lưu môn học và cơ sở vào SQL Server thành công!',
      data: result.recordset[0]
    });
  } catch (error) {
    console.error('Error saving subject:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Khởi chạy server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 REST API Server đang chạy tại: http://localhost:${PORT}`);
  console.log(`📱 Android Emulator truy cập qua: http://10.0.2.2:${PORT}`);
});
