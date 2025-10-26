# CreatorOS Implementation Guide

This guide helps developers understand and extend the CreatorOS features implemented in this project.

## Overview

CreatorOS extends the Hello platform with professional creator workflow features. This document explains the architecture, implementation patterns, and how to build upon the foundation.

## Architecture

### Model-Controller-Route Pattern

All CreatorOS features follow a consistent MVC pattern:

```
Model (Data) → Controller (Logic) → Route (API) → Frontend (UI)
```

### Feature Structure

Each feature consists of:
1. **Model**: MongoDB schema in `src/models/`
2. **Controller**: Business logic in `src/controllers/`
3. **Route**: API endpoints in `src/routes/`
4. **Integration**: Route registered in `src/app.js`

## Implemented Features

### 1. Project Management

**Purpose**: Manage creative projects with tasks, versions, and collaboration.

**Model**: `src/models/Project.js`
- Supports multiple project types (video, podcast, social, design, other)
- Embedded tasks with status tracking
- Version history with snapshots
- Collaborator management with roles

**Controller**: `src/controllers/projectController.js`
- `createProject`: Create new project
- `getProjects`: List user's projects with filters
- `getProjectById`: Get project details with populated data
- `updateProject`: Update project fields
- `addCollaborator`: Add team members with roles
- `addTask`: Create tasks within projects
- `createVersion`: Snapshot current state

**API Endpoints**:
```
POST   /api/projects              - Create project
GET    /api/projects              - List projects (?status=, ?type=)
GET    /api/projects/:id          - Get project details
PUT    /api/projects/:id          - Update project
POST   /api/projects/:id/collaborators - Add collaborator
POST   /api/projects/:id/tasks    - Add task
POST   /api/projects/:id/versions - Create version
```

**Example Usage**:
```javascript
// Create a video project
POST /api/projects
{
  "title": "Tutorial Series",
  "description": "Educational content",
  "type": "video",
  "dueDate": "2024-02-01T00:00:00.000Z",
  "tags": ["tutorial", "education"]
}

// Add a collaborator
POST /api/projects/:id/collaborators
{
  "userId": "user_id_here",
  "role": "editor"
}

// Create a version snapshot
POST /api/projects/:id/versions
{
  "name": "v1.0 - First Draft",
  "description": "Initial complete version"
}
```

### 2. Media Library

**Purpose**: Central repository for media assets (images, videos, audio, documents).

**Model**: `src/models/Media.js`
- Supports multiple media types
- Metadata storage (dimensions, duration, file size)
- Tag-based organization
- Public/private access control
- Project linking

**Controller**: `src/controllers/mediaController.js`
- `createMedia`: Upload media metadata
- `getMedia`: List media with search/filter
- `getMediaById`: Get media details
- `updateMedia`: Update metadata
- `deleteMedia`: Remove media

**API Endpoints**:
```
POST   /api/media                 - Create media entry
GET    /api/media                 - List media (?type=, ?search=)
GET    /api/media/:id             - Get media details
PUT    /api/media/:id             - Update media
DELETE /api/media/:id             - Delete media
```

**Note**: File upload integration is not implemented. Current implementation handles metadata only. To add file upload:
1. Install `multer` for file handling
2. Configure cloud storage (AWS S3, Cloudinary, etc.)
3. Add upload middleware to routes
4. Update controller to handle file processing

### 3. Templates Gallery

**Purpose**: Reusable templates for common creator workflows.

**Model**: `src/models/Template.js`
- Categorized templates (video, podcast, social, design, workflow)
- Flexible structure storage (JSON)
- Rating system with average/count
- Usage tracking
- Featured/official template flags

**Controller**: `src/controllers/templateController.js`
- `createTemplate`: Create new template
- `getTemplates`: Browse templates with filters
- `getTemplateById`: Get template details
- `useTemplate`: Increment usage counter
- `rateTemplate`: Submit rating (1-5 stars)

**API Endpoints**:
```
POST   /api/templates             - Create template
GET    /api/templates             - List templates (?category=, ?featured=, ?search=)
GET    /api/templates/:id         - Get template details
POST   /api/templates/:id/use     - Use template
POST   /api/templates/:id/rate    - Rate template
```

