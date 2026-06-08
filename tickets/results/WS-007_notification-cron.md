# WS-007 — Result

## What was done
Stood up the tip-reminder cron end-to-end and verified both channels in
production. Generated `CRON_SECRET` on the server, added a wrapper script that
calls the endpoint (with the matching Origin/Host the middleware requires), and
installed a `*/10` crontab entry alongside the existing DB-backup cron.

Verified the server clock is UTC-correct and NTP-synced. Ran two controlled live
tests against user 1 (email + push, all five lead times): a single untipped
match (`sent:2`) and two matches at the same kickoff with one tipped
(`sent:6` — only the untipped match fired, across leads 360/720/1440 × both
channels). User confirmed the email and push arrived. All test rows removed.

## Files changed
### workspace
- `deploy/run-notifications.sh` (new) — cron runner.

### server (not in VCS)
- `/opt/football-betting/frontend/.env` — `CRON_SECRET`.
- root crontab — `*/10` notification job.

## Tests / quality gate
- Endpoint auth probes (401/200) and two delivery tests as above.
- Email + push delivery confirmed by the user.
