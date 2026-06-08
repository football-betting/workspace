# FE-088 Allow Cloudflare Web Analytics beacon in CSP

## Repo
frontend

## Type
fix

## Risk
low

## Background
Cloudflare auto-injects its Web Analytics beacon (`beacon.min.js` from
`static.cloudflareinsights.com`, posting RUM data to `cloudflareinsights.com`) on
the proxied origin. The site CSP (`script-src 'self' 'unsafe-inline'`) did not
list those origins, so the browser blocked the beacon and logged a CSP violation
on every page load. The app was unaffected, but the console error was noisy and
the analytics never ran. Reported live from the browser console.

## Scope
- in: `proxy.ts` CSP (`script-src`, `connect-src`).
- out: nothing else; no other external origins added.

## What changed
- `script-src` += `https://static.cloudflareinsights.com`.
- `connect-src` += `https://cloudflareinsights.com`.

## Acceptance / verification
- Live `Content-Security-Policy` header lists both Cloudflare origins.
- No more CSP violation for the beacon in the console.
- Quality gate: tsc clean. PR #97, deployed.
