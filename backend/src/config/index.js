require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET || 'conference-buddy-secret-key-change-in-production',
  jwtExpiration: process.env.JWT_EXPIRATION || '7d',
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'conference_buddy',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
  },
  googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY || '',
  defaultSearchRadiusKm: 2,
  meetupMinParticipants: 2,
};