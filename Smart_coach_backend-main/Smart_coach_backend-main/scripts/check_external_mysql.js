const mysql = require('mysql2/promise');

(async () => {
  console.log('Connecting to external MySQL at 103.227.176.27:3306...');
  const conn = await mysql.createConnection({
    host: '103.227.176.27',
    port: 3306,
    user: 'smartcoachadmin',
    password: 'miDf5k8P8Y5',
    database: 'railway',
    connectTimeout: 15000
  });
  console.log('Connected!');

  const [dbs] = await conn.query('SHOW DATABASES');
  console.log('Databases:');
  for (const row of dbs) console.log('  ' + Object.values(row)[0]);

  const [tables] = await conn.query('SHOW TABLES');
  console.log('\nTables in railway:');
  for (const row of tables) {
    const name = Object.values(row)[0];
    const [count] = await conn.query('SELECT COUNT(*) as cnt FROM `' + name + '`');
    console.log('  ' + name + ': ' + count[0].cnt + ' rows');
  }

  await conn.end();
})();
