# Fisher-Mans-Node Development Guide

## Build & Run Commands
- Development: `docker compose up`
- Testing: `docker build --target test -t your-app:test .`
- Production build: `docker build --target production -t your-app:prod .`
- Run production: `docker run -p 3000:3000 your-app:prod`

## Code Style Guidelines
- **Indentation**: 4 spaces
- **Naming**: camelCase for variables/functions, PascalCase for classes
- **Imports**: CommonJS (require/module.exports)
- **Error handling**: Use try/catch for async operations
- **Environment**: Access via process.env with defaults (e.g., `process.env.PORT || 3000`)
- **String literals**: Use backticks for template strings
- **Async patterns**: Use Promise-based APIs

## Docker Best Practices
- Always use non-root user in containers (USER node)
- Implement proper signal handling with tini
- Add healthchecks to all services
- Use multi-stage builds for different environments
- Follow security best practices from README.md

## Environment Variables
- NODE_ENV: development/production
- PORT: Default 3000