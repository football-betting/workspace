# [FE-013] Zod-validate Rust API responses in fetchApi

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
todo

## Background
`lib/api.ts`'s `fetchApi<T>(endpoint, wrappedByKey?)` casts
`await res.json()` directly to `T` with no runtime validation.
Dashboard, ranking, profile, and match-detail all consume the result
under that blind cast. If the Rust API ever changes its response
shape (new field naming, missing keys, type drift), the frontend
will silently render broken or undefined data.

FE-005's match-detail already added defensive ad-hoc parsing in
`parseTips`. Generalise.

## Scope

**In scope:**
- Add an optional `schema?: ZodSchema<T>` argument to `fetchApi`
- Treat `schema.safeParse` failures as offline (same code path as
  network failure: log + return null in the call sites that already
  handle null)
- Add Zod schemas for `RatingResponse`, `RatingUser`, `GameTips`
  in `lib/rating.ts` (move the existing types into schemas)
- Update `lib/api.ts` callers (dashboard, ranking, profile,
  match-detail) to pass their schema

**Out of scope:**
- Changing the Rust API
- Refactoring the consuming pages beyond passing the schema

## Acceptance Criteria

- [ ] `fetchApi(endpoint, key, schema?)` validates response via Zod when
      schema is provided
- [ ] Mismatched payload → callers see the same "offline" branch they
      already implement (no new error UI)
- [ ] `tsc` clean, `next build` clean
- [ ] Type of `fetchApi` no longer carries an unchecked cast
- [ ] Dashboard / ranking / profile / match-detail still render
      correctly against a live Rust API

## References
- `frontend/lib/api.ts`
- `frontend/lib/rating.ts`
- `frontend/app/(app)/match/[id]/page.tsx` (parseTips — pattern to generalise)
- `tickets/results/FE-009_security-audit.md`
