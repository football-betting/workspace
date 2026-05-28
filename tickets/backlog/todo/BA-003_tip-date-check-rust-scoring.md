# [BA-003] Reject post-kickoff tips in Rust scoring (defense-in-depth)

## Repo
betting-api

## Type
feature

## Risk
medium

> Touches the scoring logic. Reviewer must verify behaviour against
> the FE-007 seed (which intentionally has tips with `date < utcDate`).

## Priority
high

> Adversarial security audit (2026-05-28) found this as the only
> defense-in-depth gap: frontend blocks POST `/api/tip/{matchId}` after
> kickoff, but if any other actor writes to the `tip` table directly
> (DBA access, compromised macht-api, future microservice, manual SQL),
> Rust scores those tips normally because it never compares
> `tip.date` vs `match.utcDate`.

## Background
The frontend handler at `frontend/app/api/tip/[matchId]/route.ts:37-44`
correctly rejects edits when:
```
matchRow.utcDate.getTime() < now.getTime()
  || matchRow.homeScore !== null
  || matchRow.awayScore !== null
```

But `betting-api`'s aggregation pipeline does NOT check `tip.date`:
- `src/db/mod.rs:80-82` loads ALL tips for a user (`SELECT ... FROM tip WHERE user_id = ?1`)
- `src/db/mod.rs:105` filters matches only by score presence
  (`WHERE homeScore >= 0 AND awayScore >= 0`)
- `src/service/mod.rs:144` `calculate_score()` only compares the
  scores; it never sees `tip.date` or `match.utcDate`

The frontend is the only chokepoint. That is a single point of failure.

## Scope

**In scope:**
- Filter or score-down tips where `tip.date >= match.utcDate` in the
  `betting-api` aggregation
- Keep the legacy seed working: FE-007 tips are all inserted with
  `tip.date < match.utcDate` so they remain scored
- Update fixtures in `betting-api/src/db/fixtures.rs` if any test
  fixture has `tip.date >= match.utcDate` (most should already be
  correct, verify)

**Out of scope:**
- Adding a unique index on `(user_id, match_id)` — separate ticket (M-1 from audit)
- Changing the SQLite schema
- Changing the frontend logic (it already blocks)
- Adding an audit log for late tip-writes (separate ticket if wanted)

## Implementation notes

Two reasonable approaches:

**Option A — SQL filter** (recommended; one query change):
```sql
SELECT t.id, t.user_id, t.match_id, t.score_home, t.score_away
FROM tip t
JOIN match m ON m.id = t.match_id
WHERE t.user_id = ?1
  AND t.date < m.utcDate
```
Tips with `tip.date >= match.utcDate` are silently ignored — they
don't appear in `tips_by_user` so `calculate_score` is never called
for them.

**Option B — score-time filter** (more defensive logging):
Load all tips, then in `service/mod.rs` skip / log tips where
`tip.date >= game.date`. Useful if you want to surface these in a
monitoring/audit endpoint.

Recommend Option A as the first cut. Option B can land later if a
"suspicious tips" dashboard is wanted.

## References

- `betting-api/src/db/mod.rs:77-100` (`get_tips_by_user`)
- `betting-api/src/db/mod.rs:102-120` (`get_past_games`)
- `betting-api/src/service/mod.rs:144` (`calculate_score`)
- `frontend/app/api/tip/[matchId]/route.ts:37-44` (mirror logic)
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §5.3
- Adversarial security audit 2026-05-28 (in workspace conversation log)

## Acceptance Criteria

- [ ] `get_tips_by_user` (or the equivalent join) excludes any row
      where `tip.date >= match.utcDate`
- [ ] Existing FE-007 demo seed still produces the same ranking
      (24 / 13 / 12 / 9 / 7 / 5 / 4 / 0 — the 8 seeded users) when
      `/rating` is called against `shared/db/database.db`
- [ ] Manual test: insert a late tip directly (`INSERT INTO tip
      (userId, matchId, scoreHome, scoreAway, date) VALUES (6, 1, 2, 0,
      <some-timestamp-after-match-1-utcDate>)`) — `/rating` for user 6
      reflects no point change from this row
- [ ] `cargo clippy -- -D warnings` clean
- [ ] `cargo test` green; fixtures updated if any had `tip.date >= match.utcDate`

## Verification (manual)

1. `cargo test` and confirm existing tests pass
2. Start `betting-api`, hit `/rating`, record TestUser's score
3. `sqlite3 shared/db/database.db "INSERT INTO tip (userId, matchId, scoreHome, scoreAway, date) VALUES (6, 1, 2, 0, strftime('%s', 'now'));"` (this is a +4 exact tip for a past match)
4. Hit `/rating` again — TestUser's score must be unchanged
5. `sqlite3 shared/db/database.db "DELETE FROM tip WHERE id = (SELECT MAX(id) FROM tip);"` (clean up)
