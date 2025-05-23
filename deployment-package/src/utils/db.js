/**
 * Database connection configuration
 */

const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const fs = require('fs');
const { logger } = require('../utils/logger');

// Load environment variables
dotenv.config();

/**
 * Get database configuration from environment variables
 * In production, these values can be loaded from AWS Parameter Store
 */
const getDbConfig = () => {
  // If running in AWS, try to get database configuration from Parameter Store
  if (process.env.NODE_ENV === 'production') {
    try {
      const dbHost = process.env.DB_HOST || '';
      const dbName = process.env.DB_NAME || '';
      const dbUser = process.env.DB_USER || '';
      const dbPassword = process.env.DB_PASSWORD || '';
      
      return {
        host: dbHost,
        port: parseInt(process.env.DB_PORT || '3306'),
        user: dbUser,
        password: dbPassword,
        database: dbName,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
        ssl: process.env.NODE_ENV === 'production' ? {
          // In production, we can use SSL with the RDS CA certificate
          ca: fs.readFileSync('./rds-ca-2019-root.pem')
        } : undefined
      };
    } catch (error) {
      logger.error('Error loading database configuration:', error);
      throw new Error('Could not load database configuration');
    }
  }

  // Default configuration for development
  return {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'admin',
    password: process.env.DB_PASSWORD || 'your_password',
    database: process.env.DB_NAME || 'appdb',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  };
};

// Create a MySQL connection pool
const pool = mysql.createPool(getDbConfig());

// Test the database connection
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    logger.info('Database connection successful');
    connection.release();
    return true;
  } catch (error) {
    logger.error('Database connection failed:', error);
    return false;
  }
};

module.exports = {
  pool,
  testConnection
};
