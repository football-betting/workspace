# FE-087 — Result

## What was done
Made the settings "Install the app" affordance mobile-only and reliable. The
`beforeinstallprompt` signal also fires on desktop Chrome and fires once early in
the page lifecycle, so the previous component (which listened only after the
settings page mounted) showed the card on Desktop yet missed it on Android.

The installability signal is now captured app-wide by an `InstallProvider` in the
root layout, and `InstallApp` decides visibility from the device (UA): shown on
Android/iOS, hidden on Desktop and when already installed. Android without a
captured prompt falls back to a manual "browser menu → Install app" hint.

## Files changed
### frontend
- `components/InstallContext.tsx` (new) — `InstallProvider` + `useInstall()`.
- `app/layout.tsx` — wraps children in `InstallProvider`.
- `components/InstallApp.tsx` — device-gated rendering, consumes the hook.
- `messages/de.json`, `messages/en.json` — `Install.androidHint`.

## Tests / quality gate
- `tsc --noEmit`: clean.
- i18n de/en parity test: green.
- PR #96 (squash-merged), deployed to production and verified.
