# XR-005 Result — SQLite-Concurrency: WAL + busy_timeout
**Geschlossen**: 2026-06-02
**Commits**: frontend `b0a7b82 (#76)` · betting-api `7fd21bf (#6)` · macht-api `528b298 (#5)`

## Was wurde gemacht
Alle drei Services setzen jetzt auf der geteilten SQLite-Datei
`PRAGMA busy_timeout = 5000` (Writer/Reader warten bis 5 s auf den Lock statt
sofort mit `SQLITE_BUSY` zu failen) und WAL:
- **frontend** (`lib/db.ts`): `busy_timeout` ergänzt (WAL war schon gesetzt).
- **betting-api** (`establish_connection`, Prod-Zweig): `busy_timeout` + WAL via
  `query_row("PRAGMA journal_mode=WAL")`, `?`-propagiert (kein unwrap).
- **macht-api** (`get_connection`): `busy_timeout` + WAL, Fehler geloggt + `None`
  (MA-004-Stil, kein unwrap auf Prod-Pfad).

→ macht-apis Minuten-Importe kollidieren nicht mehr fehlerhaft mit Frontend-/
Read-Zugriffen.

## Gate
- frontend `check.sh` grün; betting-api clippy + 39 Tests; macht-api clippy + 5 Tests.

## Separat (kein Code)
Der gemeldete Turbopack-Crash war Next.js-Dev-Cache-Korruption
(`.next/dev/cache/turbopack/*.sst`), **nicht** die DB — Fix: `.next` löschen,
`pnpm dev` neu (nie zwei Dev-Server parallel).
