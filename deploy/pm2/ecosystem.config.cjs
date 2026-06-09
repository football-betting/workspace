// PM2 process config for the Next.js frontend (production).
//
//   pm2 start /opt/football-betting/deploy/pm2/ecosystem.config.cjs
//   pm2 save            # persist the process list across reboots
//   pm2 startup systemd # generate the boot service (run once)
//
// Runtime env (DATABASE_URL, RUST_API_URL, VAPID keys, …) is loaded by
// `next start` from frontend/.env (uncommitted — never committed).
//
// Logs:
//   pm2 logs wm-frontend
//   /root/.pm2/logs/wm-frontend-out.log
//   /root/.pm2/logs/wm-frontend-error.log
module.exports = {
  apps: [
    {
      name: "wm-frontend",
      cwd: "/opt/football-betting/frontend",
      script: "pnpm",
      // Bind to loopback only — nginx proxies to 127.0.0.1:3000, so the app is
      // never reachable on the public IP:3000 (which would bypass Cloudflare).
      // Use `pnpm exec next start -H …`: `pnpm start -- -H …` makes next-start
      // treat `-H` as the project dir and crash-loops on every (re)start.
      args: "exec next start -H 127.0.0.1",
      autorestart: true,
      max_memory_restart: "600M",
    },
  ],
};
