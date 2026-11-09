const sql = require('mssql/msnodesqlv8');

const pool = new sql.ConnectionPool({
  connectionString: 'Driver={ODBC Driver 18 for SQL Server};Server=.\\SQLEXPRESS;Database=KiemTraDB;Trusted_Connection=yes;TrustServerCertificate=yes;'
});

async function run() {
  try {
    await pool.connect();
    console.log('Successfully connected to SQL Server using msnodesqlv8!');
    const result = await pool.request().query('SELECT * FROM SinhVien');
    console.log('Students:', result.recordset);
    process.exit(0);
  } catch (err) {
    console.error('Connection error:', err);
    process.exit(1);
  }
}

run();
