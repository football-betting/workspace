# MA-004 macht-api: externe API nicht blind vertrauen

## Repo
macht-api

## Type
bug

## Risk
medium

## Priority
medium

> Security-Audit 2026-06-01 (MEDIUM).

## Status
todo

## Owner
implementer

## Background
Der Importer vertraut der externen Football-API vollständig: `.unwrap()` auf
HTTP/JSON/Datum, ein einzelner schlechter Datensatz bricht den ganzen Cron-Lauf,
und Team-Felder werden ohne Validierung in die geteilte DB geschrieben.

## Findings (Audit)
1. **Unwrap auf HTTP/JSON** (`src/api/match_client.rs:81-84`, MEDIUM): Netzwerk-/
   Nicht-2xx-/Schema-Fehler panicken den Importer.
2. **Datum-Parse-Panic** (`src/api/match_client.rs:94`, MEDIUM):
   `DateTime::parse_from_rfc3339(&utcDate).unwrap()` — ein malformed `utcDate`
   bricht den **gesamten** Lauf (Loop nicht isoliert) → keine Imports mehr.
3. **Keine Feld-Validierung/Sanitisierung** (`src/api/match_client.rs:102-103`,
   MEDIUM): Team `name`/`tla`/Crest werden roh persistiert → speist u. a. den
   betting-api-Parse-Panic (BA-004) und ist die Daten-Quelle für potenzielle
   FE-Render-Probleme. (Match-Tabelle nur von macht-api beschrieben — korrekt.)

## Scope
- **In scope**:
  - HTTP/JSON-Fehler behandeln (loggen, sauber beenden) statt `.unwrap()`.
  - Pro-Match-Parsing isolieren: bei malformed `utcDate`/Feldern den Datensatz
    **überspringen** (`continue`), nicht den ganzen Lauf abbrechen.
  - Team-Felder beim Import validieren (Pflichtfelder `name`/`tla` setzen bzw.
    Defaults, Längen-Caps); kein null in die `homeTeam`/`awayTeam`-JSON, das
    betting-api required liest (Lockstep mit BA-004).
- **Out of scope**: API-Provider-Wechsel; Schema-Änderungen.

## Acceptance Criteria
- [ ] Netzwerk-/JSON-Fehler brechen nicht mit Panic ab.
- [ ] Ein malformed Datensatz überspringt nur diesen, der Rest wird importiert.
- [ ] Persistierte Team-JSON haben immer gültige `name`/`tla` (kein null) → BA-004-Panic-Quelle geschlossen.
- [ ] `cargo clippy -- -D warnings` clean; `cargo test` grün.
