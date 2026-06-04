# FE-080 Install-the-app prompt in settings

## Repo
frontend

## Type
feature

## Risk
low

## Background
Users had no clear way to discover that the site is installable as an app. Add a
non-intrusive install affordance in the account area (after login), not a pushy
first-visit banner.

## What changed
- `components/InstallApp.tsx`: client component. Android/Chrome → native install
  dialog via captured `beforeinstallprompt`; iOS/Safari → Share → Add to Home
  Screen instruction; desktop or already-installed (standalone) → renders null.
- Added to `/settings` (account area → only after login).
- `Install` message namespace (de/en), no "PWA" wording.

## Acceptance / verification
- Android: Install button triggers the native dialog.
- iPhone: shows the Add-to-Home-Screen hint.
- Desktop / installed: hidden.
- Quality gate: tsc clean, vitest 191 passed (de/en parity ok). PR #87, deployed.
