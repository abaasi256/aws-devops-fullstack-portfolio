/**
 * User model for database interactions
 */

const { pool } = require('../utils/db');
const { logger } = require('../utils/logger');
const bcrypt = require('bcryptjs');

class User {
  static async initTable() {
    try {
      const createTableQuery = `
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(50) UNIQUE NOT NULL,
          email VARCHAR(100) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          first_name VARCHAR(50) NOT NULL,
          last_name VARCHAR(50) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      `;
      
      const connection = await pool.getConnection();
      await connection.query(createTableQuery);
      connection.release();
      logger.info('Users table initialized');
      
      // Insert sample user if none exists
      await User.createSampleUser();
    } catch (error) {
      logger.error('Error initializing users table:', error);
      throw error;
    }
  }
  
  static async createSampleUser() {
    try {
      const connection = await pool.getConnection();
      
      // Check if a user already exists
      const [rows] = await connection.query('SELECT COUNT(*) as count FROM users');
      
      if (rows[0].count === 0) {
        // Create a sample user
        const hashedPassword = await bcrypt.hash('password123', 10);
        await connection.query(
          'INSERT INTO users (username, email, password, first_name, last_name) VALUES (?, ?, ?, ?, ?)',
          ['admin', 'admin@example.com', hashedPassword, 'Admin', 'User']
        );
        logger.info('Sample user created');
      }
      
      connection.release();
    } catch (error) {
      logger.error('Error creating sample user:', error);
      throw error;
    }
  }
  
  static async findByUsername(username) {
    try {
      const connection = await pool.getConnection();
      const [rows] = await connection.query(
        'SELECT * FROM users WHERE username = ?',
        [username]
      );
      connection.release();
      
      return rows.length ? rows[0] : null;
    } catch (error) {
      logger.error('Error finding user by username:', error);
      throw error;
    }
  }
  
  static async findByEmail(email) {
    try {
      const connection = await pool.getConnection();
      const [rows] = await connection.query(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
      connection.release();
      
      return rows.length ? rows[0] : null;
    } catch (error) {
      logger.error('Error finding user by email:', error);
      throw error;
    }
  }
  
  static async create(userData) {
    try {
      const { username, email, password, firstName, lastName } = userData;
      
      // Hash the password
      const hashedPassword = await bcrypt.hash(password, 10);
      
      const connection = await pool.getConnection();
      const [result] = await connection.query(
        'INSERT INTO users (username, email, password, first_name, last_name) VALUES (?, ?, ?, ?, ?)',
        [username, email, hashedPassword, firstName, lastName]
      );
      connection.release();
      
      return { id: result.insertId, username, email, firstName, lastName };
    } catch (error) {
      logger.error('Error creating user:', error);
      throw error;
    }
  }
  
  static async validateCredentials(username, password) {
    try {
      const user = await this.findByUsername(username);
      
      if (!user) {
        return null;
      }
      
      const isPasswordValid = await bcrypt.compare(password, user.password);
      
      if (!isPasswordValid) {
        return null;
      }
      
      // Remove password from user object before returning
      const { password: _, ...userWithoutPassword } = user;
      return userWithoutPassword;
    } catch (error) {
      logger.error('Error validating credentials:', error);
      throw error;
    }
  }
}

module.exports = User;
