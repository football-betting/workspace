# FE-091 Branded tip-reminder email + dashboard link

## Repo
frontend

## Type
feature

## Risk
low

## Background
The tip-reminder email was bare `<p>` HTML with no branding, and its CTA (and the
push click target) pointed at a single match detail page. Requested: brand the
email like the app and land users on the dashboard, where they can tip directly.

## What changed
- `lib/mail.ts`: branded HTML reminder (dark surface, coral CTA, "WM '26 — a
  valantic guessing game" header), table layout + inline styles for email-client
  compatibility; dynamic values HTML-escaped.
- `app/api/cron/notifications/route.ts`: reminder link (email + push) now points
  at the dashboard (`/`) instead of `/match/{id}`.

## Acceptance / verification
- tsc clean, vitest 191 passed.
- Live test: styled email received (logo + coral "JETZT TIPPEN" button), link to
  dashboard. User confirmed it looks good. PR #100, deployed.
