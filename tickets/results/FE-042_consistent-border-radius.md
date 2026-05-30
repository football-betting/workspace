# FE-042 Result — Einheitliche Border-Radien

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `d0fc590 FE-042: unify border radius (cards rounded-lg, fix sharp auth card, xl->lg, xs->sm) (#40)` (squash-merge von PR #40)

## Was wurde gemacht

Konvention vereinheitlicht (nur Radius-Utilities, keine Layout-/Farb-/
Spacing-Änderungen):
- Karten/Panels → `rounded-lg` (inkl. der zuvor **kantigen** Login-Card;
  `rounded-xl`-Container → `rounded-lg`).
- Kleine Tags/Bilder: `rounded-xs` → `rounded-sm`.
- Buttons `rounded-lg`, Inputs `rounded`, Pills/Avatare/Dots `rounded-full`
  unverändert.

## Geänderte Dateien (frontend, 9)
- `app/(auth)/login/page.tsx`, `app/(app)/match/[id]/page.tsx`,
  `app/(app)/ranking/page.tsx`, `components/ranking/RankingTable.tsx`,
  `components/ranking/ScoringInfobox.tsx`, `components/match/PredictionsTable.tsx`,
  `components/profile/PredictionHistory.tsx`, `components/dashboard/Flag.tsx`,
  `components/profile/WinnerCards.tsx`

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest 98/98; `--build` → ok.

## Review
Rein kosmetisch (Radius-Klassen), build-verifiziert → Self-Review.

## Offen (Folge, optional)
Einige blanke `rounded`-Chips/Badges (PredictionsTable „YOU", MatchHeader-Pills,
RankingTabs inaktiv) bleiben — bei Bedarf später auf `rounded-sm` normalisieren.
