# Rust Quick-Wins, Package-Updates & Architektur-Empfehlungen

**Datum**: 2026-05-28
**Scope**: nur `betting-api/` und `macht-api/` — Frontend wird parallel von
einer anderen Session bearbeitet und bleibt unangetastet.

---

## 1. Kontext

Die zwei Rust-Services teilen sich die SQLite-Datei mit dem Frontend
(`shared/db/database.db`). Aktueller Zustand:

- `betting-api`: kompiliert, **72/72 Tests grün**, aber
  `cargo clippy -- -D warnings` (Quality-Gate aus `CLAUDE.md`) **rot** —
  8 Findings: `clone_on_copy`, `let_and_return`, `needless_borrow`,
  `module_inception`, redundante `use serde_json;`, plus ein
  Fixtures-DDL-Tippfehler (`homeTeam he NOT NULL`).
- `macht-api`: Bin-Crate baut mit Warnings (`unused imports`,
  `dead_code FoundMatch`), aber **`cargo test` kompiliert nicht**
  (E0063: `Score`-Literal in zwei Tests ohne `regularTime`-Feld).
  Quality-Gate also rot.
- Beide: Dependencies mehrere Monate alt; `dotenv` ist unmaintained,
  `serde_derive` als separate Dep redundant.

Ziel dieses Specs: Quality-Gate in beiden Repos grün ziehen ohne
Verhaltensänderung, alle Dependencies auf aktuelle stable bringen, und
strukturelle Verbesserungen als priorisierten Backlog im Architektur-Doc
festhalten.

## 2. Scope

5 Tickets in dieser Reihenfolge. BA-001/MA-001 und BA-002/MA-002 sind je
unabhängig und können parallel laufen.

| # | Ticket | Was |
|---|---|---|
| 1 | **BA-001** | `betting-api` Clippy-Findings + Fixtures-Tippfehler beheben |
| 2 | **MA-001** | `macht-api` Test-Compile reparieren + unused/dead Code raus |
| 3 | **WS-001** | `docs/RUST_VERBESSERUNGEN.md` mit Architektur-Empfehlungen schreiben |
| 4 | **BA-002** | `betting-api` Dependencies auf latest stable |
| 5 | **MA-002** | `macht-api` Dependencies auf latest stable |

## 3. Quick-Win-Items im Detail

### `betting-api` (BA-001)

- `src/db/fixtures.rs:58, 62` — `&conn` → `conn` (needless_borrow ×2)
- `src/db/fixtures.rs:285` — `homeTeam he NOT NULL` → `homeTeam TEXT NOT NULL`
- `src/db/fixtures.rs:4` und `src/service/mod.rs:6` — redundante
  `use serde_json;` löschen
- `src/db/mod.rs:46-48` — `let connection = …; connection`
  → direkter Ausdruck (let_and_return)
- `src/service/mod.rs:70, 89, 97` — `.clone()` auf `i32`/`u64` entfernen
- `src/service/mod.rs:176` — inneres `mod tests { … }` auflösen,
  Inhalt ins äußere `mod tests` ziehen (module_inception)
- `src/service/ranking.rs` — komplette Datei löschen
  (Dead Code mit kaputten Imports `crate::api::match_client`,
  `crate::service::firebase_connector`)
- `Cargo.toml:14` — `mockall` aus `[dependencies]` nach
  `[dev-dependencies]` verschieben

### `macht-api` (MA-001)

- `src/api/match_client.rs` Tests Z. 175 + 221 — `regularTime: None`
  im `Score`-Literal ergänzen (E0063 fix)
- `src/api/match_client.rs:2` — `use chrono::{DateTime, TimeZone, Utc};`
  → `use chrono::DateTime;` (unused imports)
- `src/api/match_client.rs:28-31` — `pub struct FoundMatch` löschen
  (dead_code, nirgendwo benutzt)

## 4. Package-Updates

Alle Crates auf den heute aktuellen stable-Stand. Crates die nicht mehr
gepflegt werden bzw. redundant sind, werden ersetzt/entfernt.

### `betting-api/Cargo.toml` (BA-002)

| Crate | Aktuell | Neu |
|---|---|---|
| actix-web | 4.7 | **4.13** |
| rusqlite | 0.31 | **0.40** ⚠️ Breaking-API möglich |
| chrono | 0.4.38 | **0.4.44** |
| serde | 1.0 | **1.0.228** (mit `features = ["derive"]`) |
| serde_derive | 1.0.203 | **entfernt** (durch serde-derive-Feature) |
| serde_json | 1.0 | **1.0.150** |
| dotenv | 0.15 | **dotenvy 0.15.7** (unmaintained → maintained Fork) |
| mockall | 0.12.1 | **0.14.0**, **nach `[dev-dependencies]`** |
| rstest | 0.21 | **0.26.1** (dev-only, bleibt) |
| actix-rt | 2.10 | **2.10.x** (dev-only) |

### `macht-api/Cargo.toml` (MA-002)

