const db = require('../config/database');
const config = require('../config/index');
const { findNearbyVenues } = require('../services/googlePlaces');
const { getIO } = require('../services/websocket');

const createMeetup = async (req, res) => {
  try {
    const { conferenceId, radiusKm } = req.body;
    const creatorId = req.user.id;

    if (!conferenceId) {
      return res.status(400).json({ error: 'Conference ID is required' });
    }

    const userLocation = await db.query(
      'SELECT hotel_lat, hotel_lon, hotel_geometry FROM user_conferences WHERE user_id = $1 AND conference_id = $2',
      [creatorId, conferenceId]
    );

    if (userLocation.rows.length === 0) {
      return res.status(404).json({ error: 'Not registered for this conference' });
    }

    const { hotel_lat: lat, hotel_lon: lon } = userLocation.rows[0];

    if (!lat || !lon) {
      return res.status(400).json({ error: 'Hotel location not set' });
    }

    const radius = radiusKm ? parseFloat(radiusKm) : config.defaultSearchRadiusKm;

    const nearbyUsers = await db.query(
      `SELECT u.id, u.full_name, u.email
       FROM user_conferences uc
       JOIN users u ON uc.user_id = u.id
       WHERE uc.conference_id = $1
         AND uc.user_id != $2
         AND ST_DWithin(uc.hotel_geometry, ST_MakePoint($3, $4)::geography, $5 * 1000)`,
      [conferenceId, creatorId, lon, lat, radius]
    );

    if (nearbyUsers.rows.length < config.meetupMinParticipants - 1) {
      return res.status(400).json({ 
        error: `Not enough nearby attendees. Need at least ${config.meetupMinParticipants - 1} more.` 
      });
    }

    const venues = await findNearbyVenues(lat, lon, 500);
    const suggestedVenue = venues.length > 0 ? venues[0] : null;

    const meetupResult = await db.query(
      `INSERT INTO meetups (creator_id, conference_id, venue_name, venue_address, venue_lat, venue_lon, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'pending')
       RETURNING id, creator_id, conference_id, venue_name, venue_address, venue_lat, venue_lon, status, created_at`,
      [
        creatorId, 
        conferenceId, 
        suggestedVenue?.name || null,
        suggestedVenue?.address || null,
        suggestedVenue?.lat || null,
        suggestedVenue?.lng || null,
      ]
    );

    const meetup = meetupResult.rows[0];

    await db.query(
      'INSERT INTO meetup_participants (meetup_id, user_id, status) VALUES ($1, $2, $3)',
      [meetup.id, creatorId, 'creator']
    );

    for (const user of nearbyUsers.rows) {
      await db.query(
        'INSERT INTO meetup_participants (meetup_id, user_id, status) VALUES ($1, $2, $3)',
        [meetup.id, user.id, 'pending']
      );

      const io = getIO();
      if (io) {
        io.to(`user_${user.id}`).emit('meetup_request', {
          meetupId: meetup.id,
          creatorName: req.user.fullName || 'Someone',
          conferenceId,
          venue: suggestedVenue,
        });
      }
    }

    const participantsResult = await db.query(
      `SELECT mp.user_id, u.full_name, mp.status 
       FROM meetup_participants mp 
       JOIN users u ON mp.user_id = u.id 
       WHERE mp.meetup_id = $1`,
      [meetup.id]
    );

    res.status(201).json({
      meetup,
      participants: participantsResult.rows,
      suggestedVenue,
      nearbyUserCount: nearbyUsers.rows.length,
    });
  } catch (err) {
    console.error('Create meetup error:', err);
    res.status(500).json({ error: 'Failed to create meetup' });
  }
};

