const express = require('express');
const router = express.Router();
const meetupController = require('../controllers/meetupController');
const { authMiddleware } = require('../middleware/auth');

router.post('/', authMiddleware, meetupController.createMeetup);
router.get('/', authMiddleware, meetupController.getMeetups);
router.get('/:meetupId', authMiddleware, meetupController.getMeetupById);
router.post('/:meetupId/respond', authMiddleware, meetupController.respondToMeetup);

module.exports = router;