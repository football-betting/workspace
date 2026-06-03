# FE-077 Result — Offline page shown when online + unstyled offline fallback

## What was done

Fixed the production bug where, after login, the PWA offline page was shown
instead of the dashboard even though the user was online, and that offline page
rendered unstyled.

- **Root cause**: `app/sw.ts` used `precacheOptions.navigateFallback: "/offline"`
  (the SPA app-shell pattern). Once the service worker activated
  (`clientsClaim`), it served the precached `/offline` for every navigation to a
  server-rendered (non-precached) route — i.e. for normal online navigations.
  The server itself was fine (`GET /` with a session returns the dashboard, 200).
- **Fix (service worker)**: replaced `navigateFallback` /
  `navigateFallbackAllowlist` with Serwist's `fallbacks` option
  (`{ url: "/offline", matcher: request.destination === "document" }`). The
  offline page is now served **only when a navigation actually fails** (offline);
  online navigations go to the network as normal. Verified in the generated
  `public/sw.js`: the `navigateFallback` NavigationRoute is no longer registered
  and `/offline` is wired as a document fallback.
- **Fix (offline page)**: `app/offline/page.tsx` is now fully self-contained —
  an inline SVG wifi-off icon (no Material Symbols web font) and inline styles
  (no dependency on `globals.css`), so it renders correctly with the dark theme
  even when served with no network/external assets. Translations
  (`Offline.title` / `Offline.description`) are kept.

## Files changed

**frontend** (PR #82)
- `app/sw.ts` — `fallbacks` option instead of `precacheOptions.navigateFallback`.
- `app/offline/page.tsx` — self-contained inline icon + inline styles.

## Test results

- `pnpm exec tsc --noEmit` clean; `pnpm exec vitest run` 191 passed.
- Deployed to production: rebuilt, `pm2 restart`; `https://wm.vcec.cloud/login`
  and `/sw.js` → 200; generated SW confirms the fallback wiring.

## Note

Existing browsers hold the old service worker; it auto-updates on the next visit
(`skipWaiting` + `clientsClaim`). A single hard reload (or closing the tab) picks
up the fixed worker immediately.
