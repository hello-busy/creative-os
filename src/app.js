const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const communityRoutes = require('./routes/communities');
const postRoutes = require('./routes/posts');
const challengeRoutes = require('./routes/challenges');
const projectRoutes = require('./routes/projects');
const mediaRoutes = require('./routes/media');
const templateRoutes = require('./routes/templates');
const notificationRoutes = require('./routes/notifications');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/communities', communityRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/challenges', challengeRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/media', mediaRoutes);
app.use('/api/templates', templateRoutes);
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Home route
app.get('/', (req, res) => {
  res.sendFile('index.html', { root: './public' });
});

module.exports = app;
