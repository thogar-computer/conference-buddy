const { searchHotels, searchLocation } = require('../services/googlePlaces');

const searchLocations = async (req, res) => {
  try {
    const { query } = req.query;

    if (!query) {
      return res.status(400).json({ error: 'Search query is required' });
    }

    const results = await searchLocation(query);
    res.json(results);
  } catch (err) {
    console.error('Search locations error:', err);
    res.status(500).json({ error: 'Search failed' });
  }
};

const searchHotelsByName = async (req, res) => {
  try {
    const { query } = req.query;

    if (!query) {
      return res.status(400).json({ error: 'Search query is required' });
    }

    const results = await searchHotels(query);
    res.json(results);
  } catch (err) {
    console.error('Search hotels error:', err);
    res.status(500).json({ error: 'Search failed' });
  }
};

module.exports = { searchLocations, searchHotelsByName };