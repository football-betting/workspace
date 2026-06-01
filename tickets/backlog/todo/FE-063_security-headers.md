# FE-063 Security-Header (CSP, X-Frame-Options, nosniff, HSTS)

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
high

> Security-Audit 2026-06-01 (MEDIUM). Clickjacking-/Defense-in-depth-Lücke.

## Status
todo

## Owner
implementer

## Background
Die App setzt **keine** Security-Header. Kein `X-Frame-Options`/CSP
`frame-ancestors` → Clickjacking (App im iframe, UI-Redress auf Winner-Pick,
Avatar-Upload, Passwort-Ändern). Kein `nosniff`, kein CSP-Backstop, kein HSTS.

## Findings (Audit)
- `next.config.ts:7-10` — kein `headers()`, keine `middleware.ts`.

## Scope
- **In scope**: `headers()` in `next.config.ts` (oder Middleware) mit mindestens:
  `X-Frame-Options: DENY` (bzw. CSP `frame-ancestors 'none'`),
  `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`,
  `Strict-Transport-Security` (prod), und eine **baseline CSP**. CSP prod-scoped
  (dev braucht `'unsafe-eval'`). PWA/Service-Worker + Material-Symbols/Fonts +
  `NEXT_PUBLIC_VAPID_PUBLIC_KEY`-Flows dürfen nicht brechen.
- **Out of scope**: strenge Nonce-CSP-Migration (separat, falls gewünscht).

## Acceptance Criteria
- [ ] Header auf allen Responses gesetzt (prod), App + PWA funktionieren weiter.
- [ ] App ist nicht mehr iframebar (frame-ancestors/XFO).
- [ ] CSP bricht keine bestehenden Funktionen (Bilder, Fonts, SW, Avatare, Push).
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. DevTools → Response-Header zeigen CSP/XFO/nosniff.
2. App in `<iframe>` einbetten → blockiert.
