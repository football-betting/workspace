# [FE-017] Revert FE-016 — secret winner is public again

## Repo
frontend

## Type
bug

## Risk
low

## Priority
high

> Owner correction (2026-05-28): the secret-winner pick is part of the
> public profile by design. FE-016 hid it from other users based on
> an over-literal reading of the field name. Revert.

## Status
todo

## Background
FE-016 (merged 2026-05-28, PR #16, squash `f41b637`) hid
`secretWinner` on other users' profiles, replacing it with a `Hidden`
placeholder card. The audit finding L-1 flagged this as a privacy
risk, but the owner clarified that the field is **intentionally**
visible to all logged-in users — it's part of the public office-pool
profile, alongside the tournament-winner pick. The "secret" naming
refers to its gameplay role (a long-shot pick separate from the main
winner prediction), not to a privacy boundary.

## Scope

**In scope:**
- `app/(app)/user/[id]/page.tsx` — pass `localUser.secretWinner`
  unconditionally to `<WinnerCards>` (drop the `isOwnProfile`
  ternary)
- `components/profile/WinnerCards.tsx` — restore the original
  `secretWinner: string` prop type; remove `<HiddenSecretWinnerCard>`
  and the null-branch
- `tests/e2e/profile.spec.ts` — drop the "hidden on other users"
  Playwright spec added in FE-016

**Out of scope:**
- The follow-up FE-018 (edit winner + secretWinner before tournament
  starts) — that's a separate change

## Acceptance Criteria

- [ ] `/user/{my-id}` shows my own secret-winner TLA
- [ ] `/user/{other-id}` shows the other user's secret-winner TLA
      (no `Hidden` placeholder)
- [ ] `WinnerCards.tsx` `secretWinner` prop type is `string` again
- [ ] The Playwright spec added in FE-016 is removed
- [ ] `pnpm exec tsc --noEmit` clean
- [ ] `pnpm build` clean
- [ ] 53 Vitest + 12 Playwright tests green (Playwright count drops
      from 13 → 12 because the FE-016 spec is removed)

## References
- FE-016 ticket and its result doc (`tickets/results/FE-016_secret-winner-only-own-profile.md`)
- PR #16 (`f41b637`) — what we are undoing