**Example Usage**:
```javascript
// Create a template
POST /api/templates
{
  "title": "YouTube Intro Template",
  "description": "Professional intro for YouTube",
  "category": "video",
  "structure": {
    "duration": 10,
    "layers": ["background", "text", "logo"]
  },
  "tags": ["youtube", "intro"]
}

// Rate a template
POST /api/templates/:id/rate
{
  "rating": 5
}
```

### 4. Notifications Center

**Purpose**: Keep users informed about activities, mentions, and deadlines.

**Model**: `src/models/Notification.js`
- Multiple notification types (mention, comment, like, deadline, invite, system)
- Read/unread status
- Snooze functionality
- Related entity linking

**Controller**: `src/controllers/notificationController.js`
- `getNotifications`: List notifications with filters
- `markAsRead`: Mark single notification as read
- `markAllAsRead`: Mark all as read
- `snoozeNotification`: Snooze for specified time
- `createNotification`: Helper for creating notifications (internal use)

**API Endpoints**:
```
GET    /api/notifications          - List notifications (?type=, ?unreadOnly=)
PUT    /api/notifications/:id/read - Mark as read
PUT    /api/notifications/read-all - Mark all as read
PUT    /api/notifications/:id/snooze - Snooze notification
```

**Creating Notifications**:
```javascript
// In your controller when an event occurs
const { createNotification } = require('./notificationController');

// Example: Notify when added as collaborator
await createNotification(
  userId,                    // recipient
  'invite',                  // type
  'Added to Project',        // title
  'You were added to Tutorial Series', // message
  {
    senderId: req.user._id,
    link: `/projects/${projectId}`,
    relatedModel: 'Project',
    relatedId: projectId
  }
);
```

## Extension Patterns

### Adding a New Feature

1. **Create the Model** (`src/models/YourFeature.js`):
```javascript
const mongoose = require('mongoose');

const yourFeatureSchema = new mongoose.Schema({
  title: { type: String, required: true },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  // ... other fields
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('YourFeature', yourFeatureSchema);
```

2. **Create the Controller** (`src/controllers/yourFeatureController.js`):
```javascript
const YourFeature = require('../models/YourFeature');

exports.create = async (req, res) => {
  try {
    const feature = new YourFeature({
      ...req.body,
      owner: req.user._id,
    });
    await feature.save();
    res.status(201).json({ feature });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// ... more CRUD operations
```

3. **Create the Routes** (`src/routes/yourFeature.js`):
```javascript
const express = require('express');
const router = express.Router();
const controller = require('../controllers/yourFeatureController');
const auth = require('../middleware/auth');

router.post('/', auth, controller.create);
router.get('/', auth, controller.list);
// ... more routes

module.exports = router;
```

4. **Register Routes** (in `src/app.js`):
```javascript
const yourFeatureRoutes = require('./routes/yourFeature');
app.use('/api/your-feature', yourFeatureRoutes);
```

### Adding Relationships

To link features together:

```javascript
// In your model
const schema = new mongoose.Schema({
  project: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Project'
  },
  media: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Media'
  }]
});

// In your controller
const item = await YourModel.findById(id)
  .populate('project', 'title description')
  .populate('media', 'title fileUrl');
```

### Adding Permissions

Follow the existing pattern in `projectController.js`:

```javascript
// Check if user owns the resource
if (!resource.owner.equals(req.user._id)) {
  return res.status(403).json({ message: 'Access denied' });
}

// Check if user has access (owner or collaborator)
const hasAccess = resource.owner.equals(req.user._id) ||
  resource.collaborators.some(c => c.user.equals(req.user._id));

if (!hasAccess) {
  return res.status(403).json({ message: 'Access denied' });
}

// Check role-based access
const isEditor = resource.collaborators.some(c => 
  c.user.equals(req.user._id) && ['admin', 'editor'].includes(c.role)
);
```

## Frontend Integration

### API Client Setup

