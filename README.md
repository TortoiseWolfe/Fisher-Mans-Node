# Fisher-Man's-Node

A robust Docker environment for Node.js applications, inspired by Bret Fisher's "Docker Mastery for Node.js Projects" course.

## Features

- Multi-stage Docker builds for development, testing, and production
- Automatic cloning of Node.js repositories during build
- Proper signal handling with tini and graceful shutdown
- Optimized layer caching and dependency management
- Security best practices (non-root user, security scanning options)
- Docker Compose setup with PostgreSQL database
- Health checks for all services

## Getting Started

### Prerequisites

- Docker
- Docker Compose

No local Node.js installation needed! Everything runs in containers.

### Quick Start

1. Clone this repository:
```bash
git clone https://github.com/yourusername/Fisher-Mans-Node.git
cd Fisher-Mans-Node
```

2. Start the development environment:
```bash
docker compose up
```

This will:
- Build the Docker image using the development target
- Clone the default Node.js sample application
- Start the PostgreSQL database
- Start the application with hot-reloading enabled

3. Access your application at http://localhost:3000

### Building with a Custom Repository

You can build the image with your own Node.js repository:

```bash
docker build --target development \
  --build-arg GIT_REPO=https://github.com/yourusername/your-repo.git \
  --build-arg GIT_BRANCH=main \
  -t your-app:dev .
```

Or modify the `docker-compose.yml` file to use your repository:

```yaml
services:
  app:
    build:
      args:
        - GIT_REPO=https://github.com/yourusername/your-repo.git
        - GIT_BRANCH=main
```

## Development Workflow

- Source code is mounted as a volume for live reloading
- Node modules are stored in a Docker volume for performance
- Changes to your code will automatically restart the application (via nodemon)
- Database data persists between restarts

## Production Deployment

Build a production-ready image:

```bash
docker build --target production -t your-app:prod .
```

Run the production image:

```bash
docker run -p 3000:3000 your-app:prod
```

## Testing

Build and run the test stage:

```bash
docker build --target test -t your-app:test .
```

## Environment Variables

- `NODE_ENV`: Set to `development` or `production`
- `PORT`: The port the application listens on (default: 3000)
- Database credentials are set in `docker-compose.yml`

## Security Features

- Non-root user for running the application
- Tini as init system for proper signal handling
- Graceful shutdown support
- Option to integrate Trivy scanner for vulnerability scanning

## License

MIT