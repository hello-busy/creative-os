# Creative OS

A comprehensive creative platform combining web-based collaboration with Aurora OS - a next-generation microkernel operating system.

## Components

This repository contains two major components:

### 1. Hello - Creative Content Platform
A web-based platform for creative collaboration and competition with gamification features.

### 2. Aurora OS
A minimal L4-inspired microkernel with Swift UI integration for native macOS experience.

## Features

### 🌍 Public Feed
- Share creative content publicly with the entire community
- Like and comment on posts
- Real-time engagement tracking

### 🔒 Private Communities
- Create and manage private communities
- Control access to exclusive content
- Community-specific discussions and collaboration

### 🤝 Collaboration (Collab)
- Team-based creative challenges
- Shared content creation
- Collaborative achievements

### ⚔️ Competition (Compete)
- Individual and team competitions
- Leaderboards and rankings
- Performance tracking

### 🎮 Gamification System
- **Points System**: Earn points for activities
- **Level Progression**: 8 levels from beginner to expert
- **Badges**: Unlock achievements
  - First Post (10 pts)
  - Community Creator (50 pts)
  - Challenge Winner (100 pts)
  - Team Player (25 pts)
  - Competitor (25 pts)

## Tech Stack

- **Backend**: Node.js, Express
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT (JSON Web Tokens)
- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Containerization**: Docker, Docker Compose

## Quick Start

### Option 1: Web Platform (Hello)

#### Using Docker (Recommended)

1. Clone the repository
2. Run the application:
```bash
docker-compose up -d
```
3. Access the application at `http://localhost:3000`

#### Manual Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Update environment variables in `.env`:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/hello
JWT_SECRET=your-secret-key-change-in-production
```

4. Start MongoDB (if not using Docker)

5. Start the application:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

### Option 2: Aurora OS (Native macOS)

Aurora OS provides a minimal microkernel with Swift UI for demonstration and experimentation.

#### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 14+ with Command Line Tools
- CMake 3.15+
- Swift 5.7+

#### Build and Run Aurora OS

**Step 1: Build the C++ Kernel**

```bash
cd aurora
./build.sh
```

This creates:
- `build/lib/libaurora_kernel.a` - Static library
- `build/lib/libaurora_kernel.dylib` - Shared library
- `build/bin/aurora_kernel_test` - Test executable

**Step 2: Build the Swift UI**

```bash
cd ../aurora-ui
swift build
```

**Step 3: Run Aurora OS**

```bash
swift run
```

The Aurora UI will launch, allowing you to:
- Monitor kernel status (version, uptime, thread count)
- Create and destroy kernel threads
- Execute demo kernel calls
- See real-time kernel interaction

#### Testing Aurora Components

**Test C++ Kernel:**
```bash
cd aurora/build
./bin/aurora_kernel_test
```

**Test Swift UI:**
```bash
cd aurora-ui
swift test  # (when tests are added)
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Posts (Public Feed)
- `POST /api/posts` - Create a post
- `GET /api/posts/feed` - Get public feed
- `POST /api/posts/:id/like` - Like a post
- `POST /api/posts/:id/comment` - Comment on a post

### Communities
- `POST /api/communities` - Create community
- `GET /api/communities` - Get accessible communities
- `POST /api/communities/:id/join` - Join a community

### Challenges
- `POST /api/challenges` - Create challenge
- `GET /api/challenges` - Get challenges (filter by type/status)
- `POST /api/challenges/:id/join` - Join challenge
- `POST /api/challenges/:id/submit` - Submit challenge entry
- `GET /api/challenges/:id/leaderboard` - Get challenge leaderboard

## Architecture

```
hello/
├── src/
│   ├── config/         # Configuration files
│   │   └── database.js # Database connection
│   ├── controllers/    # Business logic
│   │   ├── authController.js
│   │   ├── communityController.js
│   │   ├── postController.js
│   │   └── challengeController.js
│   ├── middleware/     # Custom middleware
│   │   ├── auth.js     # Authentication
│   │   └── gamification.js # Gamification logic
│   ├── models/         # Data models
│   │   ├── User.js
│   │   ├── Community.js
│   │   ├── Post.js
│   │   └── Challenge.js
│   ├── routes/         # API routes
│   │   ├── auth.js
│   │   ├── communities.js
│   │   ├── posts.js
│   │   └── challenges.js
│   ├── app.js          # Express app
│   └── server.js       # Server entry point
├── public/             # Frontend files
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── Dockerfile          # Container definition
└── docker-compose.yml  # Multi-container setup
```

## Deployment

### Single Container Deployment

The application is designed to run as a single container with all necessary components:

```bash
docker build -t hello-platform .
docker run -p 3000:3000 hello-platform
```

For production with database:
```bash
docker-compose up -d
```

## Gamification Details

