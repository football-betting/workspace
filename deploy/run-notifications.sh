#!/usr/bin/env bash
# Fire the tip-reminder notification job. Meant to be run by cron every ~10 min.
#   */10 * * * * /opt/football-betting/deploy/run-notifications.sh >> /var/log/cron-notifications.log 2>&1
#
# The endpoint (POST /api/cron/notifications) is gated by CRON_SECRET, read here
# from the frontend .env so the secret never lands in crontab or the process
# list of another user. The app middleware also enforces a CSRF origin check on
# non-GET requests, so we present a matching Origin/Host for the local call.
set -euo pipefail

ENV="${FRONTEND_ENV:-/opt/football-betting/frontend/.env}"
APP_PORT="${APP_PORT:-3000}"
APP_HOST="${APP_HOST:-wm.vcec.cloud}"

SECRET="$(grep '^CRON_SECRET=' "$ENV" | cut -d= -f2-)"
if [ -z "$SECRET" ]; then
  echo "$(date -Is) CRON_SECRET missing in $ENV" >&2
  exit 1
fi

RESPONSE="$(curl -fsS -X POST "http://127.0.0.1:${APP_PORT}/api/cron/notifications" \
  -H "x-cron-secret: ${SECRET}" \
  -H "Origin: https://${APP_HOST}" \
  -H "Host: ${APP_HOST}")"

echo "$(date -Is) ${RESPONSE}"
