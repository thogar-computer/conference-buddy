const express = require('express');
const router = express.Router();
const nearbyController = require('../controllers/nearbyController');
const { authMiddleware } = require('../middleware/auth');

router.get('/count', authMiddleware, nearbyController.getNearbyCount);
router.get('/users', authMiddleware, nearbyController.getNearbyUsers);

module.exports = router;