```javascript
// Example API client
class CreatorOSAPI {
  constructor(baseURL, token) {
    this.baseURL = baseURL;
    this.token = token;
  }

  async request(endpoint, options = {}) {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.token}`,
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  }

  // Projects
  async createProject(data) {
    return this.request('/api/projects', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async getProjects(filters = {}) {
    const params = new URLSearchParams(filters);
    return this.request(`/api/projects?${params}`);
  }

  // Media
  async getMediaLibrary(filters = {}) {
    const params = new URLSearchParams(filters);
    return this.request(`/api/media?${params}`);
  }

  // Templates
  async getTemplates(filters = {}) {
    const params = new URLSearchParams(filters);
    return this.request(`/api/templates?${params}`);
  }

  // Notifications
  async getNotifications(filters = {}) {
    const params = new URLSearchParams(filters);
    return this.request(`/api/notifications?${params}`);
  }

  async markNotificationRead(id) {
    return this.request(`/api/notifications/${id}/read`, {
      method: 'PUT',
    });
  }
}

// Usage
const api = new CreatorOSAPI('http://localhost:3000', token);
const projects = await api.getProjects({ status: 'in-progress' });
```

### Building UI Components

Recommended structure for frontend:

```
public/
├── components/
│   ├── projects/
│   │   ├── ProjectList.js
│   │   ├── ProjectDetail.js
│   │   └── ProjectForm.js
│   ├── media/
│   │   ├── MediaLibrary.js
│   │   └── MediaGrid.js
│   ├── templates/
│   │   ├── TemplateGallery.js
│   │   └── TemplateCard.js
│   └── notifications/
│       └── NotificationCenter.js
├── app.js
└── index.html
```

## Database Considerations

### Indexes

Add indexes for frequently queried fields:

```javascript
// In your model file
schema.index({ owner: 1, createdAt: -1 });
schema.index({ tags: 1 });
schema.index({ 'collaborators.user': 1 });
```

### Pagination

Implement pagination for large datasets:

```javascript
exports.getProjects = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const projects = await Project.find(query)
    .skip(skip)
    .limit(limit)
    .sort({ updatedAt: -1 });

  const total = await Project.countDocuments(query);

  res.json({
    projects,
    page,
    totalPages: Math.ceil(total / limit),
    total,
  });
};
```

## Testing

### Writing Tests

Example test structure:

```javascript
// test/projects.test.js
const request = require('supertest');
const app = require('../src/app');

describe('Projects API', () => {
  let token;

  beforeAll(async () => {
    // Setup: Create user and get token
  });

  test('Create project', async () => {
    const response = await request(app)
      .post('/api/projects')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Test Project',
        description: 'Test',
        type: 'video',
      });

    expect(response.status).toBe(201);
    expect(response.body.project).toHaveProperty('_id');
  });

  test('Get projects', async () => {
    const response = await request(app)
      .get('/api/projects')
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body.projects)).toBe(true);
  });
});
```

## Best Practices

1. **Always validate user permissions** before allowing operations
2. **Use populate() wisely** - only populate fields you need
3. **Implement pagination** for list endpoints
4. **Add indexes** for frequently queried fields
5. **Handle errors consistently** - use try/catch and meaningful messages
6. **Validate input** - check required fields and data types
7. **Document your APIs** - keep API.md updated
8. **Test thoroughly** - write tests for new features
9. **Keep it minimal** - don't over-engineer solutions
10. **Follow existing patterns** - consistency is key

## Security Considerations

1. **Authentication**: All protected routes use JWT middleware
2. **Authorization**: Controllers check user permissions
3. **Input Validation**: Validate and sanitize user input
4. **Data Access**: Users can only access their own data or shared resources
5. **Rate Limiting**: Consider adding rate limiting for production
6. **CORS**: Configure CORS policies appropriately
7. **Environment Variables**: Keep secrets in .env, never commit them

## Performance Optimization

1. **Database**: Use indexes, lean queries, and select only needed fields
2. **Caching**: Consider Redis for frequently accessed data
3. **Pagination**: Always paginate large result sets
4. **Populate**: Use select to limit populated fields
5. **Aggregation**: Use MongoDB aggregation for complex queries

## Future Enhancements

See [ROADMAP.md](./ROADMAP.md) for planned features:
- Real-time notifications (WebSocket)
- File upload integration
- AI Assistants Hub
- Analytics Dashboard
- Scheduler/Calendar
- Integrations Marketplace
- Editor Shells

## Getting Help

- Review [API.md](./API.md) for API documentation
- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
- See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidelines
- Open issues on GitHub for bugs or feature requests

## Summary

This implementation provides a solid foundation for CreatorOS features:
- ✅ Consistent MVC architecture
- ✅ RESTful API design
- ✅ Role-based permissions
- ✅ Extensible patterns
- ✅ Production-ready structure

Follow the patterns established here to add new features and build upon this foundation.
