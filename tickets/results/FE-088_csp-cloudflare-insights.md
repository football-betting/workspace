# FE-088 — Result

## What was done
Allowed Cloudflare's auto-injected Web Analytics beacon through the site CSP so
it is no longer blocked and no longer logs a console violation on every page
load. The app was never broken by this — only the beacon and a noisy error.

## Files changed
### frontend
- `proxy.ts` — `script-src` += `https://static.cloudflareinsights.com`;
  `connect-src` += `https://cloudflareinsights.com`.

## Tests / quality gate
- `tsc --noEmit`: clean.
- Verified live: `Content-Security-Policy` response header on `/login` lists both
  Cloudflare origins.
- PR #97 (squash-merged), deployed to production.
