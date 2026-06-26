const mysql = require('mysql2/promise');
require('dotenv').config();

// Railway MySQL Connection Pool Setup
const poolConfig = {
  host: String(process.env.MYSQLHOST || '').trim(),
  user: String(process.env.MYSQLUSER || 'root').trim(),
  password: String(process.env.MYSQL_ROOT_PASSWORD || '').trim(),
  database: String(process.env.MYSQLDATABASE || 'railway').trim(),
  port: parseInt(process.env.MYSQLPORT) || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};
const pool = mysql.createPool(poolConfig);

// Function jo server startup par check karega ki DB connected hai ya nahi
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Railway MySQL Connected Successfully');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Database Connection Error:', error.message);
    return false;
  }
};

// IMPORTANT: Dono ko object mein export kar rahe hain taaki index.js { pool, testConnection } use kar sake
module.exports = {
  pool,
  testConnection
};