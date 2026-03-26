const db = require('../config/database');
const config = require('../config/index');

const getNearbyCount = async (req, res) => {
  try {
    const { conferenceId, radiusKm } = req.query;
    const userId = req.user.id;

    if (!conferenceId) {
      return res.status(400).json({ error: 'Conference ID is required' });
    }

    const userLocation = await db.query(
      'SELECT hotel_lat, hotel_lon, hotel_geometry FROM user_conferences WHERE user_id = $1 AND conference_id = $2',
      [userId, conferenceId]
    );

    if (userLocation.rows.length === 0) {
      return res.status(404).json({ error: 'Not registered for this conference' });
    }

    const { hotel_lat: lat, hotel_lon: lon, hotel_geometry: geometry } = userLocation.rows[0];

    if (!lat || !lon) {
      return res.status(400).json({ error: 'Hotel location not set' });
    }

    const radius = radiusKm ? parseFloat(radiusKm) : config.defaultSearchRadiusKm;

    const result = await db.query(
      `SELECT COUNT(*) as count
       FROM user_conferences uc
       JOIN users u ON uc.user_id = u.id
       WHERE uc.conference_id = $1
         AND uc.user_id != $2
         AND ST_DWithin(uc.hotel_geometry, ST_MakePoint($3, $4)::geography, $5 * 1000)`,
      [conferenceId, userId, lon, lat, radius]
    );

    res.json({
      count: parseInt(result.rows[0].count),
      radiusKm: radius,
      conferenceId,
    });
  } catch (err) {
    console.error('Get nearby count error:', err);
    res.status(500).json({ error: 'Failed to get nearby count' });
  }
};

const getNearbyUsers = async (req, res) => {
  try {
    const { conferenceId, radiusKm } = req.query;
    const userId = req.user.id;

    if (!conferenceId) {
      return res.status(400).json({ error: 'Conference ID is required' });
    }

    const userLocation = await db.query(
      'SELECT hotel_lat, hotel_lon FROM user_conferences WHERE user_id = $1 AND conference_id = $2',
      [userId, conferenceId]
    );

    if (userLocation.rows.length === 0) {
      return res.status(404).json({ error: 'Not registered for this conference' });
    }

    const { hotel_lat: lat, hotel_lon: lon } = userLocation.rows[0];

    if (!lat || !lon) {
      return res.status(400).json({ error: 'Hotel location not set' });
    }

    const radius = radiusKm ? parseFloat(radiusKm) : config.defaultSearchRadiusKm;

    const result = await db.query(
      `SELECT u.id, u.full_name, u.email,
              ST_Distance(uc.hotel_geometry, ST_MakePoint($3, $4)::geography) / 1000 as distance_km
       FROM user_conferences uc
       JOIN users u ON uc.user_id = u.id
       WHERE uc.conference_id = $1
         AND uc.user_id != $2
         AND ST_DWithin(uc.hotel_geometry, ST_MakePoint($3, $4)::geography, $5 * 1000)
       ORDER BY distance_km ASC`,
      [conferenceId, userId, lon, lat, radius]
    );

    const users = result.rows.map(row => ({
      id: row.id,
      fullName: row.full_name,
      distanceKm: Math.round(row.distance_km * 100) / 100,
    }));

    res.json({
      users,
      radiusKm: radius,
      conferenceId,
    });
  } catch (err) {
    console.error('Get nearby users error:', err);
    res.status(500).json({ error: 'Failed to get nearby users' });
  }
};

module.exports = { getNearbyCount, getNearbyUsers };