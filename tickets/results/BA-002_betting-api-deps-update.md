# BA-002 Result — betting-api Dependencies auf latest stable

**Geschlossen**: 2026-05-28
**Commits**:
- `betting-api` (main) `fba2521 BA-002: deps to latest stable`
- workspace `2c56601 BA-002 + MA-002: ready for review`

## Was wurde gemacht

`betting-api/Cargo.toml` auf den heute aktuellen stable-Stand gebracht.
Crate-Wechsel `dotenv → dotenvy` (gepflegter Fork), `serde_derive` als
separate Dep raus (durch `serde` derive-Feature ersetzt). Verhalten und
HTTP-Schema unverändert — alle 72 Tests bestehen mit identischen
Assertions wie nach BA-001.

## Dependencies

| Crate | Vorher | Nachher |
|---|---|---|
| actix-web | 4.7 | **4.13.0** |
| rusqlite | 0.31.0 | **0.40.0** |
| chrono | 0.4.38 | **0.4.44** |
| serde | 1.0 | **1.0.228** (mit `features = ["derive"]`) |
| serde_derive | 1.0.203 | **entfernt** |
| serde_json | 1.0 | **1.0.150** |
| dotenv | 0.15 | **dotenvy 0.15.7** |
| mockall (dev) | 0.12.1 | **0.14.0** |
| rstest (dev) | 0.21 | **0.26.1** |

## System-Change

Rustc-Toolchain von **1.91.1 auf 1.95.0** gebumpt. `rusqlite 0.40` nutzt
`cfg_select!` aus `core`, das erst in 1.95 stabilisiert wurde (Tracking
Issue rust-lang/rust#115585). Festgehalten als neue Workspace-Minimum-
Version in [`project_rust-toolchain-1.95`](memory).

## Geänderte Dateien

Alle in `betting-api/`:

- `Cargo.toml` — Dep-Bumps + Crate-Wechsel (siehe Tabelle)
- `Cargo.lock` — von cargo regeneriert
- `src/routes.rs` — `use serde_derive::{...}` → `use serde::{...}`;
  `sort_by(|a,b| b.x.cmp(&a.x))` → `sort_by_key(|x| Reverse(x))`
- `src/db/mod.rs` — `use dotenv::dotenv` → `use dotenvy::dotenv`;
  `Game.date: u64` → `i64`
- `src/db/fixtures.rs` — `DbGame.utc_date: u64 → i64`, `DbTip.date: u64 → i64`,
  `now: u64 → i64` (Signaturen + `.as_secs() as i64` Cast)
- `src/service/mod.rs` — `MatchInfo.date: u64 → i64`;
  `sort_by` → `sort_by_key` in `calculate_positions`

## Unplanned aber notwendig

Mit dem Toolchain-/Dep-Bump kamen vier nicht vom Ticket explizit
gedeckte Änderungen, die für `cargo clippy -D warnings` und
`cargo build` zwingend waren:

1. **`u64 → i64` für DB-Timestamps**: `rusqlite 0.40` hat `ToSql` und
   `FromSql` für `u64` entfernt (SQLite INTEGER ist nativ `i64`).
   Wire-Output unverändert — Werte sind positive Sekunden seit Epoch,
   im `i64`-Bereich, JSON-Serialisierung identisch.
2. **`sort_by` → `sort_by_key`**: Neuer clippy-Lint
   `unnecessary_sort_by` in 1.95.
3. **`use serde_derive` → `use serde`**: Folge des Entfernens der
   separaten `serde_derive`-Dep.
4. **`use dotenv` → `use dotenvy`**: Folge des Crate-Wechsels.

## Quality-Gate

- `cargo update` → läuft durch
- `cargo build` → exit 0
- `cargo clippy --all-targets -- -D warnings` → clean
- `MODE=test cargo test` → **72/72 passed** mit unveränderten
  Assertions (keine Schema-Drift)
- `cargo fmt --check` → clean
- `cargo tree -e normal --depth 1` zeigt exakt die Ziel-Deps,
  kein `serde_derive` als direkte Top-Level-Dep, kein `dotenv`

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**.

- 72/72 Tests bestehen mit identischer JSON-Wire-Form
- Direct-Deps stimmen exakt mit Spec überein
- `mockall` nur in `[dev-dependencies]`
- `u64 → i64`-Migration wire-kompatibel (Reviewer bestätigt anhand
  Route-Tests, dass Deserialisierung unverändert funktioniert)
- Keine neuen `.unwrap()`, kein Schema-Drift

Reviewer's `cargo update` hat eine dirty `Cargo.lock` hinterlassen
(transitive Bumps) — habe ich vor dem Close mit `git checkout --
Cargo.lock` revertiert, weil das nicht zum BA-002-Scope gehört.

## Folge-Aktionen

Keine. Architektur-Backlog in `docs/RUST_VERBESSERUNGEN.md` (WS-001)
deckt alle weiteren Verbesserungen ab.