| Crate | Aktuell | Neu |
|---|---|---|
| tokio | 1.33 | **1.52.3** |
| reqwest | 0.12.4 | **0.13.4** ⚠️ Breaking |
| rusqlite | 0.31 | **0.40** ⚠️ Breaking |
| chrono | 0.4.31 | **0.4.44** |
| serde | 1.0.22 | **1.0.228** (mit `features = ["derive"]`) |
| serde_derive | 1.0.188 | **entfernt** |
| serde_json | 1.0.117 | **1.0.150** |
| dotenv | 0.15 | **dotenvy 0.15.7** |
| getopts | 0.2.21 | **clap 4.6.1** (derive-Macro, typisiertes CLI) |
| futures | 0.3 | **0.3.x** |
| mio (dev) | 0.8.11 | **entfernt** (nirgendwo referenziert) |

## 5. Architektur-Empfehlungs-Doc (WS-001)

Pfad: `docs/RUST_VERBESSERUNGEN.md`.

Form: Empfehlungs-Liste, **kein Code-Diff**. Pro Eintrag: Befund mit
`Datei:Zeile`-Referenz, Risiko, Empfehlung, Aufwand (S/M/L). Gruppiert
nach Priorität:

- **P0 Korrektheit** — `secret_winner == "ESP"` überschreibt
  `winner == "ESP"`-Bonus (`betting-api/src/service/mod.rs:62-66`);
  `serde_json::from_str::<Team>(…).unwrap()` auf nullable `tla`-Felder
  (Schema-Drift-Panic)
- **P1 Härtung** — `.unwrap()`-Pfade in
  `macht-api/src/api/match_client.rs` und `betting-api/src/routes.rs`;
  env-Errors als String "Error loading env variable …"; `panic!()` in
  `macht-api/src/main.rs:18`
- **P2 Konfigurierbarkeit** — `ESP`-Turnier-Sieger, `127.0.0.1:8080`,
  Scoring-Konstanten 4/2/1/+15/+7
- **P3 Performance/DB** — N+1 DB-Connections in `/rating`;
  `r2d2 + r2d2_sqlite` + JOIN-Query
- **P4 Code-Struktur** — `MatchClient`/`ScoreHelper`/`Ranking` als
  leere Structs; `macht-api` ohne `lib.rs`; kein zentraler Error-Type
  (`thiserror`)
- **P5 Observability** — kein `tracing`/Logging
- **P6 Schema/Migrationen** — `betting-api/migrations/` leer;
  Schema-Wahrheit doppelt (Drizzle + `fixtures.rs`); ungenutzte
  `match.score`-Spalte
- **P7 Testing** — `macht-api`-Tests hängen an echter DB; kein HTTP-Mock
  (z. B. `wiremock`) für externe API

P0-Items werden im Doc als **offene Fragen an Owner** dokumentiert und
nicht direkt in diesem Spec-Scope gefixt — sie sind Verhaltens-Entscheidungen.

## 6. Akzeptanzkriterien (übergreifend)

Pro Ticket:

- Quality-Gate des berührten Repos grün:
  `cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test`
- Keine neuen `.unwrap()`, kein `any` (TS-Regel, hier n/a), keine Debug-Flags
- Keine `Co-Authored-By: Claude` / AI-Attribution-Zeilen in Commits
- Result-Doc nach `tickets/results/<id>_<slug>.md` mit Befund-Zusammenfassung

Für BA-002 / MA-002 zusätzlich:
- Verhalten unverändert (gleiche Test-Assertions grün)
- Keine API-Änderung (gleiche HTTP-Pfade, gleiche Response-Schemas)

## 7. Out of Scope

Bewusst nicht in diesem Spec:

- Alle P0–P7-Items aus dem Architektur-Doc (außer dem Schreiben des Docs
  selbst). Diese werden als separate Tickets gezogen, sobald Owner die
  P0-Fragen entschieden hat.
- Frontend-Änderungen jeglicher Art.
- Schema-Änderungen (`shared/db/database.db` Spalten).
- Edition-Bump auf 2024.

## 8. Frontend-Koordination

Keiner der 5 Tickets berührt `frontend/db/schema.ts`, Spaltennamen oder
Tabellen. Kollidiert nicht mit der parallelen Frontend-Session.

## 9. Offene Punkte (von Architektur-Doc nach Owner zu beantworten)

1. Ist die `secret_winner == "ESP"`-Überschreibung von 15 auf 7 in
   `betting-api/src/service/mod.rs:62-66` Absicht oder Bug?
2. Welche Felder im `Team`-Struct sind verlässlich vorhanden (`tla`)?
   Sollen `betting-api`-Reads optional dekodieren oder hart auf Schema
   bestehen?

## 10. Reihenfolge

1. **BA-001, MA-001** parallel
2. **WS-001** — sobald 1+2 fertig (Doc landet auf cleanem Code)
3. **BA-002, MA-002** parallel — Updates auf cleanem Code
