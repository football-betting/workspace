# XR-009 Result — normalize team codes (GER, not DEU)

## What was done

Standardized the `winner`/`secretWinner` team codes on the football-data TLA
that the signup form and the imported `match` table already use (Germany =
`"GER"`, not the ISO3 `"DEU"`). The mismatch meant a user who registered via the
form (storing `"GER"`) would never match a tournament winner recorded as
`"DEU"`, silently losing the +12 / +6 bonus.

## Production check — no migration needed

Read the live DB first: all **12 production users already use TLA codes**
(winner: ESP/POR/FRA/GER/ENG/ARG; secretWinner: GER/FRA/POR/NOR/NED/ESP/ENG) —
**zero** ISO3 codes, and `TOURNAMENT_WINNER` is unset (tournament not decided).
So production was already consistent; **no data migration was required**. The
inconsistency lived only in the demo seed and betting-api test fixtures. When the
tournament ends, `TOURNAMENT_WINNER` must be set to the TLA (e.g. `"GER"`), which
matches the stored user codes.

## Files changed

### frontend (branch `xr-009-team-codes`)
- `scripts/seed-users.ts` — **new**: extracted the demo `USERS` (was inline in
  the self-executing `demo_data.ts`) so it is importable by a test. Codes fixed
  to valid form TLAs: `DEU→GER`, `HRV→CRO`, `NLD→NED`, and `ITA→BRA` (Italy is
  not in the WM'26 team list).
- `scripts/demo_data.ts` — import `USERS`/`SeedUser` from `./seed-users`.
- `tests/unit/seed-team-codes.test.ts` — **new guard**: every seeded
  winner/secretWinner must be a code the signup form offers, and the two must
  differ. Would have caught both `DEU` and `ITA`.
- `tests/e2e/profile.spec.ts` — assertions updated to the seed's new codes
  (`NLD→NED`, `DEU→GER`).

### betting-api (branch `xr-009-team-codes`)
- `src/db/fixtures.rs` — test fixtures `DEU→GER`, `NLD→NED` for consistency
  (scoring is code-agnostic; logic unchanged).

## Test results
- frontend: `tsc` clean · unit **399 passed** (incl. new guard) · E2E **48
  passed, 1 skipped** (~46s)
- betting-api: `cargo fmt`/`clippy -D warnings` clean · **39 passed**

## Deployment
None required. Demo seed + test fixtures are not production runtime; the prod DB
is already TLA-consistent and needs no migration.

## Note
`lib/data/flag.ts` / `flag.test.ts` intentionally map both ISO3 and TLA codes to
flags (the imported match data is historically mixed), so they were left as-is.
