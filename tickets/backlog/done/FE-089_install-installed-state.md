# FE-089 Install card: reliable capture + already-installed state

## Repo
frontend

## Type
fix

## Risk
low

## Background
On a Pixel where the app was already installed, the settings install card kept
showing the manual "browser menu → install" hint — confusing, since there is
nothing left to install. The `beforeinstallprompt` signal also fires once very
early, so a client-only listener could miss it.

## Scope
- in: `app/layout.tsx` (inline pre-hydration capture script),
  `components/InstallContext.tsx`.
- out: `InstallApp.tsx` rendering (unchanged), manifest.

## What changed
- Inline head script captures `beforeinstallprompt`/`appinstalled` before React
  hydrates, into `window.__wmInstall`; `InstallProvider` adopts it (direct
  listeners kept as fallback).
- `InstallProvider` calls `navigator.getInstalledRelatedApps()` — if the PWA is
  installed on the device, `installed=true` → the card hides instead of showing
  a stale install hint.

## Acceptance / verification
- Already-installed device: card hidden (no confusing hint).
- Not installed (Android): native button reliably appears.
- Quality gate: tsc clean. PR #98, deployed. Confirmed live by user (device was
  still installed).
