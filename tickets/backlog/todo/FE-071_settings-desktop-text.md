# FE-071 Settings auf Desktop als Text (Icon nur Mobile)

## Repo
frontend
## Type
bug
## Risk
low
## Priority
low
> User (2026-06-02): das Settings-Zahnrad-Icon passt für Mobile, aber auf Desktop (sonst nur Text) wirkt es inkonsistent.

## Status
todo
## Owner
implementer

## Background
`components/dashboard/TopAppBar.tsx` (Desktop) rendert Settings als
`material-symbols-outlined`-Zahnrad-Icon, während Dashboard/Rangliste/Profil
Text-Labels sind. Auf Desktop gibt es sonst keine Nav-Icons → das eine Zahnrad
wirkt deplatziert. Auf Mobile (BottomNav) ist das Icon ok.

## Scope
- **In scope**: In `TopAppBar` das Settings-Zahnrad durch ein **Text-Label**
  (`t("settings")`) ersetzen, konsistent mit den anderen Desktop-Nav-Einträgen
  (Aktiv-Zustand beibehalten). BottomNav (Mobile) bleibt mit Icon.
- **Out of scope**: Nav-Redesign; Mobile.

## Acceptance Criteria
- [ ] Desktop-Header: „Einstellungen"/„Settings" als Text, kein Zahnrad-Icon.
- [ ] Aktiv-Zustand (auf /settings) korrekt markiert.
- [ ] Mobile-BottomNav unverändert (Icon bleibt).
- [ ] Quality Gate: `bash scripts/check.sh`.
