const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

pool.getConnection()
  .then(conn => {
    console.log('Database MySQL terhubung...');
    conn.release();
  })
  .catch(err => {
    console.error('Koneksi Database Gagal: ', err.message);
  });

module.exports = pool;