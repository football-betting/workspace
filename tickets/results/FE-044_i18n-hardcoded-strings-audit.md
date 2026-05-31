# FE-044 — i18n audit: no hardcoded user-visible strings — Result

## Outcome
APPROVED. All acceptance criteria satisfied. Quality Gate green.

## What was done
All raw-English validation messages and API error strings were converted to
stable translation keys under a new `Errors` namespace, present in both
`messages/de.json` and `messages/en.json`. Display components translate the
key returned in `body.error` via `useTranslations("Errors")`, guarded by
`tErrors.has(key)` so an unknown key falls back to the component's localized
default instead of leaking a raw key.

- Validation schemas now emit keys: `lib/validation/auth.ts`,
  `lib/validation/winners.ts` (and `lib/validation/password.ts`, already keyed).
- API routes return keys instead of English sentences across all of `app/api/**`.
- New helper `lib/error-message.ts` `extractErrorKey(body: unknown)` —
  `unknown` + narrowing, no `any`.

## Files changed (frontend only)
- `app/(auth)/login/login-form.tsx`
- `app/(auth)/signup/signup-form.tsx`
- `app/api/auth/login/route.ts`
- `app/api/tip/[matchId]/route.ts`
- `app/api/user/avatar/route.ts`
- `app/api/user/password/route.ts`
- `app/api/user/route.ts`
- `app/api/user/winners/route.ts`
- `components/dashboard/TipForm.tsx`
- `components/profile/WinnerEditForm.tsx`
- `components/settings/PasswordChangeForm.tsx`
- `lib/validation/auth.ts`
- `lib/validation/winners.ts`
- `lib/error-message.ts` (new)
- `messages/de.json`, `messages/en.json` (new `Errors` namespace, 33 keys each)
- `tests/e2e/auth-disclosure.spec.ts`, `tests/e2e/winner-edit.spec.ts`,
  `tests/unit/winners-validation.test.ts` (assertions updated to keys)

## Verification
- `pnpm exec tsc --noEmit` — clean (exit 0).
- `pnpm exec vitest run` — 19 files, 127/127 passed, incl.
  `i18n-messages` parity (identical keys + no empty values) and
  `winners-validation`.
- de/en `Errors` parity: 33 keys each, identical key sets, zero values
  identical across locales (no English copy left in German).
- Login disclosure: single `GENERIC_ERROR = "loginError"` for both
  unknown-email and wrong-password, both after the dummy-hash verify;
  `auth-disclosure.spec.ts` still asserts identical responses. No enumeration.
- HTTP status codes, `Retry-After`/rate-limit headers, redirects, and
  `wantsJson` branches unchanged — only the message string swapped to a key.
- grep of `lib/validation/**` and `app/api/**` for capitalized raw
  `error:`/`message:`/`jsonError("…")` literals returned none.

## Notes for implementer (non-blocking)
Two stray untracked files unrelated to this ticket are present in the working
tree and must NOT be staged with this work:
- `frontend/design/account.html`
- `frontend/scripts/mobile-audit.mjs`
Stage FE-044 with explicit pathspecs only (never `git add -A`).
