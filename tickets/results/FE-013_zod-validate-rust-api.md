# FE-013 — Zod-validate Rust API responses

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#21](https://github.com/football-betting/frontend/pull/21) (squash → `033f00a`)

## What was done
- `lib/api.ts::fetchApi` now accepts `{ wrappedByKey?, schema? }` (or the legacy `string` key for backwards-compat). Zod `safeParse` runs on the unwrapped payload; failure throws into the caller's existing offline branch.
- `lib/rating.ts` schemas: `RatingTeamSchema`, `RatingMatchInfoSchema`, `RatingUserSchema`, `RatingResponseSchema`. Types derived via `z.infer<typeof X>` — schemas are the single source of truth.
- Dashboard, ranking, profile pages pass their schema to `fetchApi`. Match-detail keeps its tolerant `parseTips()` (intentional — Zod would regress UX on one-bad-element).
- `tests/unit/rating-schemas.test.ts` — 16 cases.

## Quality gates
- vitest 75/75 (was 59, +16)
- tsc + build clean
- icon greps 0; no `any`/`@ts-ignore`
