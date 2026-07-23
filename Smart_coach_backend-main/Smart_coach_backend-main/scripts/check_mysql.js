const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkMySQL() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.MYSQLHOST || '103.227.176.27',
      user: process.env.MYSQLUSER || 'smartcoachadmin',
      password: process.env.MYSQL_ROOT_PASSWORD || 'miDf5k8P8Y5',
      database: process.env.MYSQLDATABASE || 'railway',
      port: parseInt(process.env.MYSQLPORT) || 3306,
    });
    console.log('✅ Connected to MySQL!');
    const [tables] = await connection.query('SHOW TABLES');
    console.log('Tables:', tables);
    connection.end();
  } catch (error) {
    console.error('MySQL connection error:', error.message);
  }
}

checkMySQL();
