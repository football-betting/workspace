# XR-003 Scoring-Schema überarbeiten (neue Punkte + Draw-Regel)

## Repo
multi

## Type
feature

## Risk
high

## Priority
high

## Status
todo

## Owner
implementer

> `high` → externer Review erforderlich vor `done`.

## Background
Das Punktesystem wird umgestellt. Die Punktwerte ändern sich und die
Draw-Behandlung wird vereinheitlicht. Aktuell rechnet die Rust-Read-API
(`betting-api`) die Rangliste, **und** das Frontend rechnet dieselben Punkte
für die Live-Anzeige nochmal nach (`lib/score.ts`) — die beiden weichen heute
beim Unentschieden voneinander ab. Beide Seiten müssen auf das neue Schema und
eine identische Draw-Regel gebracht werden, sonst zeigt das Dashboard andere
Punkte als die Rangliste.

## Neues Punkteschema
| Treffer | Punkte |
|---|---:|
| Exaktes Ergebnis | 5 |
| Richtige Tordifferenz (kein Draw) | 3 |
| Richtiger Gewinner | 2 |
| Draw korrekt, aber Ergebnis falsch | 2 |
| — kein Treffer | 0 |

Bonus:
| | Punkte |
|---|---:|
| Weltmeister richtig | +12 |
| Secret/Geheimtipp richtig | +6 |

**Draw-Regel:** Ist das tatsächliche Ergebnis ein Unentschieden und der Tipp
ein (anderes) Unentschieden, gibt es **2** Punkte (wie „richtiger Gewinner") —
**nicht** die Tordifferenz-Punkte (3). Tordifferenz-Punkte gelten nur für
Nicht-Draws.

## Scope
- **In scope**:
  - `betting-api`:
    - `ScoreConfig`: `WIN_EXACT` 4→5, `WIN_SCORE_DIFF` 2→3, `WIN_TEAM` 1→2.
    - Bonus: `extra_point` 15→12 (Weltmeister), 7→6 (Secret).
    - Draw-Zweig in `calculate_score` (gibt bereits `WIN_TEAM`) auf das neue
      Schema bestätigen; Kategorisierung der `sum_*`-Zähler prüfen.
    - Unit-Tests in `src/service/mod.rs` an die neuen Werte + Draw-Fall
      anpassen.
  - `frontend`:
    - `lib/score.ts` `computeScore`: neue Werte (5/3/2) **und** Draw-Sonderfall
      ergänzen (korrekter Draw, falsches Ergebnis → 2, nicht 3) — identisch zu
      Rust.
    - `lib/scoring.ts` `scoreColor`: Schwellen an neue Werte anpassen.
    - `components/ranking/ScoringInfobox.tsx`: angezeigte Werte auf 5/3/2 +
      Bonus +12/+6 aktualisieren und Zeile „Draw korrekt, Ergebnis falsch → 2"
      ergänzen.
    - Frontend-Unit-Tests (`tests/unit/scoring.test.ts`,
      `tests/unit/scoring-color.test.ts`) anpassen.
  - `docs`: Scoring-Konstanten in `FRONTEND_FUNKTIONS_SPEC.md` /
    `TECH_ARCHITEKTUR.md` aktualisieren, falls dort die alten Werte stehen.
- **Out of scope (explicit)**: Hardcodiertes `"ESP"` für Weltmeister/Secret in
  ein `.env`-Var auslagern (separates Thema); i18n-Übersetzung der
  ScoringInfobox (bleibt FE-023).

## References
- `betting-api/src/service/mod.rs` — `ScoreConfig` (Z. ~40-46),
  `extra_point` (Z. ~57-65), `calculate_score` (Z. ~144-169), Tests (`mod tests`)
- `frontend/lib/score.ts` — `computeScore` (dupliziert die Logik)
- `frontend/lib/scoring.ts` — `scoreColor` (Schwellen 4/2/0)
- `frontend/components/ranking/ScoringInfobox.tsx` — angezeigte Werte
- `frontend/tests/unit/scoring.test.ts`, `scoring-color.test.ts`

## Acceptance Criteria
- [ ] Rust: exakt=5, Tordifferenz=3, Gewinner=2, Draw-korrekt=2, kein Treffer=0.
- [ ] Rust: Bonus Weltmeister=+12, Secret=+6.
- [ ] Rust: korrekter Draw mit falschem Ergebnis → 2 (nicht 3); `cargo test` grün.
- [ ] Frontend `computeScore` liefert für jeden Fall **denselben** Wert wie Rust,
      inkl. Draw-Sonderfall (2).
- [ ] ScoringInfobox zeigt 5/3/2, Bonus +12/+6 und die Draw-Zeile.
- [ ] `scoreColor` passt zu den neuen Werten.
- [ ] Quality Gate grün in beiden Repos:
  - Rust: `cargo clippy -- -D warnings && cargo test`
  - Next.js: `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Notes (multi-repo only)
Implementierungsreihenfolge (koordinierte Commit-Kette):
1. `betting-api/src/service/mod.rs` — Konstanten, Bonus, Draw bestätigen
2. `betting-api` — Unit-Tests anpassen
3. `frontend/lib/score.ts` — neue Werte + Draw-Sonderfall
4. `frontend/lib/scoring.ts` — `scoreColor`-Schwellen
5. `frontend/components/ranking/ScoringInfobox.tsx` — Anzeige
6. `frontend` — Unit-Tests anpassen
7. `docs` — Scoring-Referenzen

## Verification (manual)
1. Spiel mit exaktem Tipp → 5; Tordifferenz (kein Draw) → 3; nur Gewinner → 2.
2. Tatsächlicher Draw, anderer Draw getippt → 2 (nicht 3), in Dashboard **und**
   Rangliste identisch.
3. Rangliste: Bonus für Weltmeister/Secret = +12 / +6.
4. ScoringInfobox zeigt die neuen Werte + Draw-Zeile.
