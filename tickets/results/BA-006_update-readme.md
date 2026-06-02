# BA-006 — Update betting-api README — Result

## What was done
Rewrote `betting-api/README.md`:
- Retitled from "EM2024 Backend API" to betting-api, described as the read-only
  Actix API for the football-prediction game.
- Added an Architecture section (shared SQLite at `../shared/db/database.db`,
  schema owned by the frontend, no writes from this service).
- Replaced the inaccurate `.env.example` setup with the real env vars
  (`DATABASE_URL`, `MODE`) and run/test instructions.
- Kept the existing endpoint and object reference (UserInfo, Tip, Team,
  `/rating`, `/user/{id}`, `/game/{id}`, `/`).

## Files changed
- `README.md`

Delivered via PR football-betting/betting-api#9 (squash-merged into `main`).

## Test results
CI green (fmt · clippy · test · coverage, ~2m9s) on the PR.
