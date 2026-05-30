# FE-038 Result — Registrierung: in Production nur valantic.com-Emails

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `97bdcf7 FE-038: production-only valantic.com signup email restriction + hint (#39)` (squash-merge von PR #39)

## Was wurde gemacht

- `lib/validation/auth.ts`: reine Helper-Funktion
  `isAllowedSignupEmailDomain(email)` — Domain (nach `@`, lowercase) muss
  `=== "valantic.com"` sein **oder** auf `.valantic.com` enden (label-sicher:
  weist `valantic.com.evil.com`, `evilvalantic.com`, `gmail.com` ab). Im
  `signupSchema` per `.refine` **nur aktiv wenn `NODE_ENV === "production"`**
  — Dev/Test (inkl. `@local.dev`-Seed) akzeptieren jede Email.
- Server: `app/api/user/route.ts` parst `signupSchema` serverseitig → Regel
  nicht per Direct-API umgehbar.
- `signup-form.tsx`: Hinweis `Auth.valanticEmailHint` (de/en) am Email-Feld.

## Geänderte Dateien (frontend)
- `lib/validation/auth.ts`, `app/(auth)/signup/signup-form.tsx`,
  `messages/de.json`, `messages/en.json`, `tests/unit/validation.test.ts`

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **98/98** (inkl. 18 Validation-Tests
  mit Trick-Domains + NODE_ENV-Gate); `--build` → ok.

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** — Domain-Check bypass-sicher, Production-gated,
server-enforced, i18n-Parität, kein `any`/`NEXT_PUBLIC_`.
