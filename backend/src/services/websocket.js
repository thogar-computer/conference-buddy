let io = null;

const setupWebSocket = (socketIO) => {
  io = socketIO;

  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('authenticate', (userId) => {
      socket.join(`user_${userId}`);
      console.log(`User ${userId} joined room user_${userId}`);
    });

    socket.on('join_conference', (conferenceId) => {
      socket.join(`conference_${conferenceId}`);
      console.log(`Socket ${socket.id} joined conference_${conferenceId}`);
    });

    socket.on('leave_conference', (conferenceId) => {
      socket.leave(`conference_${conferenceId}`);
    });

    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.id);
    });
  });
};

const getIO = () => io;

const notifyUser = (userId, event, data) => {
  if (io) {
    io.to(`user_${userId}`).emit(event, data);
  }
};

const notifyConference = (conferenceId, event, data) => {
  if (io) {
    io.to(`conference_${conferenceId}`).emit(event, data);
  }
};

module.exports = { setupWebSocket, getIO, notifyUser, notifyConference };