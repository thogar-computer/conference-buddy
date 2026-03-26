-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conferences table
CREATE TABLE IF NOT EXISTS conferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  organizer_secret VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User conference attendance (linking users to conferences with their hotel location)
CREATE TABLE IF NOT EXISTS user_conferences (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  conference_id UUID REFERENCES conferences(id) ON DELETE CASCADE,
  hotel_name TEXT,
  hotel_address TEXT,
  hotel_lat DOUBLE PRECISION,
  hotel_lon DOUBLE PRECISION,
  hotel_geometry GEOGRAPHY(POINT, 4326),
  PRIMARY KEY (user_id, conference_id)
);

-- Create index for geospatial queries
CREATE INDEX IF NOT EXISTS idx_user_conferences_geometry 
ON user_conferences USING GIST (hotel_geometry);

-- Meetups table
CREATE TABLE IF NOT EXISTS meetups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES users(id) NOT NULL,
  conference_id UUID REFERENCES conferences(id) NOT NULL,
  venue_name TEXT,
  venue_address TEXT,
  venue_lat DOUBLE PRECISION,
  venue_lon DOUBLE PRECISION,
  status VARCHAR(32) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ
);

-- Meetup participants
CREATE TABLE IF NOT EXISTS meetup_participants (
  meetup_id UUID REFERENCES meetups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending',
  responded_at TIMESTAMPTZ,
  PRIMARY KEY (meetup_id, user_id)
);

-- Notifications table for push notifications tracking
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for user notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user 
ON notifications (user_id, is_read, created_at DESC);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for users table
CREATE TRIGGER update_users_updated_at 
BEFORE UPDATE ON users 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();