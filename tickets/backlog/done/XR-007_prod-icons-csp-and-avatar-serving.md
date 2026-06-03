# XR-007 Production: Material Symbols icons blocked by CSP + avatars 404

## Repo
multi

> frontend (`proxy.ts` CSP) + workspace (`deploy/nginx` for `/uploads/`).

## Type
bug

## Risk
medium

## Priority
high

## Background
On the production deployment two rendering bugs appeared:
1. **Icons missing** — Material Symbols icons render as their ligature text
   (`save`, `person`, `wifi_off`, …) instead of the glyphs.
2. **Avatars don't load** — `https://wm.vcec.cloud/user/8` shows a broken
   profile photo.

## Symptom (bugs only)
- Icons: the `<link>` to `fonts.googleapis.com` and the CSP `style-src`/
  `font-src` are correct, but the service worker (`@serwist/next` `defaultCache`)
  intercepts the Google-Fonts requests and re-fetches them with `fetch()`. The
  service worker script is served with the page CSP `connect-src 'self'`, which
  governs a worker's own fetches — so the cross-origin font fetch is blocked and
  the font never loads. (No service worker in dev, so it only breaks in prod.)
- Avatars: `GET /uploads/avatars/8.webp` → 404 even though the file exists at
  `frontend/public/uploads/avatars/8.webp`. `next start` does not serve files
  written into `public/` after the server started, so runtime-uploaded avatars
  are not served by Next.

## Scope
- **In scope**:
  - `frontend/proxy.ts`: add `https://fonts.googleapis.com https://fonts.gstatic.com`
    to the CSP `connect-src` so the service worker may fetch/cache the icon font
    (these origins are already allowed in `style-src`/`font-src`).
  - `workspace/deploy/nginx/wm.vcec.cloud.conf`: serve `/uploads/` directly from
    `frontend/public/uploads/` via nginx (bypasses Next's runtime public-file
    limitation; standard way to serve user uploads).
- **Out of scope (explicit)**:
  - Self-hosting Material Symbols (a possible future hardening that would also
    fix offline icons and let `connect-src` stay strict).
  - Changing how/where avatars are stored.

## References
- `frontend/proxy.ts` (CSP)
- `frontend/app/layout.tsx` (Material Symbols `<link>`), `app/sw.ts`
- `frontend/app/api/user/avatar/route.ts` (writes `public/uploads/avatars/…`)
- `workspace/deploy/nginx/wm.vcec.cloud.conf`

## Acceptance Criteria
- [ ] In production the Material Symbols glyphs render (not the ligature text).
- [ ] `GET /uploads/avatars/<file>` returns the image (200) and `/user/<id>`
      shows the uploaded photo.
- [ ] CSP still denies everything else (`connect-src` only adds the two font
      origins already trusted by `style-src`/`font-src`).
- [ ] Quality Gate green: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Hard-reload the production site → icons render as glyphs.
2. Open a profile that has an uploaded photo → the photo loads.
3. `curl -I https://wm.vcec.cloud/uploads/avatars/<file>` → 200 image.

## Notes (multi-repo only)
1. `frontend/proxy.ts` — CSP `connect-src` (PR).
2. `workspace/deploy/nginx/wm.vcec.cloud.conf` — `/uploads/` location; apply on
   the server and reload nginx.
