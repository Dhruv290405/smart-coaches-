const fs = require('fs').promises;
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function runMigrations() {
  let connection;
  try {
    // Create a connection to the MySQL server
    const dbConfig = {
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT || 3306,
      multipleStatements: true // Allow multiple SQL statements
    };

    connection = await mysql.createConnection(dbConfig);
    
    console.log('Connected to MySQL server');
    
    // Read the schema file
    const schemaPath = path.join(__dirname, '../sql/schema.sql');
    const schema = await fs.readFile(schemaPath, 'utf8');
    
    // Execute the schema
    await connection.query(schema);
    console.log('Database schema created successfully');
    
    // Close the connection
    await connection.end();
    console.log('Connection closed');
    
  } catch (error) {
    console.error('Error setting up database:', error);
    if (connection) {
      await connection.end();
    }
    process.exit(1);
  }
}

// Run the setup
runMigrations();
