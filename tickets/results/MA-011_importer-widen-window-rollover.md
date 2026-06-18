# MA-011 result — widen incremental import window across UTC midnight

## What was done
The per-minute live importer fetched only the current UTC day
(`dateFrom=today&dateTo=today`). A match still in play across 00:00 UTC dropped
out of the query window and froze at its last pre-midnight state until the 3×/day
full re-import (MA-010) repaired it hours later.

The incremental window now spans `today-1 … today+1` (UTC), so a match crossing
midnight stays in range and keeps updating every minute until it finalizes.
`--full` (no date filter) is unchanged and remains a backstop.

## Trigger (production incident)
2026-06-18: Ghana–Panama (id `537410`, kickoff 2026-06-17 23:00 UTC, final 1:0)
showed 0:0 / PAUSED on the live site after midnight UTC while upstream already
reported FINISHED 1:0. Manual `rust-api --full` restored the correct score; this
ticket is the permanent fix.

## Files changed (macht-api)
- `src/main.rs` — added `incremental_window(today)` helper (`today-1 … today+1`,
  UTC); incremental branch now passes the range; 2 unit tests.
- `src/api/match_client.rs` — `get_matches` takes `Option<(String, String)>`
  (dateFrom, dateTo) instead of a single date; updated the date-query test to
  assert distinct from/to.

## Tests
- `cargo clippy -- -D warnings` — clean.
- `cargo test` — 27 passed (run with `--test-threads=1`; the suite shares
  process-global env vars via `set_var`, so fully-parallel runs are flaky —
  pre-existing on master, not introduced here).
- CI (PR #13: fmt · clippy · test · coverage) — green.

## PR
- macht-api PR #13 — squash-merged to `master`.

## Deployment
- **valantic** (45.90.6.68): `git pull` + `cargo build --release`; timer-driven
  (`macht-api.timer`, oneshot per minute) picks up the new binary. Verified:
  incremental run `12 saved, 0 skipped`, zero matches stuck in IN_PLAY/PAUSED,
  Ghana–Panama = FINISHED 1:0.
- **fuhlingen** (wm.api-fussball.de): same `git pull` + `cargo build --release`;
  verified `12 saved, 0 skipped`.

## Notes
- MA-010 (3×/day full-import safety timer) stays in place as belt-and-braces.
- Pre-existing test flakiness under full parallelism (shared `set_var`) is a
  candidate follow-up but out of scope here.
