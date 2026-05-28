# FE-017 — Revert FE-016: secret winner is public again

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#17](https://github.com/football-betting/frontend/pull/17) (squash → `930bd75`)

## What was done
Reverted FE-016's owner-only gate on the `secretWinner` field. The card now renders the team TLA on every profile, not just the owner's. Owner clarified the "secret" in the name is a gameplay role, not a privacy boundary.

Files:
- `components/profile/WinnerCards.tsx` — `secretWinner` prop type back to `string`; `HiddenSecretWinnerCard` removed
- `app/(app)/user/[id]/page.tsx` — pass `secretWinner` unconditionally
- `tests/e2e/profile.spec.ts` — spec replaced (asserts TLA visible on every profile)

53 Vitest + 13 Playwright tests green.
