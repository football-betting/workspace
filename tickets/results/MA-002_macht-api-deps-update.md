# MA-002 Result — macht-api Dependencies auf latest stable

**Geschlossen**: 2026-05-28
**Commits**:
- `macht-api` (master) `a23b814 MA-002: deps to latest stable, getopts -> clap`
- workspace `2c56601 BA-002 + MA-002: ready for review`

## Was wurde gemacht

`macht-api/Cargo.toml` auf den heute aktuellen stable-Stand gebracht.
Drei Crate-Wechsel: `dotenv → dotenvy`, `getopts → clap`, plus
`serde_derive` raus. `mio` dev-dep entfernt (nirgendwo referenziert).
CLI-Schnittstelle (`-f / --full`) unverändert, jetzt von `clap` derive
generiert statt `getopts`.

## Dependencies

| Crate | Vorher | Nachher |
|---|---|---|
| tokio | 1.33 | **1.52.3** |
| reqwest | 0.12.4 | **0.13.4** |
| rusqlite | 0.31.0 | **0.40.0** |
| chrono | 0.4.31 | **0.4.44** |
| serde | 1.0.22 | **1.0.228** (mit `features = ["derive"]`) |
| serde_derive | 1.0.188 | **entfernt** |
| serde_json | 1.0.117 | **1.0.150** |
| dotenv | 0.15 | **dotenvy 0.15.7** |
| getopts | 0.2.21 | **clap 4.6.1** (derive) |
| futures | 0.3 | **0.3.32** |
| mio (dev) | 0.8.11 | **entfernt** |

`[dev-dependencies]`-Block ist jetzt komplett leer (Header weggelassen).

## System-Change

Toolchain von **rustc 1.91.1 auf 1.95.0** gebumpt — gleiche Begründung
wie BA-002 (`rusqlite 0.40` braucht `cfg_select`).

## Geänderte Dateien

Alle in `macht-api/`:

- `Cargo.toml` — Dep-Bumps + Crate-Wechsel
- `Cargo.lock` — von cargo regeneriert
- `src/main.rs` —
  - `getopts::Options` weg, `#[derive(clap::Parser)] struct Args`
    mit `#[arg(short = 'f', long = "full")] full: bool`
  - `panic!("{}", f.to_string())` weg (clap übernimmt
    Parse-Fehlerbehandlung mit Exit-Code 2 + Usage)
  - `if api_result.matches.is_some() { … as_mut().unwrap() … }`
    → `if let Some(matches) = api_result.matches.as_mut() { … }`
    (entfernt zwei `.unwrap()`-Aufrufe aus dem Produktivpfad, fixt
    clippy 1.95 `unnecessary_unwrap`-Lint)
  - `use std::env` entfernt (nicht mehr gebraucht)
- `src/api/match_client.rs` —
  - `use serde_derive::{...}` → `use serde::{...}`
  - `use dotenv::dotenv` → `use dotenvy::dotenv`
  - `dotenv()`-Call-Sites unverändert (dotenvy exportiert dieselbe
    Funktion)

## Unplanned aber notwendig

Eine nicht vom Ticket explizit gedeckte Änderung war zwingend für
`cargo clippy -D warnings`:

- **`if let Some(matches) = …` statt `is_some()` + `as_mut().unwrap()`**:
  Neuer clippy-Lint `unnecessary_unwrap` in 1.95. Bonus: zwei
  `.unwrap()`-Aufrufe weniger im Produktivpfad → kleiner Schritt in
  Richtung P1.1 (`docs/RUST_VERBESSERUNGEN.md`).

## CLI-Verhalten

Identisches Ergebnis, anderes Interface-Tooling:

- `cargo run` → daily import (heutiges Datum als `dateFrom=…&dateTo=…`)
- `cargo run -- --full` → full import (kein Datums-Filter)
- `cargo run -- --help` → clap-generierter Help-Text mit `-f, --full`
  und `-h, --help`
- `cargo run -- --unknown` → exit ≠ 0 mit clap-Usage-Hinweis (ersetzt
  das alte `panic!`-Stacktrace-Verhalten)

## Quality-Gate

- `cargo update` → läuft durch
- `cargo build` → exit 0
- `cargo clippy --all-targets -- -D warnings` → clean
- `cargo test --no-run` → kompiliert (Lauf benötigt echte DB,
  out of scope)
- `cargo fmt --check` → clean
- `cargo tree -e normal --depth 1` zeigt exakt die Ziel-Deps,
  kein `dotenv` (ohne y), kein `getopts`, kein `serde_derive`,
  kein `mio`

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**.

- Build clean, clippy clean, Tests kompilieren
- `main.rs:30` zeigt `if let Some(matches) = …` (alte `.unwrap()`s weg)
- `Match`-Struct unverändert — kein Schema-Drift gegenüber
  `betting-api` Read-Pfad
- reqwest 0.13 mit default-tls (native-tls) wie vor 0.12
- HTTP-Call-Shape unverändert

## Folge-Aktionen

Verbleibende `.unwrap()`-Pfade in `match_client.rs` (HTTP-/DB-/Parse-
Kette) sind in `docs/RUST_VERBESSERUNGEN.md` als P1.1 und P1.2
dokumentiert. Test-Refactor auf In-Memory-DB ist P7.1.
