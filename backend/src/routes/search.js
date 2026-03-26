const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const { authMiddleware } = require('../middleware/auth');

router.get('/locations', authMiddleware, searchController.searchLocations);
router.get('/hotels', authMiddleware, searchController.searchHotelsByName);

module.exports = router;