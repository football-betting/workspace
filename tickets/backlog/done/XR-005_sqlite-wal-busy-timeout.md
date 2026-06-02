# XR-005 SQLite-Concurrency: WAL + busy_timeout in allen Services

## Repo
frontend, betting-api, macht-api (cross-repo)
## Type
bug
## Risk
medium
## Priority
high
> User (2026-06-02): macht-api schreibt in die geteilte DB — das darf nicht zu Fehlern führen (SQLITE_BUSY).

## Status
in-progress
## Owner
implementer

## Background
Die drei Services teilen `shared/db/database.db`. Aktuell:
- frontend (`lib/db.ts`): `journal_mode=WAL` gesetzt, **kein** `busy_timeout`.
- betting-api (`establish_connection`): weder WAL noch busy_timeout.
- macht-api (`get_connection`): weder WAL noch busy_timeout.
→ Gleichzeitige Zugriffe (macht-api schreibt im Minutentakt, frontend schreibt
Tipps/Sessions/Reminder) können `SQLITE_BUSY` werfen.

## Fix
Auf **jeder** Verbindung setzen:
- `PRAGMA busy_timeout = 5000` (Writer wartet bis 5 s auf den Lock statt sofort zu failen).
- `PRAGMA journal_mode = WAL` (Leser blockieren nicht; ein Writer; persistiert).
- frontend: zusätzlich `busy_timeout` (WAL ist schon da).
- Rust (betting-api/macht-api): Pragmas nach `Connection::open` setzen, ohne neue
  `.unwrap()` auf Prod-Pfad (Fehler sauber behandeln/propagieren wie BA-004/MA-004).

## Acceptance Criteria
- [ ] Alle drei Services setzen `busy_timeout`; Rust zusätzlich WAL.
- [ ] Gleichzeitiges Schreiben (macht-api) blockiert/fehlerfrei statt SQLITE_BUSY.
- [ ] frontend `bash scripts/check.sh`; betting-api/macht-api `cargo clippy -D warnings` + `cargo test` grün.
- [ ] Kein neues `.unwrap()` auf Rust-Prod-Pfad.

## Hinweis (separat)
Der gemeldete Turbopack-Crash (`.next/dev/cache/turbopack/*.sst`) ist Next.js-
Dev-Cache-Korruption, **nicht** die DB — Fix: `.next` löschen, `pnpm dev` neu.
