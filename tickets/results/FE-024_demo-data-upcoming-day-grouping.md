# FE-024 Result — Demo-Daten: Upcoming Fixtures über mehrere Tage

**Geschlossen**: 2026-05-30
**Commits**:
- `frontend` (main) `28234c3 FE-024: seed second fixtures on upcoming days so day-grouping shows multi-match days (#33)` (squash-merge von PR #33)

## Was wurde gemacht

`scripts/demo_data.ts` `buildMatches` um zwei zusätzliche SCHEDULED-Spiele
(id 13, 14) ergänzt, mit **identischer `utcDate`** zu bestehenden
Upcoming-Spielen (id 13 = `now + 1*DAY` wie id 7; id 14 = `now + 2*DAY` wie
id 8). Dadurch enthalten zwei Upcoming-Tage je **2 Spiele**, sodass die
Tag-Gruppierung im Dashboard Tage mit mehreren Spielen zeigt. Die anstehenden
Spiele verteilen sich weiterhin über ≥3 Kalendertage.

## Geänderte Dateien

- `frontend/scripts/demo_data.ts` — zwei Fixtures (id 13, 14) ergänzt

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **82/82 passed**
- `pnpm db:reset`-Verifikation **manuell** (nicht ausgeführt, da es die
  laufende Shared-DB überschreiben würde) — vom Reviewer per Code-Reasoning
  bestätigt.

## Reviewer-Feedback

Reviewer-Agent: zunächst **REQUEST-CHANGES** — der Commit enthielt
versehentlich eine leer gestagte `design/account.html` (durch `git commit`
ohne Pathspec). Behoben: Commit auf nur `demo_data.ts` reduziert
(force-push). Danach **APPROVE** (Tag-Gruppierung korrekt, IDs/Teams gültig,
fehlender Unit-Test wegen `main()`-Top-Level-Execution als Exemption
akzeptiert).

## Notiz

`demo_data.ts` führt `main()` top-level aus → `buildMatches` ist nicht ohne
Seed-Side-Effect unit-testbar (Test out of scope für diesen Seed-Tweak).
