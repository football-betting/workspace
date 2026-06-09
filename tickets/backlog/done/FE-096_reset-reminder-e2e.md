# FE-096 E2E for password reset + email reminder settings

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
done

## Owner
implementer

## Background
Two user-facing flows have store/route/unit coverage but **no end-to-end test**
(gap found in FE-095): the password-reset completion (`/reset-password`) and the
reminder settings UI. The mail-send and forgot-password route are already unit
tested (`tests/unit/mail.test.ts`, `tests/unit/forgot-password-route.test.ts`)
and the reset/reminder stores have integration tests — so the missing layer is
purely the browser flow.

## Scope
- **In scope**:
  - E2E `tests/e2e/password-reset.spec.ts`:
    - `/forgot-password` shows the generic confirmation on submit (no
      enumeration).
    - A valid reset token (seeded into `test.db` with the real
      `generateResetToken`/`hashResetToken` helpers) lets a freshly registered
      user set a new password on `/reset-password?token=…`, sign in with the new
      password, and the old password is rejected.
  - E2E `tests/e2e/reminders.spec.ts` (email channel only — push needs a
    service worker and is out of scope):
    - Email reminders are on by default; selecting lead times and saving
      persists across a reload.
    - Turning the email channel off (with push off) disables the lead-time
      controls and shows the "enable a channel" hint.
  - A `seedResetToken(email)` helper in `tests/e2e/helpers.ts`.
- **Out of scope (explicit)**:
  - Push reminders (service worker / web push).
  - Real SMTP delivery in CI (the reset token is seeded directly; the send path
    is already unit-tested).

## References
- `app/(auth)/forgot-password/forgot-password-form.tsx`,
  `app/(auth)/reset-password/reset-password-form.tsx`
- `lib/password-reset.ts` (token gen/hash, TTL), `db/schema.ts`
  (`password_reset_token`)
- `components/settings/ReminderPreferences.tsx`,
  `EmailReminderToggle.tsx`, `ReminderSettings.tsx`
- `lib/reminder-store.ts` (`isEmailEnabled` — on by default, FE-073)
- existing unit/integration coverage (do not duplicate)

## Acceptance Criteria
- [ ] `/forgot-password` submit shows the generic confirmation message.
- [ ] Reset via a seeded token: new password signs in, old password rejected.
- [ ] Email reminder lead-time selection persists across reload.
- [ ] Email off + push off → lead-time controls disabled + hint shown.
- [ ] Quality Gate: `pnpm exec tsc --noEmit`, `pnpm exec vitest run`,
      `pnpm test:e2e` all green; CI `e2e` job green.

## Verification (manual)
1. Run `pnpm test:e2e tests/e2e/password-reset.spec.ts tests/e2e/reminders.spec.ts`
   → all pass.
