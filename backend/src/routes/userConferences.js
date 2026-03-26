const express = require('express');
const router = express.Router();
const userConferenceController = require('../controllers/userConferenceController');
const { authMiddleware } = require('../middleware/auth');

router.post('/', authMiddleware, userConferenceController.registerForConference);
router.get('/', authMiddleware, userConferenceController.getUserConferences);
router.get('/:userId', authMiddleware, userConferenceController.getUserConferences);
router.put('/:conferenceId', authMiddleware, userConferenceController.updateHotelLocation);

module.exports = router;