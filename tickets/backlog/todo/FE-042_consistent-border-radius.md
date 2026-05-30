# FE-042 Einheitliche Border-Radien / Ecken über alle Seiten

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Die Ecken/Rahmen sind über die Seiten inkonsistent: manche Container sind
abgerundet, andere kantig. Beispiele: die Login-/Signup-Card
(`bg-surface-container border …` **ohne** `rounded`) ist kantig, `MatchRow`
nutzt `rounded-lg`, andere Karten `rounded-xl`, Inputs `rounded`. Das soll
vereinheitlicht werden, sodass die UI konsistent wirkt.

## Scope
- **In scope**:
  - Border-Radius-Nutzung über `app/**` und `components/**` auditen
    (`rounded`, `rounded-lg`, `rounded-xl`, fehlende Rundung etc.).
  - Eine **konsistente Konvention** festlegen (z. B. Karten/Container einheitlich
    `rounded-lg`, Buttons `rounded-lg`, Inputs `rounded`, kleine Chips
    `rounded-full`) und überall anwenden. „Am besten passend" = ruhig,
    konsistent, zur bestehenden Anmutung.
  - Insbesondere die Auth-Cards (Login/Signup) angleichen (aktuell kantig).
- **Out of scope (explicit)**: Farben/Spacing/Redesign; absichtlich
  vollrunde Elemente (Avatare, Status-Dots) bleiben.

## References
- `frontend/app/(auth)/login/page.tsx`, `signup/page.tsx` — kantige Cards
- `frontend/components/dashboard/MatchRow.tsx` (`rounded-lg`),
  `components/ranking/ScoringInfobox.tsx` (`rounded-xl`),
  `components/dashboard/TipForm.tsx` (Inputs `rounded`)
- generell `components/**`

## Acceptance Criteria
- [ ] Border-Radius nach einer dokumentierten Konvention vereinheitlicht
      (gleiche Element-Typen → gleiche Rundung).
- [ ] Auth-Cards sind nicht mehr kantig (konsistent zu den übrigen Karten).
- [ ] Keine unbeabsichtigt scharfen Ecken bei Karten/Buttons/Inputs.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Login, Signup, Dashboard, Ranking, Match-Detail, Profil durchklicken →
   Ecken/Rundungen wirken einheitlich.
