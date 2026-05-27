# [BA-001] betting-api Clippy-Cleanup + Fixtures-Tippfehler

## Repo
betting-api

## Type
chore

## Risk
low

## Priority
high

## Status
todo

## Owner
implementer

## Background

`cargo clippy --all-targets -- -D warnings` ist aktuell rot in
`betting-api/` und verletzt damit das Quality-Gate aus `CLAUDE.md`.
Acht Clippy-Findings, plus ein DDL-Tippfehler im In-Memory-Fixtures-Schema,
plus eine tote Datei (`src/service/ranking.rs`) mit kaputten Imports auf
nicht existierende Module. Reine Kosmetik — kein Verhaltens-Change.

## Scope

**In scope:**
- `src/db/fixtures.rs:58, 62` — `&conn` → `conn` (needless_borrow)
- `src/db/fixtures.rs:285` — `homeTeam he NOT NULL` → `homeTeam TEXT NOT NULL`
- `src/db/fixtures.rs:4` — `use serde_json;` löschen
- `src/service/mod.rs:6` — `use serde_json;` löschen
- `src/db/mod.rs:46-48` — `let connection = …; connection` → direkter
  Ausdruck zurückgeben
- `src/service/mod.rs:70, 89, 97` — `.clone()` auf `i32`/`u64` entfernen
- `src/service/mod.rs:176-285` — inneres `mod tests { … }` auflösen,
  enthaltener Test `test_calculate_positions` direkt ins äußere
  `mod tests` integrieren
- `src/service/ranking.rs` — Datei löschen (Dead Code: importiert
  `crate::api::match_client::Match` und
  `crate::service::firebase_connector::Tip`, beide existieren nicht;
  wird auch nicht von `service/mod.rs` re-exportiert)
- `Cargo.toml` — `mockall = "0.12.1"` aus `[dependencies]` löschen und
  als `mockall = "0.12.1"` unter `[dev-dependencies]` neu eintragen

**Out of scope (explicit):**
- Jegliche Logik-Änderung
- Dependency-Versions-Bumps (Aufgabe von BA-002)
- `.unwrap()`-Entfernung in Routes/Services (separates Backlog-Item
  aus `docs/RUST_VERBESSERUNGEN.md`)

## References

- `betting-api/src/db/fixtures.rs`
- `betting-api/src/db/mod.rs`
- `betting-api/src/service/mod.rs`
- `betting-api/src/service/ranking.rs`
- `betting-api/Cargo.toml`
- `docs/specs/2026-05-28-rust-quick-wins-and-updates.md` §3

## Acceptance Criteria

- [ ] `cd betting-api && cargo clippy --all-targets -- -D warnings`
      exit code 0, keine warnings
- [ ] `cd betting-api && MODE=test cargo test` → 72/72 grün
      (alle bestehenden Assertions weiterhin OK)
- [ ] `cd betting-api && cargo fmt --check` clean
- [ ] `betting-api/src/service/ranking.rs` existiert nicht mehr
- [ ] `mockall` ist in `Cargo.toml` ausschließlich unter
      `[dev-dependencies]` zu finden
- [ ] Kein neues `.unwrap()`, kein `unsafe`, keine Debug-Prints
- [ ] Diff enthält keine Format-Churn auf nicht in Scope genannten Zeilen

## Verification (manual)

1. `cd betting-api && cargo clippy --all-targets -- -D warnings` →
   Exit 0, leere Warnliste
2. `cd betting-api && MODE=test cargo test --lib` → `36 passed; 0 failed`
3. `cd betting-api && MODE=test cargo test --bins` → `36 passed; 0 failed`
4. `cat betting-api/Cargo.toml | grep -A1 dev-dependencies` →
   `mockall` ist in der dev-Sektion
5. `ls betting-api/src/service/ranking.rs` → "No such file"
