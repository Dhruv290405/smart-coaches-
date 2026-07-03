const mysql = require('mysql2/promise');

(async () => {
  const conn = await mysql.createConnection({
    host: 'reseau.proxy.rlwy.net',
    port: 20631,
    user: 'root',
    password: 'LrHjeCFbeIhqYZQSWWWQtFRHCGRzObSC',
    database: 'railway',
    connectTimeout: 30000
  });
  console.log('Connected!');

  const [dbs] = await conn.query('SHOW DATABASES');
  console.log('Databases:');
  for (const row of dbs) {
    console.log('  ' + Object.values(row)[0]);
  }

  const [tables] = await conn.query('SHOW TABLES');
  console.log('\nTables in railway:', tables.length);

  await conn.query('USE railway');
  const [fullTables] = await conn.query('SHOW FULL TABLES');
  console.log('Full tables:', fullTables.length);

  await conn.end();
})();
