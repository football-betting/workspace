# [WS-001] Architektur-Empfehlungen für Rust-Services dokumentieren

## Repo
workspace

## Type
docs

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background

Bei der Analyse von `betting-api` und `macht-api` für die Quick-Win-Tickets
(BA-001, MA-001) sind eine Reihe strukturelle Verbesserungs-Möglichkeiten
aufgefallen, die nicht in den Quick-Win-Scope passen (Verhaltens-Änderung
oder größerer Refactor). Statt sie zu vergessen, bekommen sie einen
priorisierten Platz in einem Empfehlungs-Doc, das Owner als Entscheidungs-
Grundlage für Folge-Tickets nutzen kann.

Form: **Empfehlungen, kein Code**. Pro Eintrag:
- Befund (mit `Datei:Zeile`-Referenz)
- Risiko / Impact
- Empfehlung
- Aufwand-Schätzung (S/M/L)

## Scope

**In scope:**
- Neue Datei `docs/RUST_VERBESSERUNGEN.md` erstellen
- Inhalt gruppiert nach Priorität:
  - **P0 Korrektheit** — zwei Items:
    - `betting-api/src/service/mod.rs:62-66`:
      `secret_winner == "ESP"` setzt `extra_point = 7` und überschreibt
      damit `winner == "ESP" → 15`. Als **offene Frage an Owner**
      dokumentieren: Bug oder gewollt?
    - `betting-api/src/service/mod.rs:91-92`:
      `serde_json::from_str::<Team>(&game.home_team).unwrap()` mit
      required `name`+`tla` panict, sobald `tla` mal nicht geliefert
      wird (`macht-api::Team` hat alle Felder optional).
  - **P1 Härtung** — `.unwrap()`-Pfade:
    - `macht-api/src/api/match_client.rs` (alle HTTP/JSON/DB-Calls)
    - `macht-api/src/main.rs:18` `panic!("{}")` für getopts-Fehler
    - `MatchClient::get_matches` Z. 65-78: env-Errors fallen auf
      String `"Error loading env variable API_URI"` zurück
    - `betting-api/src/routes.rs` (mehrere `.unwrap()` in Handler)
  - **P2 Konfigurierbarkeit**:
    - `ESP` als Turnier-Sieger in
      `betting-api/src/service/mod.rs:58-66`
    - `127.0.0.1:8080` Bind in `betting-api/src/main.rs:16`
    - Scoring-Konstanten `WIN_EXACT=4 / WIN_SCORE_DIFF=2 /
      WIN_TEAM=1 / +15 / +7` (`betting-api/src/service/mod.rs:46-50`)
  - **P3 Performance / DB**:
    - N+1 DB-Connections: jeder `/rating` öffnet die DB
      `2 + N_users` mal (`establish_connection()` in jeder `db::*`-Fn)
    - Empfehlung: `r2d2 + r2d2_sqlite` + JOIN-Query in `get_user_rating`
  - **P4 Code-Struktur**:
    - `MatchClient`/`ScoreHelper` als leere Structs mit
      assoziierten Funktionen — freistehende Module oder echte Typen
      mit State
    - `macht-api` ohne `lib.rs` — schwer testbar
    - Kein zentraler Error-Type — Empfehlung: `thiserror` pro Crate
  - **P5 Observability**:
    - Kein `tracing`/Logging — Empfehlung: `tracing` +
      `tracing-subscriber` mit JSON-Layer (PM2-kompatibel)
  - **P6 Schema/Migrationen**:
    - `betting-api/migrations/` enthält nur `.keep`
    - Schema-Wahrheit doppelt in `frontend/db/schema.ts` und
      `betting-api/src/db/fixtures.rs`
    - `match.score`-Spalte wird von `macht-api` geschrieben, von
      niemand gelesen
  - **P7 Testing**:
    - `macht-api`-Tests hängen an echter DB
      (`Connection::open(&db_path)`)
    - Kein HTTP-Mock für externe API — Empfehlung: `wiremock`
- Kurze Einleitung (Sinn des Docs, wie zu lesen, Verhältnis zu
  Quick-Wins und `TECH_ARCHITEKTUR.md`)
- Schluss-Sektion „Offene Fragen an Owner" mit den zwei P0-Items

**Out of scope (explicit):**
- Code-Änderungen jeglicher Art
- Konkrete Implementations-Tickets — die werden erst gezogen, sobald
  Owner die P0-Fragen entschieden hat
- Frontend-Hinweise

## References

- `docs/TECH_ARCHITEKTUR.md` (existierende Architektur-Übersicht;
  `RUST_VERBESSERUNGEN.md` ergänzt, nicht ersetzt)
- `docs/specs/2026-05-28-rust-quick-wins-and-updates.md` §5
- `betting-api/src/{routes,service/mod,db/mod,db/fixtures}.rs`
- `macht-api/src/{main,api/match_client,service/score_helper}.rs`

## Acceptance Criteria

- [ ] `docs/RUST_VERBESSERUNGEN.md` existiert
- [ ] Datei enthält Sektionen P0–P7 in der Reihenfolge wie oben
- [ ] Jeder Befund nennt mindestens eine `Datei:Zeile`-Referenz
- [ ] Jede Empfehlung hat eine S/M/L-Aufwand-Schätzung
- [ ] Schluss-Sektion „Offene Fragen an Owner" enthält die zwei P0-Items
      explizit als nummerierte Fragen
- [ ] Keine Code-Patches, nur Beschreibung
- [ ] `pnpm exec prettier --check docs/RUST_VERBESSERUNGEN.md` clean
      (oder vom PostToolUse-Hook auto-formatiert)

## Verification (manual)

1. `cat docs/RUST_VERBESSERUNGEN.md | head -40` → liest sich als
   eigenständiges Empfehlungs-Doc
2. `grep -cE "^### P[0-7]" docs/RUST_VERBESSERUNGEN.md` → ≥ 8
3. `grep -E ":[0-9]+" docs/RUST_VERBESSERUNGEN.md | wc -l` → mehrere
   `Datei:Zeile`-Referenzen
4. Schluss-Sektion enthält die zwei P0-Fragen wörtlich

## Notes

Dieses Ticket landet **nach** BA-001 und MA-001, damit Datei:Zeile-
Referenzen in der Doc auf dem aufgeräumten Code basieren.
