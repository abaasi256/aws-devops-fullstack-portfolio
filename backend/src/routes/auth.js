/**
 * Authentication routes
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const auth = require('../middlewares/auth');
const { logger } = require('../utils/logger');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  [
    body('username', 'Username is required').not().isEmpty(),
    body('email', 'Please include a valid email').isEmail(),
    body('password', 'Password must be at least 6 characters').isLength({ min: 6 }),
    body('firstName', 'First name is required').not().isEmpty(),
    body('lastName', 'Last name is required').not().isEmpty(),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      
      const { username, email, password, firstName, lastName } = req.body;
      
      // Check if username already exists
      let user = await User.findByUsername(username);
      if (user) {
        return res.status(400).json({ message: 'Username already exists' });
      }
      
      // Check if email already exists
      user = await User.findByEmail(email);
      if (user) {
        return res.status(400).json({ message: 'Email already exists' });
      }
      
      // Create user
      const newUser = await User.create({
        username,
        email,
        password,
        firstName,
        lastName,
      });
      
      // Create JWT token
      const payload = {
        user: {
          id: newUser.id,
          username: newUser.username,
        },
      };
      
      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN },
        (err, token) => {
          if (err) throw err;
          res.json({ token });
        }
      );
    } catch (error) {
      logger.error('Registration error:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
);

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user & get token
 * @access  Public
 */
router.post(
  '/login',
  [
    body('username', 'Username is required').not().isEmpty(),
    body('password', 'Password is required').exists(),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      
      const { username, password } = req.body;
      
      // Validate credentials
      const user = await User.validateCredentials(username, password);
      
      if (!user) {
        return res.status(401).json({ message: 'Invalid credentials' });
      }
      
      // Create JWT token
      const payload = {
        user: {
          id: user.id,
          username: user.username,
        },
      };
      
      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN },
        (err, token) => {
          if (err) throw err;
          res.json({ token, user: { id: user.id, username: user.username, email: user.email } });
        }
      );
    } catch (error) {
      logger.error('Login error:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
);

/**
 * @route   GET /api/auth/me
 * @desc    Get authenticated user
 * @access  Private
 */
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findByUsername(req.user.user.username);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Remove password from user object
    const { password, ...userWithoutPassword } = user;
    
    res.json(userWithoutPassword);
  } catch (error) {
    logger.error('Get user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
