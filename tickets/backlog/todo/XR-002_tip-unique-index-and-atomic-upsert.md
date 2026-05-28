# [XR-002] Add UNIQUE(userId, matchId) on tip + use atomic upsert

## Repo
multi

> Touches `frontend/db/schema.ts` (schema + Drizzle migration) AND
> `betting-api`/`macht-api` Rust structs need to stay in lockstep.
> No Rust column-list changes expected, but Rust SQL should be reviewed.

## Type
chore

## Risk
medium

> Schema migration on a live table. Run the existing seed before/after
> to confirm idempotence.

## Priority
medium

## Background
Adversarial audit (2026-05-28) found the `tip` table lacks
`UNIQUE(user_id, match_id)`. `frontend/lib/tip.ts:30-57` `saveTip()`
does a non-transactional SELECT → conditional INSERT/UPDATE. A
double-click on Save (or two concurrent Node workers) can produce
two rows for the same `(userId, matchId)`. better-sqlite3 is sync
within one process, so the race is realistic only across multiple
Next.js workers / replicas, but the schema should guarantee
atomicity regardless.

## Scope

**In scope (frontend):**
- Drizzle migration adding `UNIQUE INDEX tip_user_match_unique ON tip(user_id, match_id)`
- Replace `saveTip` body with a single Drizzle
  `db.insert(tip).values(...).onConflictDoUpdate({target: [tip.userId, tip.matchId], set: {...}})`
- Update the local `lib/tip.ts` `getTipByUserAndMatch` to take advantage
  of the unique row (no functional change, just a comment / type tighten)

**In scope (Rust):**
- Review `betting-api/src/db/mod.rs::get_tips_by_user` — no change
  expected, but document that the index now guarantees one row per
  (user, match)

**Out of scope:**
- De-duplicating any existing rows (the dev DB likely has none; if
  prod has duplicates the migration will fail — handle as part of
  this ticket only if duplicates exist)
- Changing the foreign-key behavior (nullability is already a known
  spec §16 tech-debt)

## References

- Audit finding M-1 (workspace conversation log)
- `frontend/lib/tip.ts:30-57`
- `frontend/db/schema.ts` (tip table)
- `betting-api/src/db/mod.rs:77-100`

## Acceptance Criteria

- [ ] New Drizzle migration creates the unique index
- [ ] `pnpm db:reset` runs idempotently
- [ ] `saveTip` uses `onConflictDoUpdate`; rapid double-click never
      produces two rows for the same (user, match) — verified by
      running 10 parallel `curl POST /api/tip/<id>` in a loop
- [ ] `cargo test` in `betting-api` still green
- [ ] No schema drift documented in spec §16 changes shape
