# [002] Implement login and signup pages

## Repo
frontend

## Type
feature

## Risk
medium

> Auth boundary — any mistake here lets anyone in. Reviewer must check
> session handling, password validation, and error-message disclosure.

## Priority
high

## Status
todo

## Owner
implementer

## Background
Users need to be able to register and sign in before they can use any other
page. This is the entry point of the application.

Login takes email + password and creates a Lucia session.
Signup takes email, password (with confirmation), first/last name, username,
department (3 fixed options), tournament winner and secret winner predictions
(24 team options each).

## Scope

**In scope:**
- `app/(auth)/login/page.tsx` — login form per `frontend/design/login.html`
- `app/(auth)/signup/page.tsx` — signup form per `frontend/design/signup.html`
- `app/api/auth/login/route.ts` — POST handler with Argon2id verification
- `app/api/auth/logout/route.ts` — POST handler (note: **POST** not GET, see spec §19.1)
- `app/api/user/route.ts` — POST handler for signup
- `lib/data/teams.ts` — 24 EM/WM team constants (ISO3 codes)
- `lib/data/departments.ts` — exported from FE-001 (DB values + display map)
- Client-side validation: email format (Zod), password length, `password === rePassword`
- Server-side validation with Zod schemas
- **Security hardening** (spec §19.1):
  - Password policy: min 8 characters (server-enforced via Zod, client-mirror)
  - Email format validation via Zod `.email()` server-side
  - Rate-limit on `POST /api/auth/login` and `POST /api/user`
    (5 requests / 10 min per IP — in-memory limiter is fine for now)
  - Generic login error message (no email-existence disclosure)
  - Explicit Argon2id parameters (memorySize 19456, iterations 2,
    tagLength 32, parallelism 1)

**Out of scope (explicit):**
- Password reset flow (`/password-forget` is a stub in the old repo; deferred)
- Social login
- Email verification

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (page table), §5.1 + §5.2 (handlers),
  §19.1 (security improvements)
- `frontend/design/login.html` — visual reference (apply fixes from CHANGES.md)
- `frontend/design/signup.html` — visual reference (apply fixes from CHANGES.md)
- `frontend/design/CHANGES.md` §login.html + §signup.html for required edits
- `em2024-frontend/src/pages/api/auth/login.ts` — reference for handler logic
- `em2024-frontend/src/pages/api/user/index.ts` — reference for signup logic

## Acceptance Criteria

### Login
- [ ] `GET /login` renders form with email + password fields, "Sign In"
      button, link to `/signup`
- [ ] Logged-in user visiting `/login` is redirected to `/`
- [ ] `POST /api/auth/login` with valid credentials → session cookie set
      + 302 redirect to `/`
- [ ] **Generic error message** for both "email not found" and "wrong
      password" → 400 `"Email or password incorrect."` (identical wording,
      identical status, identical response timing within reason — verified
      manually below)
- [ ] Invalid email format (Zod `.email()`) → 400 `"Invalid email"`
- [ ] Password shorter than 8 chars → 400 `"Invalid password"`
- [ ] After successful login, session cookie has `httpOnly`, `secure` in
      prod, `sameSite: 'lax'`
- [ ] **Rate-limit**: 6th login attempt from the same IP within 10 minutes
      → 429 `"Too many requests, try again later."`

### Signup
- [ ] `GET /signup` renders form with: First Name, Last Name, Username,
      Email, **Password**, **Repeat Password**, Department, Tournament
      Winner, Secret Winner
- [ ] Department dropdown lists exactly: Langenfeld, Mannheim, Mainz
- [ ] Winner + Secret Winner dropdowns list all 24 teams from `lib/data/teams.ts`
- [ ] Client-side: `password !== rePassword` → inline error, no submit
- [ ] Server-side: missing fields → 400 with field list (fix the `s`-suffix
      bug from spec §6 — proper pluralisation)
- [ ] Server-side: `winner === secretWinner` → 400
      `"Winner and secret winner must differ."`
- [ ] Server-side: duplicate email → 400
      `"This email is already registered."`
- [ ] Password hashed with `Argon2id` (memorySize 19456, iterations 2,
      tagLength 32, parallelism 1)
- [ ] Password Zod schema enforces ≥8 characters server-side
- [ ] Email Zod schema uses `.email()`
- [ ] **Rate-limit**: 6th signup attempt from the same IP within 10 minutes
      → 429 `"Too many requests, try again later."`
- [ ] On success → 302 redirect to `/login?registered=true`
- [ ] `/login?registered=true` shows a success banner

### Logout
- [ ] `POST /api/auth/logout` invalidates the Lucia session, clears the
      cookie, redirects to `/login`
- [ ] `GET /api/auth/logout` returns 405 Method Not Allowed (CSRF-safe)

### Design
- [ ] All scoring/feature exclusions from `CHANGES.md` applied
      ("Security Credential" → "Password", "Public Champion" →
      "Tournament Winner", "Secret Dark Horse" → "Secret Winner", remove
      fake taglines and version footers)
- [ ] No inline SVG; Material Symbols for icons (`mail`, `lock`, `person`)
- [ ] Stadium background via CSS gradient (no external image URL)

## Verification (manual)

1. `pnpm dev` → open `/signup`
2. Fill all fields, set `winner = DEU`, `secretWinner = DEU` → submit →
   inline error "Winner and secret winner must differ."
3. Set `secretWinner = ESP`, mismatched passwords → submit → inline error
4. Try password `1234` (too short) → 400 "Invalid password"
5. Fix passwords (≥8 chars) → submit → land on `/login?registered=true`
   with success banner
6. Login with the new credentials → redirected to `/`
7. **Email-existence disclosure check:** open `/login`, try `unknown@example.com`
   with random password → response says `"Email or password incorrect."`
   Then try the **real** email with a wrong password → response says
   exactly the same. Two identical responses = no disclosure.
8. **Rate-limit check:** fire 6 rapid login attempts with wrong creds from
   the same browser → 6th attempt returns 429 "Too many requests…"
9. Logout via UI → land on `/login`
10. Try `curl http://localhost:3000/api/auth/login -d 'email=x&password=y'`
    → 403 (Origin check)
11. Try `curl -X GET http://localhost:3000/api/auth/logout` → 405
    (POST-only logout)

## Notes

This ticket depends on **001_bootstrap-frontend**.
