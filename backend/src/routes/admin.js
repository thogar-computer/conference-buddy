const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

router.get('/users', authMiddleware, adminMiddleware, adminController.getAllUsers);
router.get('/users/:userId', authMiddleware, adminMiddleware, adminController.getUserById);
router.delete('/users/:userId', authMiddleware, adminMiddleware, adminController.deleteUser);
router.get('/verify/:userId', adminController.verifyUserForConference);

module.exports = router;