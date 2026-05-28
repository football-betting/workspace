# FE-016 — Hide secretWinner on other users' profiles

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#16](https://github.com/football-betting/frontend/pull/16) (squash → `f41b637`)

## What was done
- `app/(app)/user/[id]/page.tsx` passes `secretWinner` only when `isOwnProfile`, otherwise `null`
- `WinnerCards.tsx` `secretWinner` prop widened to `string | null`; new `<HiddenSecretWinnerCard>` renders a placeholder with a `lock` icon and the text `"Hidden"` instead of the actual TLA
- Card layout stays consistent on own vs other profiles
- New Playwright spec (`tests/e2e/profile.spec.ts`) covers both branches: own profile shows the TLA, other profile shows `"Hidden"` and does NOT contain the other user's secret TLA

## Quality gates
- 53 vitest + 13 e2e tests green
- tsc clean, build clean
