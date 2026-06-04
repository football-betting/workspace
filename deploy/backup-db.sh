#!/usr/bin/env bash
# Online backup of the shared SQLite DB. Uses `.backup`, which is safe while the
# services are running (WAL-aware, consistent snapshot). Keeps the newest N,
# gzipped. Intended to run daily from cron (see deploy/README.md).
set -euo pipefail

DB="${DB_PATH:-/opt/football-betting/shared/db/database.db}"
DIR="${BACKUP_DIR:-/opt/football-betting/backups}"
RETAIN="${RETAIN:-14}"

mkdir -p "$DIR"
ts="$(date +%Y%m%d-%H%M%S)"
out="$DIR/database-$ts.db"

sqlite3 "$DB" ".backup '$out'"
gzip -f "$out"

# Prune: keep only the newest $RETAIN snapshots.
ls -1t "$DIR"/database-*.db.gz 2>/dev/null | tail -n +"$((RETAIN + 1))" | xargs -r rm -f

echo "$(date -Is) backup ok: $out.gz ($(ls -1 "$DIR"/database-*.db.gz | wc -l) kept)"
