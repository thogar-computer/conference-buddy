const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const http = require('http');
const { Server } = require('socket.io');
const config = require('./config');
const authRoutes = require('./routes/auth');
const conferenceRoutes = require('./routes/conferences');
const userConferenceRoutes = require('./routes/userConferences');
const meetupRoutes = require('./routes/meetups');
const adminRoutes = require('./routes/admin');
const nearbyRoutes = require('./routes/nearby');
const searchRoutes = require('./routes/search');
const { setupWebSocket } = require('./services/websocket');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/conferences', conferenceRoutes);
app.use('/api/user-conferences', userConferenceRoutes);
app.use('/api/meetups', meetupRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/nearby', nearbyRoutes);
app.use('/api/search', searchRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

setupWebSocket(io);

server.listen(config.port, () => {
  console.log(`Server running on port ${config.port}`);
});

module.exports = { app, server, io };