# XR-002 — Tip UNIQUE(userId, matchId) + atomic upsert

**Status:** done (frontend half) · **Merged:** 2026-05-28 · **PR:** [#20](https://github.com/football-betting/frontend/pull/20) (squash → `04b1e92`)

## What was done (frontend)
- `db/schema.ts` — `uniqueIndex("tip_user_match_unique").on(userId, matchId)`
- `db/migrations/0001_remarkable_living_lightning.sql` — single `CREATE UNIQUE INDEX`
- `lib/tip.ts::saveTip` — single atomic `onConflictDoUpdate` keyed on the composite; `date` set on both insert and update paths
- `tests/unit/tip-upsert.test.ts` — 3 cases (insert, conflict-update, idempotence loop) against in-memory better-sqlite3 with the unique index applied
- Concurrent-write smoke: 5 parallel `saveTip()` calls → exactly 1 row

## Rust side
No Rust code change required — `betting-api` and `macht-api` only read from `tip`. Reviewer recommends running `cargo test` in `betting-api` as a re-verification before deploy. Not tracked as a separate ticket.

## Reviewer verdict — APPROVE
59/59 Vitest, build clean, `pnpm db:reset` 8/12/48 unchanged, schema-drift §16 doc shape unchanged.
