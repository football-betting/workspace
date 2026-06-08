# FE-092 — Result

## What was done
Made the tournament/secret winner team names follow the chosen language. Team
data now holds German and English names; both winner dropdowns (sign-up and the
profile editor) render the active-locale name, sorted alphabetically for that
language. Validation (codes only) and the schema are unaffected.

## Files changed
### frontend
- `lib/data/teams.ts` — `de`/`en` names + `teamName`/`localizedTeams` helpers.
- `app/(auth)/signup/signup-form.tsx` — locale-aware options.
- `components/profile/WinnerEditForm.tsx` — locale-aware options.

## Tests / quality gate
- `tsc --noEmit`: clean. `vitest run`: 191 passed.
- Verified live: signup SSR shows German names under `locale=de` and English
  under `locale=en`. PR #101, deployed.
