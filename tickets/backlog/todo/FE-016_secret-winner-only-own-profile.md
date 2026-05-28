# [FE-016] Hide `secretWinner` on other users' profiles

## Repo
frontend

## Type
bug

## Risk
low

> Semantic / privacy fix. No data leak of password or session, but the
> feature name says "secret".

## Priority
medium

## Background
Audit finding L-1 (2026-05-28). `app/(app)/user/[id]/page.tsx:48-85`
calls `getUserById(userId)` and passes `localUser.secretWinner` to
`<WinnerCards>` regardless of whether you're viewing your own profile.
The card itself is labelled "SECRET WINNER" with the
`visibility_off` icon. Semantically and per the gameplay name, the
secret pick is meant to be hidden from other players.

## Scope

- In `app/(app)/user/[id]/page.tsx`, compute `const isOwnProfile =
  Number(sessionUser.id) === userId` (this already exists for the
  BottomNav active state)
- Pass `secretWinner` only when `isOwnProfile`; otherwise pass
  `undefined` / empty string
- `<WinnerCards>` already accepts the field — render the
  Secret-Winner card as "hidden" (e.g. show the icon + "—" or omit
  the card entirely on other users' profiles)
- One Vitest case in `tests/unit/` or a small Playwright spec
  asserting: viewing another user's profile, the page text does NOT
  contain `localUser.secretWinner`'s TLA

## Acceptance Criteria

- [ ] On `/user/{my-id}`: Secret-Winner card visible with the user's
      pick (same behaviour as today)
- [ ] On `/user/{other-id}`: Secret-Winner card either hidden, or
      shown with a placeholder ("Hidden" / "—") that does NOT include
      the actual pick
- [ ] No page text leaks the other user's secret pick (Playwright
      assertion)
- [ ] `pnpm test`, `pnpm test:e2e` both green
