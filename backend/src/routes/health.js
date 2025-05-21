/**
 * Health check route for monitoring
 */

const express = require('express');
const router = express.Router();
const { testConnection } = require('../utils/db');
const { logger } = require('../utils/logger');

/**
 * @route   GET /health
 * @desc    Health check endpoint
 * @access  Public
 */
router.get('/', async (req, res) => {
  try {
    // Test database connection
    const dbConnection = await testConnection();
    
    const health = {
      status: 'ok',
      timestamp: new Date(),
      uptime: process.uptime(),
      database: dbConnection ? 'connected' : 'disconnected',
      environment: process.env.NODE_ENV
    };
    
    if (!dbConnection) {
      logger.warn('Health check: Database connection failed');
      health.status = 'degraded';
      return res.status(200).json(health);
    }
    
    return res.status(200).json(health);
  } catch (error) {
    logger.error('Health check error:', error);
    
    return res.status(500).json({
      status: 'error',
      timestamp: new Date(),
      error: error.message
    });
  }
});

module.exports = router;
