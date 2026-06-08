# FE-087 App-install prompt: mobile only + reliable capture

## Repo
frontend

## Type
fix

## Risk
low

## Background
The settings "Install the app" card relied on the browser `beforeinstallprompt`
signal alone. That signal also fires on desktop Chrome, so the card showed up on
Desktop (unwanted), while on Android it frequently did not appear at all — the
signal fires once, early on first page load, before the settings page and its
listener had mounted. Reported live: "App-Installation auf Android funktioniert
nicht, ich sehe das bei Desktop".

## Scope
- in: `components/InstallApp.tsx`, new `components/InstallContext.tsx`,
  `app/layout.tsx`, `Install` message namespace (de/en).
- out: manifest/icons, service worker.

## What changed
- New `InstallProvider` (mounted in the root layout) captures
  `beforeinstallprompt`/`appinstalled` app-wide as soon as the app loads, exposed
  via a `useInstall()` hook (`canInstall`, `installed`, `install()`).
- `InstallApp` now gates on the device (UA), not on the signal: Android/iOS only,
  hidden on Desktop and when already installed.
- Android with no captured prompt → manual "browser menu → Install app" hint
  (`Install.androidHint`, de/en).

## Acceptance / verification
- Desktop: card hidden (even when `beforeinstallprompt` fires).
- Android: native install button when available, else manual hint.
- iPhone: Share → Add-to-Home-Screen hint.
- Quality gate: tsc clean, i18n de/en parity green. PR #96, deployed.
