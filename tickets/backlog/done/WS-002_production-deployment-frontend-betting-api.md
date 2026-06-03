# WS-002 Production deployment: frontend (PM2 + nginx) + betting-api (systemd)

## Repo
workspace

> Deploys `frontend` + `betting-api`; the committed artifacts (nginx config,
> deploy notes, cron) live in `workspace`. `macht-api` is deployed later.

## Type
chore

## Risk
medium

## Priority
high

## Background
The app must run on the production server behind the domain `wm.vcec.cloud`
(Cloudflare in front). Because the GitHub repos are public, we deploy by pulling
the repos directly on the server and configuring them there, rather than a
push-from-CI flow. All persistent deploy artifacts (nginx site config, any
cron/systemd snippets, deploy docs) are kept in the `workspace` repo so the setup
is reproducible and documented for the future.

The frontend (Next.js) runs under PM2; `betting-api` runs as a release-mode
systemd service for best performance. Both share the SQLite database, so the
connection must stay reliable while the file changes (WAL + busy_timeout are
already in the code). First we validate the stack end-to-end with demo data.

## Scope
- **In scope**:
  - Provision the server (Node + pnpm + PM2, Rust toolchain, nginx).
  - Clone `workspace`, `frontend`, `betting-api` on the server.
  - Shared SQLite DB seeded with demo data for an initial smoke test.
  - `betting-api`: `cargo build --release`, run via systemd in production mode
    (`MODE=production`), reliable SQLite connection (WAL + busy_timeout).
  - `frontend`: build, run via PM2.
  - nginx reverse proxy for `wm.vcec.cloud` → frontend; Cloudflare in front.
  - Commit the **sanitized** nginx config + deploy docs (and any cron) into
    `workspace` (e.g. `deploy/`), **without** the server IP or any secret.
- **Out of scope (explicit)**:
  - `macht-api` deployment (separate, later).
  - TLS origin certs / Cloudflare config beyond the nginx vhost.
  - The shared-user/UMask hardening tracked in **XR-006** (the WAL file
    permissions ticket) — for the demo phase the writer + reader run as the same
    OS user so writes succeed; XR-006 hardens this to a dedicated account.

## References
- `betting-api/deploy/betting-api.service`, `betting-api/deploy/README.md`
- `betting-api/src/db/mod.rs` (MODE/production, WAL + busy_timeout)
- `frontend/lib/db.ts`, `frontend/scripts/demo_data.ts`
- `docs/TECH_ARCHITEKTUR.md`, `docs/FRONTEND_FUNKTIONS_SPEC.md`

## Acceptance Criteria
- [ ] `betting-api` runs as a systemd service from the **release** binary in
      `MODE=production`, reading the shared DB; `systemctl status` active;
      survives the SQLite file being rewritten (reads keep working).
- [ ] frontend runs under PM2 and serves the app; it reads ratings from
      `betting-api` and reads/writes the shared SQLite DB.
- [ ] `https://wm.vcec.cloud` serves the app through nginx (via Cloudflare); a
      demo user can log in and the dashboard renders.
- [ ] The nginx site config + deploy docs are committed to `workspace`
      **with no server IP and no secrets**; `.env` files are not committed.
- [ ] Server IP `45.90.x.x` appears in **no** committed file (grep-clean).

## Verification (manual)
1. `systemctl status betting-api` → active (running), release binary path.
2. `pm2 status` → frontend online.
3. `curl -H 'Host: wm.vcec.cloud' http://localhost/` (and via the public domain)
   → app HTML, 200.
4. Log in as a seeded demo user → dashboard + ranking render (ratings come from
   `betting-api`).
5. `git grep` in `workspace` for the server IP → no matches.

## Notes (multi-repo only)
Deploy order:
1. Provision base tooling (Node/pnpm/PM2, Rust via rustup, nginx).
2. Clone repos under a single deploy root; create shared DB dir + seed demo data.
3. betting-api: build release → systemd unit (production) → verify.
4. frontend: env (uncommitted) → build → PM2 → verify.
5. nginx vhost for `wm.vcec.cloud` → verify through Cloudflare.
6. Commit sanitized nginx/deploy artifacts to `workspace/deploy`.

Server access (IP, root SSH) is intentionally **not** recorded here — kept out
of the repo on purpose.
