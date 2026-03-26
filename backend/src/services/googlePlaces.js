const https = require('https');
const config = require('../config');

const NOMINATIM_BASE_URL = 'https://nominatim.openstreetmap.org';

const makeRequest = (url) => {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        'User-Agent': 'ConferenceBuddy/1.0',
      }
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on('error', reject);
    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
};

const validateHotelLocation = async (lat, lon) => {
  try {
    const url = `${NOMINATIM_BASE_URL}/reverse?format=json&lat=${lat}&lon=${lon}&addressdetails=1`;
    const data = await makeRequest(url);

    if (!data || data.error) {
      return { isValid: false, message: 'Could not validate location' };
    }

    const address = data.address || {};
    const addressType = address.building || address.amenity || address.tourism || '';
    
    const isLodging = ['hotel', 'motel', 'hostel', 'guesthouse', 'guest_house', 'apartment', ' accommodation'].some(
      type => (address.tourism === 'hotel') || 
              (address.building && address.building.toLowerCase().includes('hotel')) ||
              (addressType && addressType.toLowerCase().includes('hotel'))
    );

    const hasAddress = address.road || address.city || address.town || address.village;

    if (!hasAddress) {
      return { isValid: false, message: 'Selected location does not appear to be a valid address' };
    }

    const validatedLat = parseFloat(data.lat);
    const validatedLon = parseFloat(data.lon);
    const formattedAddress = data.display_name;

    return { 
      isValid: true, 
      lat: validatedLat, 
      lon: validatedLon,
      address: formattedAddress 
    };
  } catch (err) {
    console.error('Location validation error:', err);
    return { isValid: true, lat, lon, message: 'Validation skipped (service unavailable)' };
  }
};

const findNearbyVenues = async (lat, lon, radius = 500) => {
  try {
    const searchRadiusKm = radius / 1000;
    const url = `${NOMINATIM_BASE_URL}/search?format=json&q=cafe+near+${lat},${lon}&limit=5&bounded=1&viewbox=${lon - 0.01},${lat + 0.01},${lon + 0.01},${lat - 0.01}`;
    const data = await makeRequest(url);

    if (!Array.isArray(data) || data.length === 0) {
      return [];
    }

    const venues = data.map(place => ({
      name: place.display_name.split(',')[0],
      address: place.display_name,
      lat: parseFloat(place.lat),
      lng: parseFloat(place.lon),
    }));

    return venues;
  } catch (err) {
    console.error('Find nearby venues error:', err);
    return [];
  }
};

const searchHotels = async (query) => {
  try {
    const url = `${NOMINATIM_BASE_URL}/search?format=json&q=${encodeURIComponent(query + ' hotel')}&limit=10&countrycodes=us&amenity=hotel`;
    const data = await makeRequest(url);

    if (!Array.isArray(data) || data.length === 0) {
      return [];
    }

    const hotels = data.map(place => ({
      name: place.display_name.split(',')[0],
      address: place.display_name,
      lat: parseFloat(place.lat),
      lng: parseFloat(place.lon),
    }));

    return hotels;
  } catch (err) {
    console.error('Search hotels error:', err);
    return [];
  }
};

const searchLocation = async (query) => {
  try {
    const url = `${NOMINATIM_BASE_URL}/search?format=json&q=${encodeURIComponent(query)}&limit=5`;
    const data = await makeRequest(url);

    if (!Array.isArray(data) || data.length === 0) {
      return [];
    }

    return data.map(place => ({
      name: place.display_name.split(',')[0],
      fullAddress: place.display_name,
      lat: parseFloat(place.lat),
      lon: parseFloat(place.lon),
      type: place.type,
    }));
  } catch (err) {
    console.error('Search location error:', err);
    return [];
  }
};

module.exports = { validateHotelLocation, findNearbyVenues, searchHotels, searchLocation };