const db = require('../config/database');
const { validateHotelLocation } = require('../services/googlePlaces');

const registerForConference = async (req, res) => {
  try {
    const { conferenceId, hotelName, hotelAddress, hotelLat, hotelLon } = req.body;
    const userId = req.user.id;

    if (!conferenceId || !hotelName) {
      return res.status(400).json({ error: 'Conference ID and hotel name are required' });
    }

    const conferenceResult = await db.query(
      'SELECT id, name, start_date, end_date FROM conferences WHERE id = $1',
      [conferenceId]
    );

    if (conferenceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Conference not found' });
    }

    const existingRegistration = await db.query(
      'SELECT * FROM user_conferences WHERE user_id = $1 AND conference_id = $2',
      [userId, conferenceId]
    );

    if (existingRegistration.rows.length > 0) {
      return res.status(409).json({ error: 'Already registered for this conference' });
    }

    let validatedLat = hotelLat;
    let validatedLon = hotelLon;

    if (hotelLat && hotelLon) {
      const validation = await validateHotelLocation(hotelLat, hotelLon);
      if (!validation.isValid) {
        return res.status(400).json({ error: validation.message });
      }
      validatedLat = validation.lat;
      validatedLon = validation.lon;
    }

    const geometry = validatedLat && validatedLon 
      ? `SRID=4326;POINT(${validatedLon} ${validatedLat})`
      : null;

    await db.query(
      `INSERT INTO user_conferences (user_id, conference_id, hotel_name, hotel_address, hotel_lat, hotel_lon, hotel_geometry)
       VALUES ($1, $2, $3, $4, $5, $6, $7::geography)`,
      [userId, conferenceId, hotelName, hotelAddress || null, validatedLat, validatedLon, geometry]
    );

    const result = await db.query(
      `SELECT uc.*, c.name as conference_name, c.start_date, c.end_date
       FROM user_conferences uc
       JOIN conferences c ON uc.conference_id = c.id
       WHERE uc.user_id = $1 AND uc.conference_id = $2`,
      [userId, conferenceId]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Register for conference error:', err);
    res.status(500).json({ error: 'Failed to register for conference' });
  }
};

const getUserConferences = async (req, res) => {
  try {
    const userId = req.params.userId || req.user.id;

    const result = await db.query(
      `SELECT uc.*, c.name as conference_name, c.start_date, c.end_date
       FROM user_conferences uc
       JOIN conferences c ON uc.conference_id = c.id
       WHERE uc.user_id = $1
       ORDER BY c.start_date DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Get user conferences error:', err);
    res.status(500).json({ error: 'Failed to get user conferences' });
  }
};

const updateHotelLocation = async (req, res) => {
  try {
    const { conferenceId } = req.params;
    const { hotelName, hotelAddress, hotelLat, hotelLon } = req.body;
    const userId = req.user.id;

    if (!hotelName || !hotelLat || !hotelLon) {
      return res.status(400).json({ error: 'Hotel name, latitude, and longitude are required' });
    }

    const validation = await validateHotelLocation(hotelLat, hotelLon);
    if (!validation.isValid) {
      return res.status(400).json({ error: validation.message });
    }

    const geometry = `SRID=4326;POINT(${hotelLon} ${hotelLat})`;

    await db.query(
      `UPDATE user_conferences 
       SET hotel_name = $1, hotel_address = $2, hotel_lat = $3, hotel_lon = $4, hotel_geometry = $5::geography
       WHERE user_id = $6 AND conference_id = $7`,
      [hotelName, hotelAddress || null, hotelLat, hotelLon, geometry, userId, conferenceId]
    );

    const result = await db.query(
      `SELECT uc.*, c.name as conference_name, c.start_date, c.end_date
       FROM user_conferences uc
       JOIN conferences c ON uc.conference_id = c.id
       WHERE uc.user_id = $1 AND uc.conference_id = $2`,
      [userId, conferenceId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Update hotel location error:', err);
    res.status(500).json({ error: 'Failed to update hotel location' });
  }
};

module.exports = { registerForConference, getUserConferences, updateHotelLocation };