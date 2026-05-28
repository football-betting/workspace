# [FE-018] Edit winner + secretWinner on own profile before tournament starts

## Repo
frontend

## Type
feature

## Risk
medium

> Schema-write boundary. Reviewer must verify session ownership,
> kickoff-lock, and `winner !== secretWinner` are all enforced
> server-side, not just client-side.

## Priority
high

## Status
todo

## Background
Spec §19.5 listed "Pre-Turnier-Sperre: Winner/SecretWinner-Auswahl darf
nicht mehr nach Turnier-Start geändert werden — heute via UI auch nicht
änderbar (nur DB)" as a Nice-to-have. Owner (2026-05-28) bumps it to
proper feature status: users should be able to edit their two picks on
their own profile **until any match has kicked off**, after that the
fields are locked.

## Behaviour

**Tournament has not started yet** (no match has reached kickoff):
- On `/user/{my-id}`: each Winner card shows an Edit button
- Editing opens a small form: two team selects (the existing 24-team
  `lib/data/teams.ts` list), Save / Cancel buttons
- Submit → server validates session ownership, lock, and
  `winner !== secretWinner` → updates the `user` row → page re-renders
  with the new picks

**Tournament has started** (`MIN(match.utcDate) <= now`):
- No Edit button on either card
- Server endpoint rejects with 400 `{"error":"Tournament has
  already started — picks are locked."}` even if the client tries

**Other users' profile** (`/user/{other-id}`):
- Never editable, no Edit button, regardless of lock state

## Scope

**In scope:**
- `lib/tournament.ts` — `isTournamentLocked(): Promise<boolean>` —
  returns `true` when at least one match in the `match` table has
  `utcDate <= now`. Single DB read (`SELECT MIN(utcDate) FROM match`)
- `app/api/user/winners/route.ts` (POST):
  - Session-guarded
  - Reads `winner` + `secretWinner` from form-data or JSON
  - Calls `isTournamentLocked()` — if locked, 400 with documented body
  - Zod-validates: both fields are valid TLAs from `lib/data/teams.ts`,
    `winner !== secretWinner`
  - Updates `user` row (only the logged-in user's row — `userId` from
    session, never from body)
  - Returns 200 `{success: true, winner, secretWinner}` on success
  - Reuses the FE-002 rate-limiter (a fresh bucket `"winners"`)
- `components/profile/WinnerEditForm.tsx` (Client Component):
  - Two `<select>` elements seeded from `lib/data/teams.ts`
  - Client-side validation: both required, must differ
  - Submits to `POST /api/user/winners`, then `router.refresh()`
- `components/profile/WinnerCards.tsx`:
  - New optional `editable?: boolean` prop — when `true`, render an
    Edit button on each card that toggles the form into view
  - Form/display swap is local state; layout stays consistent
- `app/(app)/user/[id]/page.tsx`:
  - Compute `const locked = await isTournamentLocked()`
  - Pass `editable = isOwnProfile && !locked` into `<WinnerCards>`
- Vitest: `lib/tournament.test.ts` — `isTournamentLocked` returns
  false when all matches are future, true when at least one is past
- Playwright: `tests/e2e/winner-edit.spec.ts`:
  - Logged in as `me@dev.local`, visit `/user/6`, click Edit on
    Tournament Winner card — form appears
  - Pick a new winner, save → card re-renders with the new TLA
  - Pick `winner = ESP, secretWinner = ESP` → inline error, no submit
  - Visit `/user/1` → no Edit button visible
  - Manually POST `/api/user/winners` with winners equal → 400

**Out of scope:**
- "Grace period" after the first kickoff (e.g. 5 min) — strict cut-off
- Audit log of changes
- Notifications to other users when someone changes their pick
- Allowing winner changes after a particular date for separate
  knock-out rounds — single lock point

## Acceptance Criteria

- [ ] `isTournamentLocked()` reads `MIN(match.utcDate)`; returns `true`
      iff at least one match is at-or-past kickoff
- [ ] `POST /api/user/winners` rejects:
  - Missing/invalid session → 401
  - Locked tournament → 400 with documented error
  - `winner === secretWinner` → 400 `"Winner and secret winner must differ."`
  - Unknown TLA → 400 with the Zod error
- [ ] `POST /api/user/winners` writes ONLY the session user's row — no
      way to specify another `userId` via body or query
- [ ] Rate-limit applies (bucket `"winners"`, same 5/10min config)
- [ ] On own profile, with tournament not yet started: Edit buttons
      visible; form submits; new picks render after save
- [ ] On own profile, with tournament started: no Edit buttons;
      `POST /api/user/winners` still 400 if tried by hand
- [ ] On another user's profile: no Edit buttons regardless of lock
- [ ] `pnpm exec tsc --noEmit` clean
- [ ] `pnpm build` clean
- [ ] Vitest + Playwright suites green; new specs included

## Verification (manual)

1. `pnpm db:reset` (FE-007 seed has all matches in the past — the
   tournament is already "started" by the seed clock). For this
   ticket, temporarily move the IN_PLAY and FINISHED matches to the
   future to test the unlocked path, OR add a small env override
   `TOURNAMENT_LOCK_OVERRIDE=unlocked` (only for dev) — your call,
   document in the report
2. Verify the unlocked flow end-to-end
3. Reset the seed, verify the locked flow

## References
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §19.5 (the original Nice-to-have)
- `frontend/lib/data/teams.ts`
- `frontend/db/schema.ts` (user.winner / user.secretWinner are plain text)
- `frontend/lib/rate-limit.ts`
- `frontend/lib/validation/auth.ts` (signupSchema's `winner !== secretWinner`
  refine — reuse the pattern)
