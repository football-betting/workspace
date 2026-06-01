# BA-004 betting-api: Panic-/DoS-Härtung (unwrap entfernen)

## Repo
betting-api

## Type
bug

## Risk
high

## Priority
high

> Security-Audit 2026-06-01 (HIGH). Erreichbare DoS über reguläre Upstream-Daten.

## Status
todo

## Owner
implementer

## Background
Mehrere `.unwrap()` auf erreichbaren Request-Pfaden → 500-DoS der gesamten
Read-API (`/rating`, `/user/{id}`, `/game/{id}`).

## Findings (Audit)
1. **Team-JSON-Parse-Panic** (`src/service/mod.rs:88-89`, HIGH):
   `serde_json::from_str(&game.home_team).unwrap()`. Das `match`-Team-JSON kommt
   von macht-api (externe API). betting-api `Team` hat **required** `name/tla`,
   macht-api-`Team` **optional** → null/fehlende Felder (Platzhalter-Teams,
   „Winner of QF1") lassen jeden Read-Call panicken. Persistenter 500 bis die
   Zeile manuell gefixt wird.
2. **Handler-`unwrap()`-Ketten** (`src/routes.rs:32,70,93`, HIGH):
   `get_users().unwrap()` / `get_user_rating(...).unwrap()`. DB-Lock (`SQLITE_BUSY`
   durch geteilte SQLite-Datei mit frontend/macht-api) → 500 auf allen Endpoints.
3. **Keine Body-Limit/Rate-Limit/Timeouts, kein Caching** (`src/main.rs:9-18`,
   MEDIUM): `/rating` baut pro Request O(users×games) im Speicher, neue
   DB-Connection + Full-Scan je Call (`db/mod.rs:36`) → Resource-Exhaustion.

## Scope
- **In scope**:
  - `Team`-Felder `Option<String>` ODER Parse-Fehler abfangen
    (`unwrap_or_default`/pro-Zeile-500) statt Panic.
  - `.unwrap()` in den Handlern durch sauberes Error-Handling →
    `HttpResponse::InternalServerError()` ersetzen (Projektregel „kein unwrap auf
    Prod-Pfad").
  - Mindestens: Connection-Pool/Caching der Rating-Berechnung **oder** dokumentierte
    Rate-Limit-/Proxy-Schranke; Body-Size-Limit setzen.
- **Out of scope**: Auth-Einführung (separat), Schema-Änderungen.

## Acceptance Criteria
- [ ] Null/fehlende Team-Felder lassen die Endpoints **nicht** panicken.
- [ ] DB-Fehler → sauberer 500, kein Panic.
- [ ] `cargo clippy -- -D warnings` clean; `cargo test` grün (Tests für die neuen Pfade).
- [ ] Lockstep: ggf. `Team`-Struct-Angleich mit macht-api dokumentiert.
