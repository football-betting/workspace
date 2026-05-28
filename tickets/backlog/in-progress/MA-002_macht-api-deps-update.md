# [MA-002] macht-api Dependencies auf latest stable

## Repo
macht-api

## Type
chore

## Risk
medium

> `reqwest 0.12 → 0.13` und `rusqlite 0.31 → 0.40` sind Breaking-Sprünge.
> Plus Crate-Wechsel `getopts → clap`. Reviewer muss CLI-Verhalten
> (`--full` Flag) und HTTP-Pfad gegen externe API überprüfen.

## Priority
medium

## Status
todo

## Owner
implementer

## Background

`macht-api/Cargo.toml` listet Crates aus Q4 2023 / Q1 2024. `dotenv`
unmaintained, `serde_derive` redundant, `getopts` funktioniert aber
ist nicht mehr Standard für neue Rust-Projekte. Plus `mio` als
dev-dep, das nirgendwo referenziert wird. Ziel: alles auf den heute
aktuellen stable-Stand, Verhalten unverändert.

Vorgänger-Ticket MA-001 muss durch sein, sonst kompilieren die Tests
nicht und der Update-Diff lässt sich nicht sauber gegen ein grünes
Quality-Gate testen.

## Scope

**In scope** — `macht-api/Cargo.toml` aktualisieren:

| Crate | Aktion |
|---|---|
| `tokio` | `1.33.0` → `1.52.3` (features bleiben `["full"]`) |
| `reqwest` | `0.12.4` → `0.13.4` (Breaking — TLS-/Response-API) |
| `rusqlite` | `0.31.0` → `0.40` (Breaking möglich) |
| `chrono` | `0.4.31` → `0.4.44` |
| `serde` | `1.0.22` → `1.0.228`, mit `features = ["derive"]` |
| `serde_derive` | **entfernen** |
| `serde_json` | `1.0.117` → `1.0.150` |
| `dotenv` | **entfernen**, `dotenvy = "0.15.7"` ersetzt, alle Imports umstellen |
| `getopts` | **entfernen**, `clap = { version = "4.6.1", features = ["derive"] }` ersetzt; CLI `-f / --full` per `#[derive(Parser)]` mit `#[arg(short, long)]` neu definieren; `panic!("{}", f.to_string())` in `main.rs:18` weg, weil `clap` Fehler selbst korrekt mit Exit-Code 2 + Usage ausgibt |
| `futures` | bleibt `0.3.x` |
| `mio` (dev) | **entfernen** (nicht referenziert) |

`cargo update`, Compile-Errors aus Breakings auflösen.
Keine Verhaltens-Änderung am CLI-Flag (`-f` / `--full` weiter
unterstützt, gleiche Semantik).

**Out of scope (explicit):**
- `.unwrap()`-Härtung im HTTP-/DB-Pfad
- Tests von echter DB auf In-Memory-SQLite umstellen
- `wiremock` für externe API einführen
- `tracing`/Logging einbauen
- Frontend / `betting-api`

## References

- `macht-api/Cargo.toml`
- `macht-api/src/main.rs` (getopts → clap)
- `macht-api/src/api/match_client.rs` (reqwest + rusqlite + dotenvy)
- `docs/specs/2026-05-28-rust-quick-wins-and-updates.md` §4

## Acceptance Criteria

- [ ] `cd macht-api && cargo update` läuft durch
- [ ] `cd macht-api && cargo build` exit 0
- [ ] `cd macht-api && cargo clippy --all-targets -- -D warnings`
      exit 0, keine warnings
- [ ] `cd macht-api && cargo test --no-run` exit 0 (Tests kompilieren)
- [ ] CLI-Verhalten unverändert:
  - `cargo run -- --full` triggert Full-Import-Pfad
  - `cargo run` ohne Flag triggert Daily-Import-Pfad
  - `cargo run -- --hilfe` (unbekanntes Flag) exit ≠ 0 mit Usage-Hinweis
    (clap ersetzt das `panic!`)
- [ ] `cargo tree | grep dotenv` → nur `dotenvy`
- [ ] `cargo tree | grep getopts` → leer
- [ ] `cargo tree | grep serde_derive` → nicht als direkte Top-Level-Dep
- [ ] `mio` ist aus dem `Cargo.toml` entfernt

## Verification (manual)

1. `cd macht-api && cargo build --release` → Erfolg, keine warnings
2. `cd macht-api && cargo run -- --help` →
   neuer clap-generierter Help-Text mit `-f, --full`
3. `cd macht-api && cargo run -- --unknown` → exit ≠ 0, Usage-Hinweis
4. Mit echter `.env` + Test-DB: `cargo run -- --full` läuft durch,
   schreibt Matches in die Test-DB (gleiches Verhalten wie vor dem
   Update — manuell gegen 1-2 Match-IDs verifizieren)
5. `cargo tree -e normal --depth 1` enthält weder `dotenv` (ohne `y`),
   `getopts`, noch `serde_derive` als direkte Top-Level-Dep

## Notes

Bei `reqwest 0.13`: prüfen ob `Client::new()` weiterhin ohne
`rustls`/`native-tls`-Feature-Flag funktioniert. Falls Compile-Error,
explizit `features = ["default-tls"]` setzen (das ist das alte Default-
Verhalten von 0.12).

Bei `clap derive`: einfachstes Setup, ein `#[derive(Parser)]`-Struct mit
einem einzigen `#[arg(short = 'f', long = "full")] full: bool`-Feld.
Kein Subcommand, keine Sub-Args nötig — `main.rs` bleibt etwa gleich
lang.
