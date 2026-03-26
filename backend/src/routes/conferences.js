const express = require('express');
const router = express.Router();
const conferenceController = require('../controllers/conferenceController');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

router.get('/', conferenceController.getAllConferences);
router.get('/:id', conferenceController.getConferenceById);
router.post('/', authMiddleware, adminMiddleware, conferenceController.createConference);

module.exports = router;