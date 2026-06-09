# FE-096 Result — E2E for password reset + email reminders

## What was done

Closed the two end-to-end gaps found in FE-095. The mail-send, the
forgot-password route and the reset/reminder stores already had unit/integration
coverage, so this adds only the missing browser-level flows.

## Files changed (frontend, branch `fe-096-reset-reminder-e2e`)

- `tests/e2e/helpers.ts` — new `seedResetToken(email)`: issues a valid reset
  token straight into `test.db` (real `generateResetToken`/`hashResetToken`,
  stores the hash) and returns the raw token, so an E2E can drive
  `/reset-password` the way the email link would. (Also fixed the test-DB path
  to mirror `setup.ts`.)
- `tests/e2e/password-reset.spec.ts` — **new**:
  - `/forgot-password` shows the generic confirmation (no enumeration).
  - A seeded token lets a freshly registered user set a new password, sign in
    with it, and the old password is then rejected.
  - An invalid token is rejected (no success state).
- `tests/e2e/reminders.spec.ts` — **new** (email channel only; push is out of
  scope — needs a service worker):
  - Email reminders on by default; selecting a lead time + saving persists
    across a reload.
  - Turning the email channel off (push off) shows the "enable a channel" hint
    and disables the lead-time controls; re-enabling restores them. Leaves the
    shared seeded user back in its default state.

## Test results
- `pnpm exec tsc --noEmit` — clean
- New specs: 4 passed (~8s)
- Full E2E suite: **52 passed, 1 skipped** (~46s), no regressions

## Notes
- Push reminders deliberately not covered (service worker / web push).
- Real SMTP delivery not exercised in CI — the reset token is seeded directly
  and the send path is already unit-tested (`tests/unit/mail.test.ts`,
  `tests/unit/forgot-password-route.test.ts`).
