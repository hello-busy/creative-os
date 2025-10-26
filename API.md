# API Documentation

## Base URL
```
http://localhost:3000/api
```

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### Authentication

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "user": {
    "id": "user_id",
    "username": "johndoe",
    "email": "john@example.com",
    "points": 0,
    "level": 1
  },
  "token": "jwt_token"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "user": {
    "id": "user_id",
    "username": "johndoe",
    "email": "john@example.com",
    "points": 100,
    "level": 2,
    "badges": [
      {
        "name": "First Post",
        "earnedAt": "2024-01-01T00:00:00.000Z"
      }
    ]
  },
  "token": "jwt_token"
}
```

### Posts (Public Feed)

#### Create Post
```http
POST /api/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My Creative Work",
  "content": "This is my creative content...",
  "isPublic": true,
  "communityId": "optional_community_id"
}
```

**Gamification:** Awards 5 points (10 for first post + First Post badge)

#### Get Public Feed
```http
GET /api/posts/feed?page=1&limit=20
Authorization: Bearer <token>
```

**Response:**
```json
{
  "posts": [
    {
      "_id": "post_id",
      "title": "My Creative Work",
      "content": "Content here...",
      "author": {
        "username": "johndoe",
        "level": 2
      },
      "likes": ["user_id1", "user_id2"],
      "comments": [],
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "page": 1,
  "totalPages": 5,
  "total": 100
}
```

#### Like Post
```http
POST /api/posts/:id/like
Authorization: Bearer <token>
```

**Gamification:** Awards 2 points to post author

#### Add Comment
```http
POST /api/posts/:id/comment
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Great work!"
}
```

**Gamification:** Awards 2 points to commenter

### Communities

#### Create Community
```http
POST /api/communities
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Creative Writers",
  "description": "A community for writers",
  "isPrivate": true
}
```

**Gamification:** Awards 50 points + Community Creator badge

#### Get Communities
```http
GET /api/communities
Authorization: Bearer <token>
```

Returns communities that are either:
- Public (isPrivate: false)
- Or user is a member

#### Join Community
```http
POST /api/communities/:id/join
Authorization: Bearer <token>
```

**Gamification:** Awards 10 points

**Note:** Only works for public communities

### Challenges

#### Create Challenge
```http
POST /api/challenges
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Creative Writing Challenge",
  "description": "Write a short story in 500 words",
  "type": "compete",
  "points": 100,
  "startDate": "2024-01-15T00:00:00.000Z",
  "endDate": "2024-01-30T23:59:59.000Z"
}
```

**Types:**
- `compete`: Individual competition
- `collab`: Team collaboration

**Gamification:** Awards 20 points to creator

#### Get Challenges
```http
GET /api/challenges?type=compete&status=active
Authorization: Bearer <token>
```

**Query Parameters:**
- `type`: `compete` or `collab` (optional)
- `status`: `upcoming`, `active`, or `completed` (optional)

#### Join Challenge
```http
POST /api/challenges/:id/join
Authorization: Bearer <token>
```

**Gamification:** 
- Awards 10 points
- Awards Collaborator badge (for collab) or Competitor badge (for compete)

#### Submit Challenge Entry
```http
POST /api/challenges/:id/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "submission": "My submission content or URL"
}
```

**Gamification:** Awards 20 points

#### Get Leaderboard
```http
GET /api/challenges/:id/leaderboard
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "user": {
      "username": "johndoe",
      "level": 5,
      "points": 2500
    },
    "score": 950,
    "submission": "submission_content",
    "submittedAt": "2024-01-20T12:00:00.000Z"
  }
]
```

## Gamification System

### Points System

| Action | Points | Badge |
|--------|--------|-------|
| Register | 0 | - |
| Create post | 5 | First Post (first time: +10) |
| Comment | 2 | - |
| Receive like | 2 | - |
| Join community | 10 | - |
| Create community | 50 | Community Creator |
| Join challenge | 10 | Team Player / Competitor |
| Submit challenge | 20 | - |
| Create challenge | 20 | - |
| Win challenge | - | Challenge Winner (+100) |

### Level System

| Level | Points Required |
|-------|----------------|
| 1 | 0 |
| 2 | 100 |
| 3 | 250 |
| 4 | 500 |
| 5 | 1,000 |
| 6 | 2,000 |
| 7 | 5,000 |
| 8 | 10,000 |

### Badges

- **First Post**: Create your first post
- **Community Creator**: Create a community
- **Challenge Winner**: Win a challenge
- **Team Player**: Participate in a collaboration challenge
- **Competitor**: Participate in a competition challenge

## Error Responses

### 400 Bad Request
```json
{
  "error": "Error message describing what went wrong"
}
```

### 401 Unauthorized
```json
{
  "error": "Please authenticate"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Error message"
}
```

## Projects (CreatorOS Feature)

#### Create Project
```http
POST /api/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My Video Project",
  "description": "Creating a tutorial series",
  "type": "video",
  "dueDate": "2024-02-01T00:00:00.000Z",
  "tags": ["tutorial", "education"]
}
```

**Types:** `video`, `podcast`, `social`, `design`, `other`

#### Get Projects
```http
GET /api/projects?status=in-progress&type=video
Authorization: Bearer <token>
```

**Query Parameters:**
- `status`: `draft`, `in-progress`, `review`, `completed`, `archived`
- `type`: `video`, `podcast`, `social`, `design`, `other`

#### Get Project Details
```http
GET /api/projects/:id
Authorization: Bearer <token>
```

Returns project with tasks, versions, collaborators, and media.

#### Update Project
```http
PUT /api/projects/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "status": "in-progress",
  "dueDate": "2024-02-15T00:00:00.000Z"
}
```

#### Add Collaborator
```http
POST /api/projects/:id/collaborators
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "user_id",
  "role": "editor"
}
```

**Roles:** `viewer`, `editor`, `admin`

#### Add Task
```http
POST /api/projects/:id/tasks
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Edit intro sequence",
  "description": "Create 30-second intro",
  "assignedTo": "user_id",
  "dueDate": "2024-01-25T00:00:00.000Z"
}
```

#### Create Version
```http
POST /api/projects/:id/versions
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "v1.0 - Initial Draft",
  "description": "First complete draft"
}
```

## Media Library (CreatorOS Feature)

#### Upload Media
```http
POST /api/media
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Background Music",
  "description": "Royalty-free track",
  "type": "audio",
  "fileUrl": "https://example.com/file.mp3",
  "fileSize": 5242880,
  "mimeType": "audio/mpeg",
  "tags": ["music", "background"],
  "isPublic": false
}
```

**Types:** `image`, `video`, `audio`, `document`

**Note:** This endpoint accepts metadata. File upload integration (multer/cloud storage) needs to be implemented.

#### Get Media Library
```http
GET /api/media?type=video&search=intro
Authorization: Bearer <token>
```

**Query Parameters:**
- `type`: `image`, `video`, `audio`, `document`
- `search`: Search in title and tags

#### Get Media Details
```http
GET /api/media/:id
Authorization: Bearer <token>
```

#### Update Media
```http
PUT /api/media/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "tags": ["new", "tags"],
  "isPublic": true
}
```

#### Delete Media
```http
DELETE /api/media/:id
Authorization: Bearer <token>
```

## Templates Gallery (CreatorOS Feature)

#### Create Template
```http
POST /api/templates
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "YouTube Intro Template",
  "description": "Professional intro for YouTube videos",
  "category": "video",
  "thumbnail": "https://example.com/thumb.jpg",
  "structure": {
    "duration": 10,
    "layers": ["background", "text", "logo"]
  },
  "tags": ["youtube", "intro"]
}
```

**Categories:** `video`, `podcast`, `social`, `design`, `workflow`

#### Get Templates
```http
GET /api/templates?category=video&featured=true&search=intro
Authorization: Bearer <token>
```

**Query Parameters:**
- `category`: Template category
- `featured`: `true` to get featured templates only
- `search`: Search in title and tags

#### Get Template Details
```http
GET /api/templates/:id
Authorization: Bearer <token>
```

#### Use Template
```http
POST /api/templates/:id/use
Authorization: Bearer <token>
```

Increments usage counter for popularity tracking.

#### Rate Template
```http
POST /api/templates/:id/rate
Authorization: Bearer <token>
Content-Type: application/json

