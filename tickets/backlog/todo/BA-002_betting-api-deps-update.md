# [BA-002] betting-api Dependencies auf latest stable

## Repo
betting-api

## Type
chore

## Risk
medium

> `rusqlite 0.31 → 0.40` ist ein 9-Minor-Sprung mit potenziellen
> Breaking-API-Änderungen. Reviewer muss die DB-Code-Pfade gegen Tests
> abgleichen.

## Priority
medium

## Status
todo

## Owner
implementer

## Background

`betting-api/Cargo.toml` listet teils Crates aus 2024. `dotenv` ist
unmaintained (Fork `dotenvy` wird gepflegt), `serde_derive` als separate
Dependency neben `serde` ist redundant. Ziel: alles auf den heute
aktuellen stable-Stand bringen, Verhalten unverändert lassen.

Vorgänger-Ticket BA-001 muss durch sein, damit der Update-Diff nicht
mit Clippy-Korrekturen vermischt wird.

## Scope

**In scope** — `betting-api/Cargo.toml` aktualisieren:

| Crate | Aktion |
|---|---|
| `actix-web` | `^4.7` → `4.13` |
| `rusqlite` | `0.31.0` → `0.40` (Breaking möglich — Compile-Errors fixen) |
| `chrono` | `0.4.38` → `0.4.44` |
| `serde` | `1.0` → `1.0.228`, mit `features = ["derive"]` |
| `serde_derive` | **entfernen** (durch `serde` derive-Feature ersetzt) |
| `serde_json` | `1.0` → `1.0.150` |
| `dotenv` | **entfernen**, durch `dotenvy = "0.15.7"` ersetzen, alle `use dotenv::dotenv` → `use dotenvy::dotenv` |
| `mockall` | `0.12.1` → `0.14.0` (nach `[dev-dependencies]`) |
| `rstest` (dev) | `0.21` → `0.26.1` |
| `actix-rt` (dev) | bleibt `2.10.x` |

Anschließend `cargo update`, Compile-Errors aus Breaking-Changes
auflösen (rusqlite Row-API, params-Macro, falls betroffen). Keine
Verhaltens-Änderung.

**Out of scope (explicit):**
- `.unwrap()`-Härtung
- DB-Connection-Pool
- Edition-Bump auf 2024
- Frontend / `macht-api`

## References

- `betting-api/Cargo.toml`
- `betting-api/src/db/mod.rs`, `betting-api/src/db/fixtures.rs` (rusqlite-API)
- `betting-api/src/main.rs`, `routes.rs` (dotenvy-Imports)
- `docs/specs/2026-05-28-rust-quick-wins-and-updates.md` §4

## Acceptance Criteria

- [ ] `cd betting-api && cargo update` läuft durch
- [ ] `cd betting-api && cargo build` exit 0
- [ ] `cd betting-api && cargo clippy --all-targets -- -D warnings`
      exit 0, keine warnings
- [ ] `cd betting-api && MODE=test cargo test` → 72/72 grün
      (alle bestehenden Assertions unverändert)
- [ ] `cargo tree | grep serde_derive` → leer (nur als transitive,
      nicht als direkte Dependency)
- [ ] `cargo tree | grep dotenv` → nur `dotenvy`, kein `dotenv`
- [ ] `mockall` ausschließlich in `[dev-dependencies]`
- [ ] Endpoints `/`, `/rating`, `/user/{id}`, `/game/{id}` antworten
      mit unveränderten JSON-Schemas (siehe Verification)

## Verification (manual)

1. `cd betting-api && cargo build --release` → Erfolg
2. `cd betting-api && MODE=test cargo test --lib --bins` → grün
3. `cd betting-api && MODE=test cargo run` startet auf `127.0.0.1:8080`
4. `curl -s localhost:8080/ | jq '.status'` → `"works"`
5. `curl -s localhost:8080/rating | jq 'keys'` →
   `["table", "daily_winner"]` (Schema unverändert)
6. `curl -s localhost:8080/user/2 | jq '.data.user_id'` → `2`
7. `cargo tree -e normal --depth 1` enthält weder `dotenv` (ohne `y`)
   noch `serde_derive` als direkte Top-Level-Dep

## Notes

Bei `rusqlite`-Compile-Errors: zuerst auf bestehende `query_map` /
`params!` / `Row::get`-API umstellen, nicht Logik ändern. Wenn ein
Breaking-Change die `Connection`-API berührt, im Ticket-Result
festhalten.
