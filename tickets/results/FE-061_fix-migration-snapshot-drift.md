# FE-061 Result — Drizzle-Snapshot-Drift behoben

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `d8f8d2a FE-061: repair 0001 drizzle snapshot to match schema (no spurious migrations) (#63)` (squash-merge PR #63)

## Was wurde gemacht
Der `0001`-Snapshot (`db/migrations/meta/0001_snapshot.json`) enthielt nur 8 der
9 Tabellen — es fehlte `password_reset_token` (Altlast aus FE-041). Folge: ein
künftiges `drizzle-kit generate` hätte eine fälschliche `CREATE TABLE
password_reset_token`-Migration erzeugt (Apply-Fehler, Tabelle existiert).

Fix: per `drizzle-kit generate` den autoritativen vollständigen Schema-Snapshot
erzeugt und dessen Inhalt in `0001_snapshot.json` übernommen (mit beibehaltener
`id`/`prevId`, damit die 0000→0001-Kette intakt bleibt); die temporären
0002-Artefakte + Journal-Eintrag wieder entfernt. Es wurde **keine** neue
Migrationsdatei eingeführt (Konvention).

## Verifikation
- `pnpm exec drizzle-kit generate` → **„No schema changes, nothing to migrate"**.
- Frische Migration gegen Temp-DB → **alle 9 Tabellen** (match, user, session,
  password_reset_token, tip, reminder_setting, reminder_sent, reminder_channel,
  push_subscription).
- `bash scripts/check.sh` → grün.

## Geänderte Dateien
- `frontend/db/migrations/meta/0001_snapshot.json` (einzige Änderung)

## Hinweis
Laufende DB + `db:reset`/Seed-Pfad unverändert (Apply nutzt die handgepflegte
Baseline-SQL, die schon korrekt war).