{
  "rating": 5
}
```

**Rating:** 1-5 stars

## Notifications (CreatorOS Feature)

#### Get Notifications
```http
GET /api/notifications?type=mention&unreadOnly=true
Authorization: Bearer <token>
```

**Query Parameters:**
- `type`: `mention`, `comment`, `like`, `deadline`, `invite`, `system`
- `unreadOnly`: `true` to get only unread notifications

#### Mark as Read
```http
PUT /api/notifications/:id/read
Authorization: Bearer <token>
```

#### Mark All as Read
```http
PUT /api/notifications/read-all
Authorization: Bearer <token>
```

#### Snooze Notification
```http
PUT /api/notifications/:id/snooze
Authorization: Bearer <token>
Content-Type: application/json

{
  "minutes": 30
}
```

Snoozes notification for specified minutes.

## Rate Limiting

Currently no rate limiting is implemented. Consider adding rate limiting middleware for production use.

## Best Practices

1. Always include proper error handling
2. Store JWT tokens securely (not in localStorage in production)
3. Validate all user input
4. Use HTTPS in production
5. Set strong JWT secrets
6. Implement proper CORS policies
7. Add rate limiting for production
8. Monitor and log API usage

## CreatorOS Roadmap

For the complete feature roadmap and implementation status, see [ROADMAP.md](./ROADMAP.md).
