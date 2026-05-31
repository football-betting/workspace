# FE-045 Result — Full PWA: Service Worker, Offline, Installable

## Outcome
Approved and moved to `done`. The frontend is now an installable PWA with a
Serwist-generated service worker, a precached offline fallback page, iOS/theme
metadata, a safe-zone maskable icon, and a hard offline-block on tip submission.

Risk: medium. Quality gate + production build green. Integrity-critical paths
(no non-GET cached/queued, `/api/tip` POST never intercepted, no personalized
response persistently cached) verified at the Serwist runtime level, not just
by inspection of the rule list.

## Acceptance criteria — all satisfied
- Production build registers a service worker (`public/sw.js` emitted by the
  Serwist webpack plugin; build log shows the bundling step).
- App installable (manifest + SW + secure context; iOS standalone meta added).
- Offline navigation falls back to the precached `/offline` page.
- Data requests not stale-cached: same-origin `/api/*` GET is `NetworkOnly`.
- Navigations are `NetworkFirst`; offline fallback limited to navigations via
  `navigateFallbackAllowlist` excluding `/api/`.
- No non-GET cached/queued; no authenticated/personalized response persistently
  cached.
- New deploy → fresh app (`skipWaiting` + `clientsClaim` + `cleanupOutdatedCaches`).
- iOS `appleWebApp` meta + `themeColor` set.
- Maskable icon uses new padded safe-zone image.
- Tip submission hard-blocked offline with a localized message; never queued;
  no background sync.
- SW disabled in dev.

## How the integrity guarantee holds (verified)
- Serwist routes are registered per HTTP method; a rule with no explicit method
  defaults to GET (`Route` constructor `method = "GET"`).
- All `defaultCache` rules and the terminal catch-all are GET-only, so the POST
  routes map is empty.
- `findMatchingRoute` queries only `_routes.get(request.method)`. For a POST
  with no match and no default POST handler, `handleRequest` returns `undefined`
  and `handleFetch` skips `respondWith` — the request hits the network as if no
  SW were present.
- Result: `/api/tip/{matchId}` POST, login, winner, avatar POSTs are never
  intercepted, cached, or queued. The prepended `apiNetworkOnly` rule's real
  effect is to make same-origin `/api/*` GET `NetworkOnly`, preventing cross-user
  caching of personalized `/api/user/...` responses.
- The `/offline` page lives at root `app/offline/` (outside the auth-gated
  `(app)` group) and uses only `useTranslations` — no session/db/fetch — so the
  offline fallback renders fully offline for any user.

## Files changed (frontend, uncommitted on `fe-045-pwa-service-worker`)
- `app/sw.ts` (new) — Serwist worker: prepended same-origin `/api/*` NetworkOnly
  (GET), defaultCache, navigate fallback `/offline`, update flow.
- `app/offline/page.tsx` (new) — client offline fallback, i18n only, no data.
- `next.config.ts` — compose `withSerwist(withNextIntl(...))`, disabled in dev,
  `/offline` added to precache with a git-HEAD revision.
- `app/layout.tsx` — `appleWebApp` metadata + `viewport.themeColor`.
- `app/manifest.ts` — maskable icon now points to `icon-maskable-512.png`.
- `components/dashboard/TipForm.tsx` — `navigator.onLine === false` guard
  returns before fetch with `t("offlineBlocked")`.
- `messages/de.json`, `messages/en.json` — `TipForm.offlineBlocked` + `Offline`
  namespace (de/en parity green).
- `package.json` — add `@serwist/next` + `serwist`; `build` → `next build --webpack`.
- `tsconfig.json` — add `webworker` lib; exclude `public/sw.js`.
- `.gitignore` — ignore generated `public/sw.js` / `.map` / `swe-worker-*.js`.
- `public/icon/icon-maskable-512.png` (new) — padded safe-zone maskable icon.

## Test results
- `bash scripts/check.sh --build`: `tsc --noEmit` clean; vitest 151/151 passed;
  `next build --webpack` succeeded with the Serwist bundling step.

## Notes / follow-ups
- `build` switched to `--webpack` because Serwist's webpack plugin does not hook
  Next 16's default Turbopack (the SW would not be emitted otherwise). Acceptable;
  minor divergence since `next dev` still uses Turbopack.
- Advisory test gap: no unit test for the `navigator.onLine === false` tip guard.
  Recommended as a follow-up given it is the integrity-critical UI path.
- When committing, use explicit pathspecs. Two unrelated untracked files exist in
  the tree (`design/account.html`, `scripts/mobile-audit.mjs`) and must NOT be
  staged; never `git add -A`.
