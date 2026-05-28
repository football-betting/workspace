# MA-001 Result — macht-api Test-Compile reparieren + unused/dead Code raus

**Geschlossen**: 2026-05-28
**Commits**:
- `macht-api` (master) `7198b0a MA-001: fix test compile, drop FoundMatch`
- workspace `76c2b10 BA-001 + MA-001: ready for review`

## Was wurde gemacht

`cargo check --all-targets` und `cargo test --no-run` in `macht-api/`
laufen wieder durch (E0063 weg). Quality-Gate aus `CLAUDE.md` in
diesem Repo wieder grün. Kein Verhaltens-Change am Cron-Importer.

## Geänderte Dateien

Alle in `macht-api/`:

- `src/api/match_client.rs` —
  - `regularTime: None` in beiden Test-`Score`-Literals ergänzt
    (Zeilen 175 + 221 → nach `cargo fmt` an 179 + 233)
  - `use chrono::{DateTime, TimeZone, Utc};` → `use chrono::DateTime;`
    (zwei unused imports raus)
  - `pub struct FoundMatch { pub id: isize }` plus dazugehöriger
    `#[allow(non_snake_case)]` und `#[derive(...)]` gelöscht
- `src/api/mod.rs`, `src/main.rs`, `src/service/mod.rs`,
  `src/service/score_helper.rs` — `cargo fmt`-Churn (zur
  AC-Erfüllung `cargo fmt --check clean` nötig)

## Quality-Gate

- `cargo check --all-targets` → exit 0, keine Warnings
- `cargo clippy --all-targets` → exit 0, keine Warnings
- `cargo test --no-run` → kompiliert (Tests benötigen echte DB,
  Lauf out of scope)
- `cargo fmt --check` → clean
- Kein neues `.unwrap()`, kein `unsafe`, keine Debug-Prints

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**.

Verifiziert auf dem aktuellen `macht-api`-HEAD (MA-002 darauf gestackt):
- `regularTime: None` in beiden Score-Literals präsent
- Import-Zeile nur noch `use chrono::DateTime;`
- `grep -rn FoundMatch|TimeZone macht-api/src/` leer
- Keine neuen `.unwrap()` in `match_client.rs` (alle bestehenden
  sind pre-existing und out of scope laut Ticket)

Caveat: Reviewer konnte den einzelnen Commit `7198b0a` nicht direkt
diffen (Sandbox-Blockade auf `git -C macht-api`), aber der aktuelle
Source-Stand plus grünes Quality-Gate verifiziert die Akzeptanz.

## Folge-Aktionen

Die `.unwrap()`-Pfade in `match_client.rs` sind als P1.1 im
`docs/RUST_VERBESSERUNGEN.md`-Backlog dokumentiert und kommen über
ein späteres MA-Ticket dran. Test-Refactor von echter DB auf
In-Memory-SQLite ist P7.1, ebenfalls dort.
