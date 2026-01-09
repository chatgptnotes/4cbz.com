// PM2 Ecosystem Configuration for aaPanel Deployment
// This file configures PM2 to manage the Node.js backend process

module.exports = {
  apps: [{
    name: '4cbz-backend',
    cwd: '/www/wwwroot/4cbz.com/4Cbitz_backend',
    script: 'index.js',
    instances: 1,
    exec_mode: 'cluster',

    // Environment variables
    env: {
      NODE_ENV: 'production',
      PORT: 5001
    },

    // Logging
    error_file: '/www/wwwroot/4cbz.com/logs/backend-error.log',
    out_file: '/www/wwwroot/4cbz.com/logs/backend-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,

    // Auto-restart settings
    watch: false,
    ignore_watch: ['node_modules', 'logs', '.git'],
    max_memory_restart: '500M',

    // Restart settings
    min_uptime: '10s',
    max_restarts: 10,
    autorestart: true,

    // Process management
    kill_timeout: 5000,
    listen_timeout: 3000,
    shutdown_with_message: false,

    // Advanced settings
    node_args: '--max-old-space-size=512'
  }]
};
