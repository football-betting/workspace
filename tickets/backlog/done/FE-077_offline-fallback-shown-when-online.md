# FE-077 Offline page shown when online + unstyled offline fallback

## Repo
frontend

## Type
bug

## Risk
medium

## Priority
high

## Status
todo

## Owner
implementer

## Background
On the production deployment the service worker is active (Serwist is disabled
in dev). After a successful login the user is shown the PWA **offline page**
instead of the dashboard, even though they are online — and that offline page
renders unstyled (the Material Symbols icon shows as the literal text
`wifi_off`, the layout is broken).

## Symptom (bugs only)
1. Log in in a normal browser → redirected to `/` → the `/offline` page appears
   although the network is up and the server returns the dashboard (verified:
   `GET /` with a valid session returns the full dashboard, HTTP 200).
2. The `/offline` page is unstyled: icon rendered as `wifi_off` text, no
   centering, text wraps per word.

## Root cause
- `app/sw.ts` uses `precacheOptions.navigateFallback: "/offline"` with a broad
  `navigateFallbackAllowlist`. That is the SPA app-shell pattern: it serves the
  precached fallback for **every** navigation whose URL is not itself precached.
  Next.js routes are server-rendered (not precached), so once the SW activates
  (`clientsClaim`) it serves `/offline` for normal online navigations. The
  correct Serwist pattern is the `fallbacks` option, which only serves the
  fallback when a caching strategy **fails** (i.e. actually offline).
- The offline page depends on `globals.css` and an external Google-Fonts
  Material Symbols stylesheet, so when served bare it loses its styling/icon.

## Scope
- **In scope**:
  - `app/sw.ts`: replace `precacheOptions.navigateFallback` /
    `navigateFallbackAllowlist` with Serwist's `fallbacks` option
    (`matcher: request.destination === "document"`, url `/offline`).
  - `app/offline/page.tsx`: make the page self-contained — inline SVG icon (no
    Material Symbols font dependency) and inline styles (no dependency on
    `globals.css`), so it renders correctly even when served offline. Keep the
    `Offline.title` / `Offline.description` translations.
- **Out of scope**: other PWA/caching behaviour; the rest of the SW (push,
  notification click, API NetworkOnly) stays unchanged.

## References
- `frontend/app/sw.ts`
- `frontend/app/offline/page.tsx`
- `frontend/next.config.ts` (Serwist `additionalPrecacheEntries: ["/offline"]`)
- Serwist docs: `fallbacks` option (official @serwist/next getting-started).

## Acceptance Criteria
- [ ] Logging in while online lands on the dashboard, not `/offline`.
- [ ] `/offline` is shown only when navigating while actually offline.
- [ ] The `/offline` page renders styled with a real icon (not the text
      `wifi_off`) even with no external CSS/font available.
- [ ] Quality Gate green: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Deploy, hard-reload once (to pick up the new SW), log in → dashboard renders.
2. DevTools → Network → Offline → navigate to an unvisited route → styled
   `/offline` page with the icon.
3. Re-enable network → navigation works again.
