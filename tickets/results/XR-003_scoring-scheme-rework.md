# XR-003 Result — Scoring-Schema-Rework (5/3/2 + Bonus 12/6)

**Geschlossen**: 2026-05-31
**Risk**: high → externer Review durchgeführt (frischer reviewer-Kontext, 0 Defects, alle Werte handverifiziert inkl. Draw-Regel + neu hergeleitete Routes-Totals).

## Was wurde gemacht
Punktesystem repo-übergreifend von 4/2/1 auf **5/3/2** umgestellt, Champion-Bonus
**15→12** (winner ESP) und **7→6** (secret_winner ESP). Zusätzlich den
Frontend-Draw-Bug behoben: ein korrektes Unentschieden mit falschem Ergebnis
zählt jetzt als Tendenz (**2**, WIN_TEAM) statt Tordifferenz — exakt wie die
Rust-Logik. Werte in lockstep über Rust, Frontend, i18n und Docs.

Neues Schema:
| Ergebnis | Punkte |
|---|---|
| Volltreffer (exakt) | 5 |
| Tordifferenz (kein Draw) | 3 |
| Tendenz / korrektes Unentschieden | 2 |
| Daneben | 0 |
| Bonus Weltmeister (ESP) | +12 |
| Bonus Secret (ESP) | +6 |

## Geänderte Dateien

### betting-api (PR #2, squash `1029068`)
- `src/service/mod.rs` — `ScoreConfig` 5/3/2; `extra_point` 12/6
- `src/routes.rs` — Integrationstest-Totals neu berechnet (ToniKroos 21→20, JohnDoe-Bonus 7→6, /game/2 Draw-Tip 1→2)
- `Cargo.lock` — inzidenteller Package-Rename-Nachzug (em2021_api→betting_api)

### frontend (PR #46, squash `9bb84c0`)
- `lib/score.ts` — `computeScore` neues Schema + Draw-Special-Case
- `lib/scoring.ts` — `scoreColor` 5→success, 3→warning, 0→danger, sonst neutral
- `components/profile/PredictionHistory.tsx` — `clampPerMatchPoints` 5/3/2
- `components/ranking/ScoringInfobox.tsx` — Draw-Zeile ergänzt, Werte aktualisiert
- `messages/de.json` / `messages/en.json` — `Scoring`-Katalog 5/3/2/+12/+6 + `drawCorrect`-Keys
- `tests/unit/scoring.test.ts`, `tests/unit/scoring-color.test.ts`, `tests/e2e/ranking.spec.ts`

### workspace (docs)
- `docs/FRONTEND_FUNKTIONS_SPEC.md`, `docs/TECH_ARCHITEKTUR.md` — Scoring-Konstanten + abgeleitete Seed-Totals neu berechnet

## Quality-Gate
- betting-api: `cargo clippy -- -D warnings` clean; `cargo test` → 36 passed
- frontend: `tsc --noEmit` clean; `vitest run` → 127 passed (19 Dateien)
