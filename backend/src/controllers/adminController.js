const db = require('../config/database');

const getAllUsers = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT u.id, u.email, u.full_name, u.is_admin, u.created_at,
              array_agg(c.name) FILTER (WHERE c.name IS NOT NULL) as conferences
       FROM users u
       LEFT JOIN user_conferences uc ON u.id = uc.user_id
       LEFT JOIN conferences c ON uc.conference_id = c.id
       GROUP BY u.id
       ORDER BY u.created_at DESC`
    );

    const users = result.rows.map(row => ({
      id: row.id,
      email: row.email,
      fullName: row.full_name,
      isAdmin: row.is_admin,
      conferences: row.conferences || [],
      createdAt: row.created_at,
    }));

    res.json(users);
  } catch (err) {
    console.error('Get all users error:', err);
    res.status(500).json({ error: 'Failed to get users' });
  }
};

const getUserById = async (req, res) => {
  try {
    const { userId } = req.params;

    const userResult = await db.query(
      'SELECT id, email, full_name, is_admin, created_at FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const conferencesResult = await db.query(
      `SELECT c.id, c.name, c.start_date, c.end_date, uc.hotel_name
       FROM user_conferences uc
       JOIN conferences c ON uc.conference_id = c.id
       WHERE uc.user_id = $1`,
      [userId]
    );

    res.json({
      ...userResult.rows[0],
      conferences: conferencesResult.rows,
    });
  } catch (err) {
    console.error('Get user by ID error:', err);
    res.status(500).json({ error: 'Failed to get user' });
  }
};

const verifyUserForConference = async (req, res) => {
  try {
    const { userId } = req.params;
    const { conferenceId, organizerSecret } = req.body;

    if (!conferenceId || !organizerSecret) {
      return res.status(400).json({ error: 'Conference ID and organizer secret are required' });
    }

    const conferenceResult = await db.query(
      'SELECT * FROM conferences WHERE id = $1 AND organizer_secret = $2',
      [conferenceId, organizerSecret]
    );

    if (conferenceResult.rows.length === 0) {
      return res.status(403).json({ error: 'Invalid conference or organizer secret' });
    }

    const registrationResult = await db.query(
      'SELECT * FROM user_conferences WHERE user_id = $1 AND conference_id = $2',
      [userId, conferenceId]
    );

    const isRegistered = registrationResult.rows.length > 0;

    const userResult = await db.query(
      'SELECT full_name, email FROM users WHERE id = $1',
      [userId]
    );

    const user = userResult.rows.length > 0 ? userResult.rows[0] : null;

    res.json({
      userId,
      conferenceId,
      conferenceName: conferenceResult.rows[0].name,
      isRegisteredForConference: isRegistered,
      user: user ? { fullName: user.full_name, email: user.email } : null,
    });
  } catch (err) {
    console.error('Verify user error:', err);
    res.status(500).json({ error: 'Failed to verify user' });
  }
};

const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await db.query(
      'DELETE FROM users WHERE id = $1 RETURNING id',
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, message: 'User deleted' });
  } catch (err) {
    console.error('Delete user error:', err);
    res.status(500).json({ error: 'Failed to delete user' });
  }
};

module.exports = { getAllUsers, getUserById, verifyUserForConference, deleteUser };