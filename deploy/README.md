# Production deployment runbook

How the stack is deployed on the production server. Reproducible from scratch.
**No server IP and no secrets are recorded here on purpose** — secrets live only
in the per-repo, gitignored `.env` files on the server.

## Architecture

```
Browser ──HTTPS──> Cloudflare (wm.vcec.cloud) ──HTTPS:443──> nginx ──> Next.js (PM2, :3000)
                                                                          │
                                                       betting-api (systemd, :8080, release) 
                                                                          │
                                              shared SQLite (WAL)  /opt/football-betting/shared/db/database.db
```

- **frontend** (Next.js): runs under **PM2**, serves the app, reads/writes the
  shared SQLite DB, reads ratings from `betting-api`.
- **betting-api** (Rust): runs under **systemd** as a release binary in
  `MODE=production`, read-only on the shared DB.
- **macht-api**: deployed later (systemd timer importer) — see its `deploy/`.
- All three share one SQLite file in **WAL** mode (+ `busy_timeout=5000`).

## Layout

Everything under one root (`/opt/football-betting`), mirroring the local repo
layout (the `workspace` repo is the root; `frontend`/`betting-api` are cloned in
as gitignored subdirs):

```
/opt/football-betting/            # workspace repo (this repo)
├── frontend/                     # cloned separately
├── betting-api/                  # cloned separately
└── shared/db/database.db         # shared SQLite (created by the seed)
```

## 1. Provision the server (Ubuntu 24.04)

```bash
apt-get update
apt-get install -y build-essential pkg-config libssl-dev libsqlite3-dev \
                   sqlite3 nginx git curl ca-certificates
# Node 22 + pnpm + PM2
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
npm i -g pnpm@11 pm2          # pnpm 11 — the repo's pnpm-workspace.yaml uses allowBuilds
# Rust (needs >= 1.95 for the workspace)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
. "$HOME/.cargo/env"
```

`libsqlite3-dev` is required: `rusqlite` links the system SQLite (no `bundled`).

## 2. Clone the repos

```bash
git clone https://github.com/football-betting/workspace.git   /opt/football-betting
git clone https://github.com/football-betting/frontend.git    /opt/football-betting/frontend
git clone https://github.com/football-betting/betting-api.git /opt/football-betting/betting-api
mkdir -p /opt/football-betting/shared/db
```

## 3. Environment (uncommitted — `chmod 600`)

Create from each repo's `.env.example`. Use the **absolute** DB path so every
service opens the same file.

`frontend/.env` (key fields):
```
DATABASE_URL=/opt/football-betting/shared/db/database.db
RUST_API_URL=http://127.0.0.1:8080
APP_BASE_URL=https://wm.vcec.cloud        # REQUIRED in production
TRUST_PROXY=1                              # behind Cloudflare + nginx
TRUSTED_PROXY_HOPS=1
VAPID_SUBJECT=mailto:...                   # Web Push (npx web-push generate-vapid-keys)
VAPID_PRIVATE_KEY=...                       # secret
NEXT_PUBLIC_VAPID_PUBLIC_KEY=...            # must be set BEFORE the build
# SMTP_* and CRON_SECRET only when email reminders / the cron endpoint are used.
```

`betting-api/.env`:
```
MODE=production
DATABASE_URL=/opt/football-betting/shared/db/database.db
```

## 4. Seed the shared DB (demo data for the smoke test)

```bash
cd /opt/football-betting/frontend
DB=/opt/football-betting/shared/db/database.db
DATABASE_URL=$DB pnpm db:migrate
DATABASE_URL=$DB pnpm db:seed        # 8 users, 14 matches, 48 tips; password: test1234
```

## 5. betting-api (systemd, release)

```bash
cd /opt/football-betting/betting-api && . "$HOME/.cargo/env" && cargo build --release
cp deploy/betting-api.service /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now betting-api
curl -s http://127.0.0.1:8080/        # {"status":"works"}
```

## 6. frontend (build + PM2)

```bash
cd /opt/football-betting/frontend
pnpm install --frozen-lockfile
pnpm build                            # next build --webpack
pm2 start /opt/football-betting/deploy/pm2/ecosystem.config.cjs
pm2 save && pm2 startup systemd       # survive reboot
```

Process config: `deploy/pm2/ecosystem.config.cjs`. Logs: `pm2 logs wm-frontend`
or `/root/.pm2/logs/wm-frontend-{out,error}.log`. Redeploy:
`git pull && pnpm build && pm2 restart wm-frontend`.

## 7. nginx + Cloudflare

```bash
cp /opt/football-betting/deploy/nginx/wm.vcec.cloud.conf /etc/nginx/sites-available/wm.vcec.cloud
ln -sf /etc/nginx/sites-available/wm.vcec.cloud /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

The vhost (`deploy/nginx/wm.vcec.cloud.conf`) proxies `:80` and `:443` to the
frontend, restores the real client IP from Cloudflare (`CF-Connecting-IP`), and
returns `444` for any non-matching Host (origin stays Cloudflare-only).

**TLS / Cloudflare:** the domain is proxied through Cloudflare (DNS resolves to
Cloudflare IPs). Cloudflare's SSL/TLS mode must be **Full** so it connects to the
origin on `:443`. The origin currently uses a **self-signed** cert
(`/etc/ssl/certs/wm.vcec.cloud.crt`, key in `/etc/ssl/private/…`), which Full
accepts. For **Full (strict)**, replace it with a free **Cloudflare Origin
Certificate** (Dashboard → SSL/TLS → Origin Server → Create Certificate) and
point the `ssl_certificate*` directives at it. The browser always sees
Cloudflare's trusted edge certificate regardless.

## 8. Scheduled jobs / cron

- **betting-api**: long-running systemd service (boot-persistent).
- **frontend**: PM2 (`pm2 save` + `pm2 startup`) → boot-persistent.
- **macht-api** (later): oneshot importer triggered by a systemd **timer**
  (`macht-api.timer`, every minute) — see `macht-api/deploy/`.
- **tip reminders** (frontend, FE-059): an external scheduler calls
  `POST /api/cron/notifications` with `Authorization: Bearer $CRON_SECRET`.
  Not wired yet — enable by setting `CRON_SECRET` and adding the schedule here.

## Hardening follow-ups

- **XR-006**: run all DB-touching services as one shared user/group with
  `UMask=0002` so the WAL `-wal`/`-shm` files stay group-writable (currently
  everything runs as `root`, which is fine only because there is a single user).
- Restrict origin `:80/:443` to Cloudflare IP ranges via `ufw` once stable.
