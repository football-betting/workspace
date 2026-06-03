# WS-002 Result — Production deployment (frontend + betting-api)

## What was done

Brought the stack live on the production server behind `https://wm.vcec.cloud`
(Cloudflare in front), deployed by pulling the public repos onto the server and
configuring them there. Validated end-to-end with demo data. `macht-api` is left
for a later step (out of scope here).

- **Server provisioning** (Ubuntu 24.04): build deps + `libsqlite3-dev`, Node 22
  + pnpm 11 + PM2, Rust via rustup (1.96), nginx.
- **Layout**: single root `/opt/football-betting` (workspace repo) with
  `frontend/` + `betting-api/` cloned in and `shared/db/database.db` alongside.
- **Shared DB** seeded with demo data (8 users, 14 matches, 48 tips; WAL).
- **betting-api**: `cargo build --release`, systemd service in `MODE=production`,
  reads the shared DB reliably (WAL + busy_timeout). `GET /rating` / `/user/1`
  return real computed data.
- **frontend**: built (`next build --webpack`), run under PM2 (`pm2 save` +
  `pm2 startup` for boot persistence). Real demo login returns `auth_session`
  (DB read + write + Argon2 verify all working on the shared WAL DB).
- **nginx**: reverse proxy for `wm.vcec.cloud` on `:80` and `:443`, Cloudflare
  real-client-IP restore (`CF-Connecting-IP`), `444` for non-matching Host
  (origin stays Cloudflare-only). Origin TLS on `:443` (self-signed) so
  Cloudflare's **Full** mode connects successfully — this resolved an initial
  `521` (Cloudflare was reaching for `:443` while nginx only had `:80`).
- **Security**: the server IP appears in **no** committed file; `.env` files
  (DB path, VAPID private key) stay uncommitted (`chmod 600`) on the server.

## Files changed (workspace repo)

- `deploy/nginx/wm.vcec.cloud.conf` — the production nginx vhost (no IP/secret).
- `deploy/README.md` — full, reproducible deployment runbook (provisioning →
  clone → env → seed → systemd → PM2 → nginx/Cloudflare → cron → hardening).
- `tickets/backlog/.../WS-002_*.md` — ticket lifecycle; this result doc.

No application code changed. `betting-api`/`frontend` were deployed at their
current `main`.

## Verification

- `systemctl is-active betting-api` → active; `GET :8080/` → `{"status":"works"}`,
  `/rating` + `/user/1` return seeded data.
- `pm2 status` → `wm-frontend` online; `:3000/login` → 200; demo login → 200 +
  `set-cookie: auth_session=…`.
- `https://wm.vcec.cloud/login` → 200 (via Cloudflare); full login over the
  public domain → `HTTP/2 200` + `auth_session` (cf-ray present).
- Origin returns `444` for a non-matching Host.
- `git grep` for the server IP in `workspace` → no matches.

## Follow-ups (separate tickets)

- **XR-006**: WAL file permissions — run DB-touching services as one shared
  user/group with `UMask=0002` (currently all run as `root`).
- macht-api deployment (systemd timer importer).
- Optional: Cloudflare **Full (strict)** with a Cloudflare Origin Certificate;
  restrict origin ports to Cloudflare IP ranges via `ufw`.
