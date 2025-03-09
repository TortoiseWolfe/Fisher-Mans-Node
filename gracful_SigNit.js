// Basic Express server with graceful shutdown integration
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Add middleware
app.use(express.json());

// Simple route for health checks
app.get('/healthz', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

// Root route
app.get('/', (req, res) => {
    res.json({
        message: 'Node.js Docker Application',
        environment: process.env.NODE_ENV,
        timestamp: new Date().toISOString()
    });
});

// Start the server
const server = app.listen(PORT, () => {
    console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV} mode`);
});

// Import the graceful shutdown handler
require('./utils/graceful-shutdown');

// Export server for graceful shutdown
module.exports = { server };