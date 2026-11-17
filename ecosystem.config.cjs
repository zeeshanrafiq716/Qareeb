module.exports = {
  apps: [
    {
      name: "zesho-backend",
      script: "src/index.js",
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      max_memory_restart: "500M",
      env: {
        NODE_ENV: "production",
        PORT: 3000,
      },
    },
  ],
};

