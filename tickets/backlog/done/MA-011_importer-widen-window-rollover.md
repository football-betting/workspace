# MA-011 macht-api: widen per-minute import window across UTC midnight

## Repo
macht-api

## Type
bug

## Risk
medium

## Priority
high

## Status
review

## Owner
implementer

## Background
The per-minute live importer fetches only the current UTC day
(`main.rs` → `dateFrom=today&dateTo=today`). A match that kicks off late in the
UTC day keeps updating until 00:00 UTC; from the next minute the importer queries
the new UTC day, so the still-running match drops out of the window and freezes at
its last-written state. The second half is never imported. The 3×/day full-import
safety timer (MA-010) only heals it hours later, so the live site shows a wrong
score for a long stretch.

Widening the per-minute window to yesterday…tomorrow makes the live importer
self-correcting across midnight, so matches crossing 00:00 UTC keep updating
every minute and finalize on their own.

## Symptom (bugs only)
2026-06-18: Ghana–Panama (match id `537410`, kickoff `2026-06-17 23:00 UTC`,
final 1:0) showed **0:0 / PAUSED** on the valantic site after midnight UTC while
the upstream feed already reported `FINISHED` 1:0. The whole second half (incl.
the goal) was lost until a manual `--full` run. Reproduction: any fixture whose
play continues past 00:00 UTC after its kickoff day.

Immediate remediation already applied: ran `rust-api --full` on valantic →
match flipped to `FINISHED` 1:0.

## Scope
- **In scope**: widen the incremental import window in `macht-api/src/main.rs`
  from a single `today` date to `yesterday`…`tomorrow` (3-day UTC window).
  Generalize `MatchClient::get_matches` to accept a `(dateFrom, dateTo)` range.
  Update/extend tests.
- **Out of scope (explicit)**: the `--full` flag and the MA-010 safety timer
  (kept as belt-and-braces); frontend live-status logic (`frontend/lib/match.ts`).

## References
- `macht-api/src/main.rs` (date-window selection)
- `macht-api/src/api/match_client.rs` (`get_matches`)
- `tickets/backlog/in-progress/MA-010_macht-api-full-import-rollover.md` (safety timer)

## Acceptance Criteria
- [ ] Incremental run requests `dateFrom = today-1`, `dateTo = today+1` (UTC).
- [ ] `--full` still sends no date filter (unchanged behaviour).
- [ ] A match kicking off the prior UTC day stays inside the per-minute window
      and is updated to `FINISHED` without needing `--full`.
- [ ] Quality Gate (macht-api): `cargo clippy -- -D warnings && cargo test` green.

## Verification (manual)
1. On valantic after deploy, `journalctl -u macht-api.service` shows the request
   URL spanning a 3-day window → matches still updating.
2. `sqlite3 database.db "SELECT id,status FROM match WHERE status IN
   ('IN_PLAY','PAUSED')"` → only genuinely-live games, none frozen post-midnight.
