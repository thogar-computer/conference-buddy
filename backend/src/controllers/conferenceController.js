const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

const getAllConferences = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, name, start_date, end_date, created_at FROM conferences ORDER BY start_date DESC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Get conferences error:', err);
    res.status(500).json({ error: 'Failed to get conferences' });
  }
};

const getConferenceById = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query(
      'SELECT id, name, start_date, end_date, created_at FROM conferences WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Conference not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Get conference error:', err);
    res.status(500).json({ error: 'Failed to get conference' });
  }
};

const createConference = async (req, res) => {
  try {
    const { name, startDate, endDate, organizerSecret } = req.body;

    if (!name || !startDate || !endDate) {
      return res.status(400).json({ error: 'Name, start date, and end date are required' });
    }

    const result = await db.query(
      'INSERT INTO conferences (name, start_date, end_date, organizer_secret) VALUES ($1, $2, $3, $4) RETURNING id, name, start_date, end_date, created_at',
      [name, startDate, endDate, organizerSecret || uuidv4()]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Create conference error:', err);
    res.status(500).json({ error: 'Failed to create conference' });
  }
};

module.exports = { getAllConferences, getConferenceById, createConference };