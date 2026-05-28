# BA-001 Result — betting-api Clippy-Cleanup + Fixtures-Tippfehler

**Geschlossen**: 2026-05-28
**Commits**:
- `betting-api` (main) `8d98d81 BA-001: clippy cleanup, remove ranking.rs`
- workspace `76c2b10 BA-001 + MA-001: ready for review`

## Was wurde gemacht

`cargo clippy --all-targets -- -D warnings` in `betting-api/` von rot
auf grün, plus DDL-Tippfehler im In-Memory-Fixtures-Schema und tote
Datei mit kaputten Imports entfernt. Kein Verhaltens-Change — alle
72 Tests bestehen mit unveränderten Assertions.

## Geänderte Dateien

Alle in `betting-api/`:

- `Cargo.toml` — `mockall` von `[dependencies]` nach `[dev-dependencies]`
- `src/db/fixtures.rs` —
  - DDL-Tippfehler `homeTeam he NOT NULL` → `homeTeam TEXT NOT NULL`
  - `needless_borrow` ×4 (clippy meldete 4, Ticket-Text sagte 2 — Agent
    hat alle 4 gefixt, AC-konform)
  - redundante `use serde_json;`-Zeile entfernt
- `src/db/mod.rs` — `let_and_return` in `establish_connection`
  aufgelöst (direkter Expression-Return)
- `src/lib.rs`, `src/main.rs`, `src/routes.rs` — `cargo fmt`-Churn
  (zur AC-Erfüllung `cargo fmt --check clean` nötig)
- `src/service/mod.rs` —
  - `clone_on_copy` ×3 (`user.id` ×2 in Z. 70 + 89, `game.date` in Z. 97)
  - redundante `use serde_json;`-Zeile entfernt
  - `module_inception` aufgelöst: inneres `mod tests { … }` mit dem
    Test `test_calculate_positions` ins äußere `mod tests` integriert
- `src/service/ranking.rs` — komplett gelöscht (toter Code mit kaputten
  Imports `crate::api::match_client` und `crate::service::firebase_connector`)

## Quality-Gate

- `cargo clippy --all-targets -- -D warnings` → exit 0, keine Warnings
- `MODE=test cargo test` → 36 lib + 36 bin = **72/72 passed**
- `cargo fmt --check` → clean
- Kein neues `.unwrap()`, kein `unsafe`, keine Debug-Prints

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**.

Verifiziert auf dem aktuellen `betting-api`-HEAD (BA-002 darauf gestackt):
- Clippy clean, Tests 72/72, fmt clean
- `ranking.rs` ist weg
- `mockall` ausschließlich unter `[dev-dependencies]`
- Alle acht im Scope genannten Fixes präsent
- Keine neuen `.unwrap()`, kein Schema-Drift-Risiko

## Folge-Aktionen

Keine direkten Follow-ups. Pre-existing `.unwrap()`-Pfade in
`routes.rs` und `service/mod.rs` sind als P1.4 / P0.2 im
`docs/RUST_VERBESSERUNGEN.md`-Backlog dokumentiert und kommen über
spätere BA-Tickets dran, wenn Owner die zwei P0-Fragen entschieden hat.
