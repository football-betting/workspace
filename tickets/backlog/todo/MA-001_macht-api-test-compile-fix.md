# [MA-001] macht-api Test-Compile reparieren + unused/dead Code raus

## Repo
macht-api

## Type
bug

## Risk
low

## Priority
high

## Status
todo

## Owner
implementer

## Background

`cd macht-api && cargo test` kompiliert aktuell nicht (E0063): die zwei
Test-Funktionen in `src/api/match_client.rs` konstruieren `Score`-Literals
ohne das `regularTime: Option<ScoreDetail>`-Feld, das im Struct definiert
ist. Damit verletzt `macht-api` das Quality-Gate aus `CLAUDE.md`. Zusätzlich
melden Build-Warnings zwei ungenutzte `chrono`-Imports und eine
unbenutzte Struct (`FoundMatch`). Kein Verhaltens-Change.

## Symptom

```
error[E0063]: missing field `regularTime` in initializer of `match_client::Score`
   --> src/api/match_client.rs:175:24
   --> src/api/match_client.rs:221:24
```

und

```
warning: unused import: `Utc`         --> src/api/match_client.rs:2:34
warning: unused import: `TimeZone`    --> src/api/match_client.rs:2:24
warning: struct `FoundMatch` is never constructed  --> src/api/match_client.rs:28:12
```

Repro: `cd macht-api && cargo check --all-targets`.

## Scope

**In scope:**
- `src/api/match_client.rs` Zeilen 175 und 221 — in beiden
  `Score { … }`-Test-Literals `regularTime: None` ergänzen
- `src/api/match_client.rs:2` — `use chrono::{DateTime, TimeZone, Utc};`
  → `use chrono::DateTime;`
- `src/api/match_client.rs:28-31` — `pub struct FoundMatch { pub id: isize }`
  inkl. `#[derive(...)]` und `#[allow(non_snake_case)]` löschen

**Out of scope (explicit):**
- `.unwrap()`-Härtung im HTTP-/DB-Pfad (separates Backlog-Item)
- Tests von echter DB auf In-Memory-SQLite umstellen
- Dependency-Updates (Aufgabe von MA-002)
- Refactor von `MatchClient`/`ScoreHelper` Pseudo-OOP

## References

- `macht-api/src/api/match_client.rs`
- `docs/specs/2026-05-28-rust-quick-wins-and-updates.md` §3
- `docs/TECH_ARCHITEKTUR.md` §2 (macht-api Übersicht)

## Acceptance Criteria

- [ ] `cd macht-api && cargo check --all-targets` exit 0, **keine** warnings
- [ ] `cd macht-api && cargo clippy --all-targets` exit 0, **keine** warnings
- [ ] `cd macht-api && cargo test --no-run` exit 0 (Tests kompilieren;
      Laufzeit-Tests hängen an echter DB und sind hier nicht im Scope)
- [ ] `cd macht-api && cargo fmt --check` clean
- [ ] `pub struct FoundMatch` ist im Code nicht mehr auffindbar
      (`grep -r FoundMatch macht-api/src/` → leer)
- [ ] Kein neues `.unwrap()`, kein `unsafe`, keine Debug-Prints
- [ ] Diff betrifft ausschließlich `src/api/match_client.rs`

## Verification (manual)

1. `cd macht-api && cargo check --all-targets 2>&1 | grep -E "warning|error"`
   → leer
2. `cd macht-api && cargo clippy --all-targets 2>&1 | grep -E "warning|error"`
   → leer
3. `cd macht-api && cargo test --no-run` → "Compiling rust-api … Finished"
4. `grep -rn "TimeZone\|FoundMatch" macht-api/src/` → leer
