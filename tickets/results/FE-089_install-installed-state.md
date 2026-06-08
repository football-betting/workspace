# FE-089 — Result

## What was done
Made the settings install affordance robust on real devices. The install signal
is now captured by an inline script before React hydrates (so it is never missed
by a late-mounting component), and the card detects when the PWA is already
installed via `getInstalledRelatedApps()` and then hides itself instead of
showing a manual install hint.

Diagnosed the user's Pixel "no button" report: the app was already installed, so
Chrome correctly stopped firing the install prompt — confirmed by the user.

## Files changed
### frontend
- `app/layout.tsx` — inline pre-hydration capture script in `<head>`.
- `components/InstallContext.tsx` — adopt the captured prompt; mark installed via
  `getInstalledRelatedApps()`.

## Tests / quality gate
- `tsc --noEmit`: clean.
- PR #98 (squash-merged), deployed to production.
