# FE-091 — Result

## What was done
Rebuilt the tip-reminder email as a branded, app-styled HTML message (wordmark,
dark surface, coral CTA), using a table layout with inline styles so it renders
across email clients, and escaped the dynamic values. Pointed the reminder CTA —
in both the email and the push notification — at the dashboard, where matches
are tipped directly.

## Files changed
### frontend
- `lib/mail.ts` — branded reminder HTML + escaping.
- `app/api/cron/notifications/route.ts` — link target → dashboard.

## Tests / quality gate
- `tsc --noEmit`: clean. `vitest run`: 191 passed.
- Live: styled email + push delivered and confirmed by the user. PR #100,
  deployed.
