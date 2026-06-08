# WS-007 Tip-reminder notification cron

## Repo
workspace (+ server ops)

## Type
infra

## Risk
medium

## Background
The tip-reminder endpoint (`POST /api/cron/notifications`) existed but nothing
called it on a schedule, and `CRON_SECRET` was unset, so no reminders were ever
delivered. Set up the recurring job and verify email + push end-to-end.

## What changed
- Server `.env`: added `CRON_SECRET` (64-hex, chmod 600), restarted frontend.
- `deploy/run-notifications.sh`: wrapper that reads the secret from `.env` and
  POSTs the endpoint. The app middleware enforces a CSRF origin check on non-GET
  requests, so the wrapper presents a matching `Origin`/`Host` for the local
  call.
- Crontab: `*/10 * * * * .../run-notifications.sh` (backup cron preserved).

## Verification
- Auth: no/!wrong secret → 401; matching Origin + secret → 200.
- Server clock: UTC correct, NTP synchronized (no timezone drift).
- Live test (user 1, all 5 leads, email + push): a single-match trigger returned
  `{"sent":2}`; a two-matches-same-kickoff trigger with one match tipped returned
  `{"sent":6}` (only the untipped match, leads 360/720/1440 × email+push). User
  confirmed receipt of email + push. Test data removed afterwards.
