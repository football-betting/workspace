# XR-007 Result — Production icons (CSP) + avatar serving

## What was done

Fixed two production-only rendering bugs that appeared once the app was live.

### Icons (Material Symbols rendered as ligature text)
Root cause: the service worker (`@serwist/next` `defaultCache`) re-fetches the
Material Symbols font from Google Fonts with its own `fetch()`. The service
worker script is served with the page CSP, whose `connect-src 'self'` governs a
worker's fetches — so the cross-origin font fetch was blocked and the font never
loaded. No service worker exists in dev, so it only broke in production.

Fix (`frontend/proxy.ts`): added `https://fonts.googleapis.com
https://fonts.gstatic.com` to CSP `connect-src` (already trusted by
`style-src`/`font-src`). Verified the served header now reads
`connect-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com`.

### Avatars (404)
Root cause: `next start` does not serve files written into `public/` at runtime,
so uploaded avatars (`public/uploads/avatars/…`) returned 404.

Fix (`workspace/deploy/nginx/wm.vcec.cloud.conf`): serve `/uploads/` directly
from disk via nginx (`alias …/frontend/public/uploads/`) on both the `:80` and
`:443` server blocks. Verified `GET /uploads/avatars/8.webp` → 200 `image/webp`
at the origin and through the public domain.

## Files changed

- **frontend** (PR #83): `proxy.ts` — CSP `connect-src` adds the Google Fonts
  origins.
- **workspace**: `deploy/nginx/wm.vcec.cloud.conf` — `/uploads/` location.

## Test results

- `pnpm exec tsc --noEmit` clean; `pnpm exec vitest run` green.
- Deployed: frontend rebuilt + `pm2 restart`; nginx reloaded.
- `https://wm.vcec.cloud/uploads/avatars/8.webp` → 200 image/webp.
- Served CSP includes the two font origins in `connect-src`.

## Note

Browsers must pick up the new service worker / CSP — a hard reload (or
Application → Service Workers → Unregister + reload) makes the icons appear.

## Follow-up (optional)

Self-host Material Symbols (e.g. the `material-symbols` package) to drop the
external font dependency entirely — would also render icons offline and let
`connect-src` stay same-origin only.
