# FE-061 Drizzle-Snapshot-Drift bereinigen (0001 fehlt password_reset_token)

## Repo
frontend

## Type
chore

## Risk
low

## Priority
low

> Tech-Debt, entdeckt im FE-059-Review.

## Status
todo

## Owner
implementer

## Background
`db/migrations/meta/0001_snapshot.json` enthält `password_reset_token` **nicht**
(Altlast aus FE-041, das die Tabelle in die 0000-Baseline gefaltet hat, den
0001-Snapshot aber nicht nachzog). Folge: ein künftiges `drizzle-kit generate`
erzeugt ein fälschliches `CREATE TABLE password_reset_token` (würde beim Apply
brechen, da 0000 sie schon anlegt). FE-059 hat die Reminder-Tabellen in 0001
ergänzt, den Drift aber nicht behoben.

## Scope
- **In scope**: `meta/0001_snapshot.json` so regenerieren/ergänzen, dass es den
  tatsächlichen Schema-Stand (inkl. `password_reset_token`, `reminder_setting`,
  `reminder_sent`) widerspiegelt; `drizzle-kit generate` danach erzeugt **keine**
  fälschliche Migration mehr. `db:reset`-Pfad muss unverändert grün bleiben.
- **Out of scope**: Schema-Änderungen; neue Migrationsdateien-Konvention ändern.

## Acceptance Criteria
- [ ] `drizzle-kit generate` erzeugt nach dem Fix **keine** Spuk-Migration
      (Snapshot == Schema).
- [ ] `pnpm db:reset` legt alle Tabellen korrekt an (frische DB).
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. `pnpm exec drizzle-kit generate` → „No schema changes" (keine neue Datei).
2. `pnpm db:reset` → alle Tabellen vorhanden.
