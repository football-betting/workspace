# FE-053 Ranking-Tabs auf Mobile abgeschnitten („Mainz")

## Repo
frontend

## Type
bug

## Risk
low

## Priority
low

## Status
todo

## Owner
implementer

## Background
Auf der Ranking-Seite werden die Standort-Tabs (Global, Langenfeld, Mannheim,
Mainz) auf Mobile am rechten Rand abgeschnitten — „MAINZ" erscheint als „MAIN"
(Mobile-Audit FE-040). Die Tab-Leiste ist zwar `overflow-x-auto`, aber der
letzte Tab wirkt abgeschnitten statt klar scrollbar.

## Symptom (bugs only)
`/ranking` auf Mobile → letzter Tab „MAINZ" am rechten Rand abgeschnitten.

## Scope
- **In scope**: `components/ranking/RankingTabs.tsx` (und ggf. `TabBar.tsx`)
  mobil sauber machen — entweder horizontal scrollbar mit klarem Hinweis
  (kein hartes Abschneiden), kleinerer Tab-Abstand/Schrift, oder Umbruch, sodass
  alle Tabs erreichbar/lesbar sind.
- **Out of scope**: Tab-Logik/Filter; Desktop.

## References
- `frontend/components/ranking/RankingTabs.tsx`,
  `frontend/components/dashboard/TabBar.tsx`

## Acceptance Criteria
- [ ] Mobile: alle Standort-Tabs lesbar/erreichbar (kein hart abgeschnittener
      letzter Tab).
- [ ] Aktiv-Zustand bleibt korrekt.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. `/ranking` auf Mobile → „Mainz" vollständig sichtbar oder klar scrollbar.
