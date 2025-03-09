# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for Node.js applications
# Optimized for development, testing, and production

##############################
# Stage 1: Base Build
##############################
FROM node:18-slim AS base

# Add labels according to OCI standard
LABEL org.opencontainers.image.authors="your-email@example.com"
LABEL org.opencontainers.image.title="Simple Express App"
LABEL org.opencontainers.image.description="Simple Express application for Docker testing"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment to production by default
ENV NODE_ENV=production

# Set the working directory
WORKDIR /app

# Expose the port your app runs on
EXPOSE 3000
ENV PORT 3000

# Install tini for proper signal handling and CA certificates for git
RUN apt-get update -qq && apt-get install -qy \
    tini \
    git \
    curl \
    ca-certificates \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create a simple Express app directly
RUN echo 'const express = require("express");\n\
    const app = express();\n\
    const port = process.env.PORT || 3000;\n\
    \n\
    app.get("/", (req, res) => {\n\
    res.send("<h1>Hello from Docker!</h1><p>The time is: " + new Date().toISOString() + "</p>");\n\
    });\n\
    \n\
    app.listen(port, () => {\n\
    console.log(`Express app listening at http://localhost:${port}`);\n\
    });' > /app/index.js

# Create a package.json file
RUN echo '{"name":"hello-world","description":"hello world app","version":"0.0.1","private":true,"dependencies":{"express":"4.x"},"scripts":{"start":"node index.js"}}' > /app/package.json

# Set tini as the entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

# Install production dependencies
RUN npm install --production && \
    npm cache clean --force

# Default command
CMD ["node", "index.js"]

##############################
# Stage 2: Development
##############################
FROM base AS development

# Set environment to development
ENV NODE_ENV=development

# Install nodemon for development
RUN npm install -g nodemon && \
    npm cache clean --force

# Update PATH to include node_modules/.bin
ENV PATH /app/node_modules/.bin:$PATH

# Switch to non-root user
USER node

# Use nodemon for development to enable hot reloading
CMD ["nodemon", "index.js"]

##############################
# Stage 3: Test
##############################
FROM development AS test

# Simple test example
RUN echo "console.log('Tests would run here');" > test.js && \
    node test.js

# Run security audit
RUN npm audit --production || true

##############################
# Stage 4: Production
##############################
FROM base AS production

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

# Switch to non-root user for security
USER node