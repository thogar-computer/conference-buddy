# Conference Buddy

A location-based networking app for solo conference attendees to find and meet up with others staying nearby.

## Features

- **Authentication**: User sign-up and login
- **Conference Management**: Join conferences with hotel location
- **Privacy-Preserving Matching**: See only the count of nearby attendees (no exact locations shared)
- **Meetup System**: Broadcast meetup requests to nearby users with minimum 2 acceptances required
- **Safe Venue Suggestions**: Automatic recommendations for public meeting places
- **Admin Dashboard**: Manage users without viewing their locations
- **Organizer Verification API**: External conference organizers can verify attendee registration

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter |
| Backend | Node.js + Express |
| Database | PostgreSQL + PostGIS |
| Maps | OpenStreetMap (free) |
| Geocoding | Nominatim (OpenStreetMap) |
| Real-time | Socket.io |
| Auth | JWT |

## Project Structure

```
conference_buddy/
├── backend/                 # Node.js API server
│   ├── src/
│   │   ├── config/         # Configuration
│   │   ├── controllers/    # Request handlers
│   │   ├── middleware/     # Auth middleware
│   │   ├── migrations/     # SQL schema
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   └── server.js       # Entry point
│   └── package.json
│
└── frontend/
    └── conference_buddy/   # Flutter app
        └── lib/
            ├── models/     # Data models
            ├── providers/  # State management
            ├── screens/    # UI screens
            ├── services/   # API services
            └── widgets/    # Reusable widgets
```

## Prerequisites

- Node.js 18+
- PostgreSQL 14+ with PostGIS extension
- Flutter 3.x
- Dart 3.x

## Quick Start (Docker Database)

```bash
# 1. Start PostgreSQL with PostGIS
docker run -d --name conference-buddy-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=conference_buddy \
  -p 5432:5432 \
  postgis/postgis:17-3.5

# 2. Run migrations
docker exec -i conference-buddy-db psql -U postgres -d conference_buddy < backend/migrations/001_initial_schema.sql

# 3. Start backend (from WSL)
cd backend && npm install && npm start

# 4. Start frontend (from WSL)
cd frontend/conference_buddy && flutter pub get && flutter run -d chrome
```

## WSL Setup (Windows Development)

If you're developing on Windows with WSL, follow these steps:

### 1. Install Prerequisites in WSL

```bash
# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# PostgreSQL client
sudo apt install postgresql-client
```

### 2. Configure Docker Access

Since Docker Desktop on Windows runs as a service, access it from WSL:

```bash
# Add current user to docker group (may need to restart)
sudo usermod -aG docker $USER

# Or use docker via Windows path
export DOCKER_HOST="tcp://localhost:2375"
```

### 3. Run the Project

```bash
# Terminal 1 - Start database (if not already running)
docker run -d --name conference-buddy-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=conference_buddy \
  -p 5432:5432 \
  postgis/postgis:17-3.5

# Run migrations
docker exec -i conference-buddy-db psql -U postgres -d conference_buddy < backend/migrations/001_initial_schema.sql

# Terminal 2 - Backend
cd /path/to/conference_buddy/backend
npm install
npm start

# Terminal 3 - Frontend
cd /path/to/conference_buddy/frontend/conference_buddy
flutter pub get
flutter run -d chrome
```

### 4. Access the App

- Backend API: http://localhost:3000
- Frontend: http://localhost:port (Flutter will specify)
- Database: localhost:5432

### Troubleshooting WSL

- **Flutter not found**: Add `export PATH="$HOME/flutter/bin:$PATH"` to ~/.bashrc
- **Node not found**: Use full path or ensure Node.js is installed in WSL, not Windows
- **Docker connection refused**: Ensure Docker Desktop is running and `export DOCKER_HOST="tcp://localhost:2375"` is set
- **Port conflicts**: Ensure Windows and WSL aren't both trying to use port 3000 or 5432

## Setup

### 1. Database Setup

Create a PostgreSQL database and enable PostGIS:

```sql
CREATE DATABASE conference_buddy;
\c conference_buddy
CREATE EXTENSION postgis;
```

Run the migration:

```bash
cd backend
psql -U postgres -d conference_buddy -f migrations/001_initial_schema.sql
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your settings:
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=conference_buddy
# DB_USER=postgres
# DB_PASSWORD=your_password
# JWT_SECRET=your-secret-key

# Start server
npm start
```

The API will run at `http://localhost:3000`

### 3. Frontend Setup

```bash
cd frontend/conference_buddy

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Or run on mobile
flutter run -d android
flutter run -d ios
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Register new user |
| POST | /api/auth/login | Login user |
| GET | /api/auth/profile | Get current user |
| GET | /api/conferences | List all conferences |
| GET | /api/user-conferences | Get user's conferences |
| POST | /api/user-conferences | Register for a conference |
| GET | /api/nearby/count | Get nearby attendee count |
| POST | /api/meetups | Create a meetup request |
| GET | /api/meetups | List user's meetups |
| POST | /api/meetups/:id/respond | Accept/decline meetup |
| GET | /api/admin/users | Admin: list users (no locations) |
| GET | /api/admin/verify/:userId | Organizer verification |
| GET | /api/search/locations | Search locations |
| GET | /api/search/hotels | Search hotels |

## Environment Variables

### Backend (.env)

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 3000 |
| DB_HOST | PostgreSQL host | localhost |
| DB_PORT | PostgreSQL port | 5432 |
| DB_NAME | Database name | conference_buddy |
| DB_USER | Database user | postgres |
| DB_PASSWORD | Database password | postgres |
| JWT_SECRET | JWT signing secret | (change in production) |
| JWT_EXPIRATION | Token expiration | 7d |

## Security Notes

- User locations are NEVER exposed to other users
- Admin dashboard explicitly hides location data
- Meetups require minimum 2 acceptances before confirmation
- Venue suggestions prioritize public, well-lit locations
- JWT tokens expire after 7 days

## Development

### Running Tests (Backend)

```bash
cd backend
npm test
```

### Code Analysis (Frontend)

```bash
cd frontend/conference_buddy
flutter analyze
```

## License

MIT