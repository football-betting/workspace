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
- `lib/data/departments.ts` — 3 department constants (Langenfeld, Mannheim, Mainz)
- Client-side validation: email format (Zod), password length, `password === rePassword`
- Server-side validation with Zod schemas

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
- [ ] Wrong password → 400 with **generic** error message
      (`"Email or password incorrect."` — no disclosure whether email exists)
- [ ] Missing/short email → 400 `"Invalid email"`
- [ ] Missing/short password → 400 `"Invalid password"`
- [ ] After successful login, session cookie has `httpOnly`, `secure` in
      prod, `sameSite: 'lax'`

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
4. Fix passwords → submit → land on `/login?registered=true` with success
   banner
5. Login with the new credentials → redirected to `/`
6. Logout via UI → land on `/login`
7. Try `curl http://localhost:3000/api/auth/login -d 'email=x&password=y'`
   → 403 (Origin check)

## Notes

This ticket depends on **001_bootstrap-frontend**.
