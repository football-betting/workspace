# [FE-011] Redirect unauthenticated users to /login

## Repo
frontend

## Type
feature

## Risk
medium

> Auth boundary — affects every protected route. Reviewer must verify
> there is no leak path (Server Component reads user data before redirect,
> client-rendered fallback flashes private content, etc.).

## Priority
high

> Jumps the original FE-007→FE-003 queue. Reason: user reported the
> missing redirect on 2026-05-28 and asked for it before any further
> feature work. Unblocks the auth pattern that FE-003/004/005/006 will
> all need, so it has compounding value.

## Status
todo

## Owner
implementer

## Background
Right now `/` is a public placeholder page. Per the spec (§3 page
table — every route except `/login`, `/signup`, `/password-forget`
requires auth), `/` must redirect unauthenticated visitors to `/login`.
Today, an unauthenticated visitor sees the "Bootstrap OK" placeholder,
which is wrong and will become a leak path as soon as FE-003 builds
the real dashboard.

This ticket installs the **auth-guard pattern** that FE-003 (dashboard),
FE-004 (ranking), FE-005 (match detail) and FE-006 (profile) will all
inherit, so the redirect logic is written once and reused.

## Scope

**In scope:**
- Introduce the `app/(app)/` route group for **all** protected pages.
- Move `app/page.tsx` → `app/(app)/page.tsx` (still serves `/`).
- Add `app/(app)/layout.tsx` — Server Component that reads
  `getCurrentSession()` and `redirect('/login')` when no user.
- The `(app)` layout is the **only** place the redirect lives — individual
  page files inside it must not duplicate the check.
- Confirm `app/(auth)/login/page.tsx` and `app/(auth)/signup/page.tsx`
  still redirect logged-in users to `/` (already in place from FE-002 —
  this ticket must not regress that behaviour).
- A short prose note in `lib/session.ts` (or a sibling file) documenting
  "use the (app) layout for auth guards" so FE-003+ implementers don't
  rebuild this per-page.

**Out of scope (explicit):**
- Real dashboard content (that is FE-003)
- Sign-out button / nav bar (FE-003 builds the chrome)
- Per-role authorization (we only have one role today)
- Middleware-based redirect (a layout guard is enough and keeps the
  redirect logic in one obvious place — middleware would complicate
  the (auth)/(app) split unnecessarily)

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (which routes require auth),
  §4.4 (the legacy Astro page-guard pattern we are porting)
- `frontend/lib/session.ts` — `getCurrentSession()` from FE-002, returns
  `{ user, session } | { user: null, session: null }`
- `frontend/app/(auth)/login/page.tsx` — already redirects logged-in
  users to `/` (mirror of this ticket's logic in the opposite direction)
- Next.js App Router docs on route groups: parentheses in folder names
  group routes without affecting the URL

## Acceptance Criteria

### Redirect behaviour
- [ ] `GET /` unauthenticated → 307/308 to `/login` (Next.js `redirect()`
      default is fine, whichever it picks)
- [ ] `GET /` authenticated → renders the page (current placeholder)
- [ ] `GET /login` authenticated → still redirects to `/` (no regression
      from FE-002)
- [ ] `GET /signup` authenticated → still redirects to `/`
- [ ] `GET /login` unauthenticated → renders the form
- [ ] `GET /signup` unauthenticated → renders the form

### Structure
- [ ] `app/(app)/layout.tsx` exists, is a Server Component, calls
      `getCurrentSession()` and `redirect('/login')` when there is no user
- [ ] `app/page.tsx` is moved to `app/(app)/page.tsx` (URL stays `/`,
      no other page change)
- [ ] `app/(app)/layout.tsx` does NOT render private user data — only
      passes `children` through (chrome lands in FE-003)
- [ ] The layout passes the session/user down via a clear mechanism
      (either re-call `getCurrentSession()` in pages — fine because it
      is React `cache()`-wrapped — or pass via context). Don't introduce
      a global mutable state.

### Leak audit
- [ ] No Server Component inside `(app)/` reads from the DB before the
      session check has resolved (the layout runs first; React guarantees
      this for Server Components)
- [ ] No Client Component is responsible for the redirect (no
      "loading…then redirect" flash)

### Quality gates
- [ ] `pnpm exec tsc --noEmit` clean
- [ ] `pnpm build` successful
- [ ] Icon-constraint greps still return 0 matches (no regression from
      FE-001/002 hardening)
- [ ] No `any`, no `as any`, no `@ts-ignore` introduced

## Verification (manual)

1. Fresh browser session (or incognito), no Lucia cookie set.
   `curl -sI http://localhost:3000/` → `HTTP/1.1 307` (or 308) with
   `Location: /login`.
2. Open `/` in the browser → land on `/login` without any flash of
   the home page.
3. Sign in with a known user (created via `/signup`) → land on `/` and
   see the placeholder page render.
4. With the session active, visit `/login` → redirected to `/` (no
   regression from FE-002).
5. Sign out (POST `/api/auth/logout`) → next visit to `/` redirects
   to `/login` again.
6. Run all three icon-constraint greps in `frontend/` — still 0 matches.

## Notes

This ticket blocks **FE-003, FE-004, FE-005, FE-006** in spirit — they
all expect to live inside `(app)/`. After FE-011 lands, each of those
tickets simply adds a file under `app/(app)/<route>/page.tsx` and gets
the guard for free.

Depends on **FE-001** (Lucia + `lib/session.ts`) and **FE-002**
(`getCurrentSession` from FE-002 — already merged).

Reschedules the sequence to: FE-001 ✅ → FE-002 ✅ → **FE-011** →
FE-007 → FE-003/004/005/006 (parallel) → FE-008 → FE-009 → FE-010.
