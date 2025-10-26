# CreatorOS Quick Start Guide

Get up and running with CreatorOS features in minutes.

## Prerequisites

- Node.js 18+ installed
- MongoDB running (locally or via Docker)
- Git

## Installation

1. **Clone and Install**
```bash
git clone https://github.com/hello-busy/hello.git
cd hello
npm install
```

2. **Configure Environment**
```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/hello
JWT_SECRET=your-secret-key-change-in-production
NODE_ENV=development
```

3. **Start MongoDB**

Using Docker:
```bash
docker-compose up -d mongo
```

Or locally:
```bash
mongod
```

4. **Start the Server**
```bash
npm start
```

The server will start on http://localhost:3000

## Quick API Tour

### 1. Register a User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "creator1",
    "email": "creator@example.com",
    "password": "securepass123"
  }'
```

Response includes a JWT token. Save this for subsequent requests.

### 2. Create a Project

```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "My First Video Project",
    "description": "Tutorial series about Node.js",
    "type": "video",
    "tags": ["nodejs", "tutorial"]
  }'
```

### 3. List Your Projects

```bash
curl http://localhost:3000/api/projects \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Add Media to Library

```bash
curl -X POST http://localhost:3000/api/media \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Intro Music",
    "description": "Background music for intro",
    "type": "audio",
    "fileUrl": "https://example.com/music.mp3",
    "tags": ["music", "intro"]
  }'
```

### 5. Browse Templates

```bash
curl http://localhost:3000/api/templates \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 6. Check Notifications

```bash
curl http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Using the Web Interface

1. Open http://localhost:3000 in your browser
2. Register or login
3. Explore the platform:
   - **Public Feed**: Share and discover content
   - **Communities**: Create or join communities
   - **Challenges**: Compete or collaborate

## CreatorOS Features Demo

### Creating a Complete Project Workflow

```javascript
// 1. Register and get token
const registerResponse = await fetch('http://localhost:3000/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'videocreator',
    email: 'video@creator.com',
    password: 'mypassword'
  })
});
const { token } = await registerResponse.json();

// 2. Create a project
const projectResponse = await fetch('http://localhost:3000/api/projects', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: 'Product Launch Video',
    description: 'Marketing video for new product',
    type: 'video',
    dueDate: '2024-03-01T00:00:00.000Z',
    tags: ['marketing', 'product']
  })
});
const { project } = await projectResponse.json();

// 3. Add a task to the project
await fetch(`http://localhost:3000/api/projects/${project._id}/tasks`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: 'Write script',
    description: 'Draft the video script',
    dueDate: '2024-02-15T00:00:00.000Z'
  })
});

// 4. Add media to library
await fetch('http://localhost:3000/api/media', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: 'Product Screenshots',
    type: 'image',
    fileUrl: 'https://example.com/screenshot.png',
    tags: ['product', 'screenshot']
  })
});

// 5. Create a version snapshot
await fetch(`http://localhost:3000/api/projects/${project._id}/versions`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    name: 'v0.1 - Initial Draft',
    description: 'First version with script'
  })
});

console.log('Project workflow created successfully!');
```

## Development Workflow

### Hot Reload During Development

```bash
npm run dev
```

This uses nodemon to automatically restart on file changes.

### Project Structure

```
hello/
├── src/
│   ├── models/          # Data models (Mongoose schemas)
│   ├── controllers/     # Business logic
│   ├── routes/          # API endpoints
│   ├── middleware/      # Auth, gamification
│   └── app.js          # Express app setup
├── public/             # Frontend files
├── ROADMAP.md          # Feature roadmap
├── API.md              # API documentation
└── IMPLEMENTATION_GUIDE.md  # Developer guide
```

### Adding a New Feature

1. Create model in `src/models/`
2. Create controller in `src/controllers/`
3. Create routes in `src/routes/`
4. Register routes in `src/app.js`

See [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for detailed instructions.

## Common Tasks

### Reset Database

```bash
# Using MongoDB shell
mongosh hello
db.dropDatabase()
```

### View Database Contents

```bash
mongosh hello
db.projects.find().pretty()
db.media.find().pretty()
db.templates.find().pretty()
```

### Check Server Health

```bash
curl http://localhost:3000/health
```

Expected response: `{"status":"ok"}`

### Test Authentication

```bash
# Register
TOKEN=$(curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"password"}' \
  | jq -r '.token')

# Use token
curl http://localhost:3000/api/projects \
  -H "Authorization: Bearer $TOKEN"
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill it
kill -9 <PID>

# Or use a different port
PORT=3001 npm start
```

### MongoDB Connection Error

```bash
# Check if MongoDB is running
mongosh

# Start MongoDB with Docker
docker-compose up -d mongo

# Check logs
docker-compose logs mongo
```

### JWT Token Invalid

- Token expires after 7 days
- Generate a new token by logging in again
- Check JWT_SECRET in .env matches server secret

### Module Not Found

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

## Next Steps

1. **Read the Documentation**
   - [ROADMAP.md](./ROADMAP.md) - Feature roadmap and status
   - [API.md](./API.md) - Complete API reference
   - [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Development guide
   - [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

2. **Explore the API**
   - Use Postman or curl to test endpoints
   - Try creating projects with different types
   - Experiment with templates and media

3. **Build the Frontend**
   - Create UI components for new features
   - Connect to API endpoints
   - Add real-time updates

4. **Contribute**
   - See [CONTRIBUTING.md](./CONTRIBUTING.md)
   - Pick a feature from ROADMAP.md
   - Submit a pull request

## Example: Complete Project Lifecycle

```bash
# 1. Create user and get token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"pro","email":"pro@example.com","password":"pass123"}' \
  | jq -r '.token')

# 2. Create project
PROJECT_ID=$(curl -s -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"My Project","description":"Test","type":"video"}' \
  | jq -r '.project._id')

# 3. Add task
curl -X POST "http://localhost:3000/api/projects/$PROJECT_ID/tasks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"Task 1","description":"Do something"}'

# 4. Create version
curl -X POST "http://localhost:3000/api/projects/$PROJECT_ID/versions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"v1.0","description":"First version"}'

# 5. View project
curl "http://localhost:3000/api/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  | jq
```

## Resources

- **GitHub**: https://github.com/hello-busy/hello
- **Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas

## Support

- Check [API.md](./API.md) for endpoint documentation
- Read [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for development help
- Open an issue on GitHub for bugs
- Join discussions for questions

---

**Ready to build amazing creator tools? Start exploring! 🚀**
