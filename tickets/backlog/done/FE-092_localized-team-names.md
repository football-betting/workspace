# FE-092 Localize team names in winner selectors

## Repo
frontend

## Type
fix

## Risk
low

## Background
The Tournament Winner and Secret Winner dropdowns (sign-up + profile editor)
always showed German team names, even in English. Reported: "Secret Winner sind
auf Deutsch wenn ich EN gebe".

## What changed
- `lib/data/teams.ts`: each team now carries `de` + `en` names; added
  `teamName(code, locale)` and `localizedTeams(locale)` (localized + sorted by
  the active language). `TEAM_CODES`/`isTeamCode` unchanged.
- `signup-form.tsx`, `components/profile/WinnerEditForm.tsx`: render via
  `localizedTeams(useLocale())` instead of the hardcoded German name.

## Acceptance / verification
- tsc clean, vitest 191 passed.
- Live SSR check: `locale=de` → "Deutschland/Brasilien"; `locale=en` →
  "Germany/Brazil". PR #101, deployed.
