require('dotenv').config();
const mysql = require('mysql2/promise');

async function testConnection() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306
  });

  try {
    const [rows] = await connection.execute('SELECT 1 as test');
    console.log(' Database connection successful!', rows);
  } catch (error) {
    console.error(' Database connection failed:', error);
  } finally {
    await connection.end();
  }
}

testConnection();