### Point Awards
- Create post: 5 points (10 for first post)
- Comment: 2 points
- Receive like: 2 points
- Join community: 10 points
- Create community: 50 points
- Join challenge: 10 points
- Submit challenge: 20 points
- Create challenge: 20 points

### Level Thresholds
- Level 1: 0-99 points
- Level 2: 100-249 points
- Level 3: 250-499 points
- Level 4: 500-999 points
- Level 5: 1000-1999 points
- Level 6: 2000-4999 points
- Level 7: 5000-9999 points
- Level 8: 10000+ points

## Development

### Running Tests
```bash
npm test
```

### Code Structure
- **Models**: Define data schemas and relationships
- **Controllers**: Handle business logic and data processing
- **Routes**: Define API endpoints and map to controllers
- **Middleware**: Handle cross-cutting concerns (auth, gamification)

## Aurora OS Architecture

Aurora OS is built on microkernel principles:

```
┌─────────────────────────────────────┐
│         Swift UI (macOS App)        │
│      (Aurora OS Control Panel)      │
└──────────────┬──────────────────────┘
               │ Swift-C Interop
               │ (AuroraBridge)
┌──────────────▼──────────────────────┐
│        C ABI Interface Layer        │
│         (aurora_abi.h)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      L4 Microkernel (C++)           │
│  • Thread Management                │
│  • IPC Primitives                   │
│  • Minimal Kernel State             │
└─────────────────────────────────────┘
```

### Key Features:
- **L4-inspired design**: Fast IPC and minimal kernel
- **Swift-C++ interop**: Native macOS UI calling C++ kernel
- **Thread management**: Create/destroy kernel threads
- **IPC messaging**: Inter-process communication primitives
- **Real-time monitoring**: Live kernel status updates

### Project Structure

```
creative-os/
├── aurora/                    # C++ Microkernel
│   ├── include/              
│   │   └── aurora_abi.h      # C API definitions
│   ├── src/
│   │   └── kernel/
│   │       └── l4_stub.cpp   # L4 microkernel implementation
│   ├── CMakeLists.txt        # Build configuration
│   ├── build.sh              # Build script
│   └── README.md             # Kernel documentation
│
├── aurora-ui/                # Swift UI Application
│   ├── Sources/
│   │   ├── AuroraBridge/     # C interop module
│   │   └── AuroraUI/         # SwiftUI views
│   ├── Package.swift         # Swift package manifest
│   └── README.md             # UI documentation
│
├── .github/
│   └── workflows/
│       └── ci.yml            # CI/CD for macOS builds
│
├── src/                      # Web platform backend
├── public/                   # Web platform frontend
└── README.md                 # This file
```

## Troubleshooting

### Common Aurora OS Build Errors

#### CMake not found
```bash
# Install via Homebrew
brew install cmake
```

#### "No such file or directory: aurora_abi.h"
The Swift build expects the kernel to be built first:
```bash
cd aurora && ./build.sh
```

#### "Library not loaded: libaurora_kernel.dylib"
The library path needs to be set. Try:
```bash
cd aurora-ui
swift build -c release
# Run with library path
DYLD_LIBRARY_PATH=../aurora/build/lib:$DYLD_LIBRARY_PATH .build/release/AuroraUI
```

Or use static linking by default (already configured in Package.swift).

#### Swift Package Build Fails
Ensure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

Verify Swift version:
```bash
swift --version  # Should be 5.7 or later
```

#### CI Build Failures
The CI workflow requires macOS runners. GitHub Actions provides these for public repositories. Check:
- Workflow file: `.github/workflows/ci.yml`
- Runner availability: https://github.com/YOUR_USERNAME/creative-os/actions

### Common Web Platform Issues

#### MongoDB Connection Failed
Ensure MongoDB is running:
```bash
# With Docker
docker-compose up -d mongo

# Or locally
brew services start mongodb-community
```

#### Port 3000 already in use
Change the port in `.env`:
```
PORT=3001
```

#### JWT Authentication Issues
Regenerate JWT secret in `.env`:
```
JWT_SECRET=$(openssl rand -base64 32)
```

## CI/CD Pipeline

Aurora OS includes GitHub Actions workflow for automated building and testing on macOS:

- **Build C++ Kernel**: Compiles kernel with CMake
- **Build Swift UI**: Builds SwiftUI app with Swift Package Manager
- **Integration Tests**: Verifies kernel-UI interop
- **Artifact Upload**: Saves builds for download

View build status: `.github/workflows/ci.yml`

## Contributing

### For Web Platform
1. Fork the repository
2. Create a feature branch for web features
3. Test with `npm test`
4. Submit a pull request

### For Aurora OS
1. Fork the repository
2. Create a feature branch for kernel/UI features
3. Build and test:
   ```bash
   cd aurora && ./build.sh && cd ../aurora-ui && swift build
   ```
4. Ensure CI passes
5. Submit a pull request

See `CONTRIBUTING.md` for detailed guidelines.

## License