const getMeetups = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await db.query(
      `SELECT m.id, m.creator_id, m.conference_id, m.venue_name, m.venue_address, 
              m.venue_lat, m.venue_lon, m.status, m.created_at, m.confirmed_at,
              c.name as conference_name,
              u.full_name as creator_name
       FROM meetups m
       JOIN conferences c ON m.conference_id = c.id
       JOIN users u ON m.creator_id = u.id
       WHERE m.id IN (SELECT meetup_id FROM meetup_participants WHERE user_id = $1)
       ORDER BY m.created_at DESC`,
      [userId]
    );

    const meetups = await Promise.all(result.rows.map(async (meetup) => {
      const participantsResult = await db.query(
        `SELECT mp.user_id, u.full_name, mp.status 
         FROM meetup_participants mp 
         JOIN users u ON mp.user_id = u.id 
         WHERE mp.meetup_id = $1`,
        [meetup.id]
      );

      return {
        ...meetup,
        participants: participantsResult.rows,
      };
    }));

    res.json(meetups);
  } catch (err) {
    console.error('Get meetups error:', err);
    res.status(500).json({ error: 'Failed to get meetups' });
  }
};

const respondToMeetup = async (req, res) => {
  try {
    const { meetupId } = req.params;
    const { accept } = req.body;
    const userId = req.user.id;

    const meetupResult = await db.query(
      'SELECT * FROM meetups WHERE id = $1',
      [meetupId]
    );

    if (meetupResult.rows.length === 0) {
      return res.status(404).json({ error: 'Meetup not found' });
    }

    const meetup = meetupResult.rows[0];

    if (meetup.status !== 'pending') {
      return res.status(400).json({ error: 'Meetup is no longer pending' });
    }

    const participantResult = await db.query(
      'SELECT * FROM meetup_participants WHERE meetup_id = $1 AND user_id = $2',
      [meetupId, userId]
    );

    if (participantResult.rows.length === 0) {
      return res.status(403).json({ error: 'Not a participant of this meetup' });
    }

    const newStatus = accept ? 'accepted' : 'rejected';

    await db.query(
      'UPDATE meetup_participants SET status = $1, responded_at = NOW() WHERE meetup_id = $2 AND user_id = $3',
      [newStatus, meetupId, userId]
    );

    const acceptancesResult = await db.query(
      `SELECT COUNT(*) as count FROM meetup_participants 
       WHERE meetup_id = $1 AND status = 'accepted'`,
      [meetupId]
    );

    const acceptanceCount = parseInt(acceptancesResult.rows[0].count);

    if (acceptanceCount >= config.meetupMinParticipants) {
      await db.query(
        "UPDATE meetups SET status = 'confirmed', confirmed_at = NOW() WHERE id = $1",
        [meetupId]
      );

      const io = getIO();
      if (io) {
        io.to(`user_${meetup.creator_id}`).emit('meetup_confirmed', {
          meetupId,
          acceptedCount: acceptanceCount,
        });
      }
    }

    res.json({ 
      success: true, 
      status: newStatus,
      acceptanceCount,
      meetsThreshold: acceptanceCount >= config.meetupMinParticipants,
    });
  } catch (err) {
    console.error('Respond to meetup error:', err);
    res.status(500).json({ error: 'Failed to respond to meetup' });
  }
};

const getMeetupById = async (req, res) => {
  try {
    const { meetupId } = req.params;
    const userId = req.user.id;

    const result = await db.query(
      `SELECT m.*, c.name as conference_name, u.full_name as creator_name
       FROM meetups m
       JOIN conferences c ON m.conference_id = c.id
       JOIN users u ON m.creator_id = u.id
       WHERE m.id = $1`,
      [meetupId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Meetup not found' });
    }

    const participantsResult = await db.query(
      `SELECT mp.user_id, u.full_name, mp.status, mp.responded_at 
       FROM meetup_participants mp 
       JOIN users u ON mp.user_id = u.id 
       WHERE mp.meetup_id = $1`,
      [meetupId]
    );

    res.json({
      ...result.rows[0],
      participants: participantsResult.rows,
    });
  } catch (err) {
    console.error('Get meetup error:', err);
    res.status(500).json({ error: 'Failed to get meetup' });
  }
};

module.exports = { createMeetup, getMeetups, respondToMeetup, getMeetupById };