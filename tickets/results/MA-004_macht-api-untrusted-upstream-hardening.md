# MA-004 Result — macht-api: externe API nicht blind vertrauen

**Geschlossen**: 2026-06-01
**Commit**: `macht-api` (master) `0255263 MA-004: harden importer against untrusted upstream data and DB errors (#3)` (PR #3)
**Risk**: medium → reviewer-Pass.

## Was wurde gemacht
- `get_matches` → `Option<ApiResult>`: Send-/Non-2xx-(`error_for_status`)/JSON-Fehler
  werden geloggt und liefern `None`; `main.rs` bricht sauber ab (kein Panic, keine Writes).
- Pro-Match-Isolation: malformed `utcDate` → loggen + `continue` (überspringt nur den Datensatz).
- `normalize_team`/`sanitize_field`: null/fehlende `name`/`tla` → `""` (nie null),
  Länge auf 255 char-grenzen-sicher gekappt → persistierte Team-JSON immer gültig.
- DB-Ops in `persist_match() -> rusqlite::Result<()>` via `?`; Fehler → loggen + skip.
- `get_connection` → `Option`. Import-Summary `N saved, M skipped`. 3 neue Tests.

## Lockstep (mit BA-004)
macht-api schreibt nun nie mehr null `name`/`tla` (Quelle geschlossen); betting-api
ist zusätzlich tolerant (BA-004). macht-api `Team` bleibt `Option<String>` — keine Schema-Änderung.

## Quality-Gate
- `cargo clippy -- -D warnings` clean; `cargo test` → 5 passed (inkl. neue).
