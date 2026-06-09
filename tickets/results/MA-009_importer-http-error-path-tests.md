# MA-009 Result — get_matches HTTP paths + connection error branches

## What was done

Covered the largest remaining untested surface in macht-api: the upstream HTTP
call (`MatchClient::get_matches`) and the database connection error branches.
Added `wiremock` as a dev-dependency and drove `get_matches` against a mock HTTP
server. Test-only change — no production code touched, no deployment needed
(dev-dependencies are excluded from the release binary).

## Coverage

Codecov project coverage (macht-api): **61.60% → 83.20% (+21.60%)** on PR #11.
Combined with MA-008 the importer went from 60.16% → 83.20%.

## Files changed (macht-api, branch `ma-009-http-error-tests`)

- `Cargo.toml` / `Cargo.lock` — add `wiremock` under `[dev-dependencies]`
- `src/api/match_client.rs` — 6 new tests in the existing `mod tests`:
  - `get_matches_parses_successful_response` — 200 + payload → parsed `ApiResult`
  - `get_matches_sends_auth_header_and_date_query` — asserts the `X-Auth-Token`
    header and `dateFrom`/`dateTo` query are sent (covers the `Some(date)` branch)
  - `get_matches_returns_none_on_error_status` — 429 → `None`
  - `get_matches_returns_none_on_malformed_json` — bad body → `None`
  - `save_matches_is_noop_when_db_path_unset` — unset `DB_PATH` → graceful no-op
  - `save_matches_is_noop_when_db_path_unopenable` — bad path → no panic
  - The env-mutating tests save/restore `DB_PATH` so the serial suite is
    unaffected (CI already pins `RUST_TEST_THREADS=1`).

## Test results

- `cargo fmt --all -- --check` — clean
- `cargo clippy --all-targets -- -D warnings` — clean
- `cargo test --locked` (serial, throwaway DB) — 25 passed (was 19)
- CI (PR #11): fmt · clippy · test · coverage + codecov/patch + codecov/project
  all SUCCESS

## Notes

The pre-existing DB-backed tests still share one `DB_PATH`; serial execution
(`RUST_TEST_THREADS=1`) remains required — unchanged by this ticket.
