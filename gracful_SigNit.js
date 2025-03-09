// Add this code to your main application file (e.g., server.js, app.js, index.js)
// It ensures your Node.js application properly handles Docker signals

// Handle SIGINT (Ctrl+C) - Docker stop sends this signal 
process.on('SIGINT', function onSigint() {
    console.info('SIGINT signal received. Graceful shutdown started at %s', new Date().toISOString());
    shutdown();
});

// Handle SIGTERM (Docker container stop) 
process.on('SIGTERM', function onSigterm() {
    console.info('SIGTERM signal received. Graceful shutdown started at %s', new Date().toISOString());
    shutdown();
});

// Implement shutdown logic
function shutdown() {
    // Set a timeout to handle the case when our cleanup takes too long
    const forcedShutdownTimeout = setTimeout(() => {
        console.error('Forced shutdown after timeout at %s', new Date().toISOString());
        process.exit(1);
    }, 30000); // 30 seconds timeout

    // Clear the timeout if we shut down properly
    forcedShutdownTimeout.unref();

    // Server shutdown 
    // For Express:
    server.close((err) => {
        if (err) {
            console.error('Error during server closing: %s', err.message);
            process.exit(1);
        }

        // Close database connections
        // For example, with Mongoose/MongoDB:
        // mongoose.connection.close();

        // For PostgreSQL with node-postgres:
        // pool.end();

        console.info('Graceful shutdown completed at %s', new Date().toISOString());
        process.exit(0);
    });
}