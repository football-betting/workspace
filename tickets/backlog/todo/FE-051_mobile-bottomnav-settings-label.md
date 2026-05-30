# FE-051 Mobile BottomNav: „Einstellungen" abgeschnitten

## Repo
frontend

## Type
bug

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Seit FE-032 hat die Bottom-Navigation 4 Einträge (Dashboard, Rangliste, Profil,
Einstellungen). Auf Mobile wird der 4. Eintrag „EINSTELLUNGEN" abgeschnitten
(„EINSTELLU…") — gefunden im Mobile-Audit (FE-040) auf jeder eingeloggten Seite.

## Symptom (bugs only)
Mobile (≤ ~390px), eingeloggt → BottomNav: „EINSTELLUNGEN" ist abgeschnitten.

## Scope
- **In scope**: `components/dashboard/BottomNav.tsx` so anpassen, dass alle 4
  Labels passen — z. B. kürzeres Label/Abkürzung, kleinere Schrift,
  gleichmäßige Verteilung, ggf. nur Icon + sehr kurzes Label. i18n-Keys nutzen
  (kein hartcodierter String), de/en.
- **Out of scope**: Redesign der Nav; Desktop-TopAppBar.

## References
- `frontend/components/dashboard/BottomNav.tsx`
- `frontend/messages/de.json`/`en.json` (`Nav.settings`)

## Acceptance Criteria
- [ ] Auf 360–414px sind alle 4 Nav-Labels vollständig lesbar (kein „…").
- [ ] Aktiv-Zustand + Icons bleiben korrekt.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Mobile-Viewport, eingeloggt → BottomNav zeigt „Einstellungen" vollständig.
