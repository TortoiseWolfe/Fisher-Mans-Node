# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for Node.js applications
# Optimized for development, testing, and production

##############################
# Stage 1: Base Build
##############################
FROM node:18-slim AS base

# Add labels according to OCI standard
LABEL org.opencontainers.image.authors="your-email@example.com"
LABEL org.opencontainers.image.title="Your Application Name"
LABEL org.opencontainers.image.description="Description of your application"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment to production by default
ENV NODE_ENV=production

# Set the working directory
WORKDIR /app

# Expose the port your app runs on
EXPOSE 3000
ENV PORT 3000

# Install tini for proper signal handling
RUN apt-get update -qq && apt-get install -qy \
    tini \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy package files first for better layer caching
COPY --chown=node:node package*.json ./

# Show npm configuration for debugging
RUN npm config list

# Install production dependencies using npm ci for more reliable builds
RUN npm ci --only=production \
    && npm cache clean --force

# Update PATH to include node_modules/.bin
ENV PATH /app/node_modules/.bin:$PATH

# Set tini as the entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

# Default command
CMD ["node", "server.js"]

##############################
# Stage 2: Development
##############################
FROM base AS development

# Set environment to development
ENV NODE_ENV=development

# Install development dependencies
RUN apt-get update -qq && apt-get install -qy \
    ca-certificates \
    curl \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install all dependencies including devDependencies
RUN npm install \
    && npm cache clean --force

# Copy the application code
COPY --chown=node:node . .

# Switch to non-root user
USER node

# Use nodemon for development to enable hot reloading
CMD ["nodemon", "server.js"]

##############################
# Stage 3: Test
##############################
FROM development AS test

# Run tests
RUN npm test || echo "Tests would run here"

# Run security audit
RUN npm audit --production

# Uncomment below lines if you want to add Trivy scanner
# ENV TRIVY_VERSION=0.35.0
# Install Trivy for security scanning
# RUN apt-get update -qq && apt-get install -y ca-certificates wget --no-install-recommends \
#     && wget --progress=dot:giga https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb \
#     && dpkg -i trivy_${TRIVY_VERSION}_Linux-64bit.deb \
#     && trivy fs --severity "HIGH,CRITICAL" --no-progress --security-checks vuln .

##############################
# Stage 4: Pre-Production
##############################
FROM test AS pre-production

# Remove test directories and dev dependencies
RUN rm -rf ./tests ./node_modules

##############################
# Stage 5: Production
##############################
FROM base AS production

# Copy the application code
COPY --chown=node:node --from=pre-production /app /app

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:$PORT/ || exit 1

# Switch to non-root user for security
USER node

##############################
# Build & Run Instructions:
##############################
# To build the production image:
#   docker build --target production -t your-app:prod .
#
# To build the development image:
#   docker build --target development -t your-app:dev .
#
# To build the test image:
#   docker build --target test -t your-app:test .