# MA-009 macht-api: cover get_matches HTTP paths + connection error branches

## Repo
macht-api

## Type
chore

## Risk
low

## Priority
medium

## Background
MA-008 raised macht-api coverage to ~61.6% but left the largest single
untested block — `MatchClient::get_matches` (the whole upstream HTTP call:
env reads, reqwest request, status handling, JSON parsing) — and the
error branches of the DB connection setup uncovered. These are exactly the
"upstream is down / returns garbage / DB path misconfigured" paths that matter
in production, so testing them both raises coverage and guards real failure
modes.

## Scope
- **In scope**:
  - Add `wiremock` as a dev-dependency.
  - Tests for `get_matches` against a mock HTTP server (sets `API_URI` /
    `X_AUTH_TOKEN` env for the duration; serial run already enforced by CI's
    `RUST_TEST_THREADS=1`):
    - 200 + valid payload → `Some(ApiResult)` with the parsed matches.
    - 200 but the request carries the `X-Auth-Token` header and the date filter
      builds the `dateFrom`/`dateTo` query (covers the `Some(date)` branch).
    - non-2xx status (e.g. 429) → `None`.
    - 200 + malformed JSON body → `None`.
  - Tests for the connection error branches (save/restore the env var so the
    other serial tests are unaffected):
    - `DB_PATH` unset → `save_matches_to_sqlite` is a no-op (no panic).
    - `DB_PATH` pointing at an unopenable path → no-op (no panic).
- **Out of scope (explicit)**:
  - No production code change (test-only + dev-dependency). No deploy needed —
    dev-dependencies are excluded from the release binary.
  - No change to import logic or connection behaviour.

## References
- `macht-api/src/api/match_client.rs` (`get_matches`, `get_connection`)
- `macht-api/Cargo.toml`
- `macht-api/.github/workflows/macht-api-ci.yml` (`RUST_TEST_THREADS=1`, tarpaulin)

## Acceptance Criteria
- [ ] `wiremock` added under `[dev-dependencies]`; `Cargo.lock` updated.
- [ ] `get_matches` success, header+query, non-2xx, and bad-JSON cases tested.
- [ ] `DB_PATH` unset and unopenable-path cases tested (no panic); the env var
      is restored so subsequent serial tests still see it.
- [ ] Quality Gate (macht-api): `cargo fmt --all -- --check`,
      `cargo clippy --all-targets -- -D warnings`, `cargo test --locked` green.
- [ ] tarpaulin/codecov project coverage increases vs. MA-008 (~61.6%).
- [ ] No `.unwrap()` added to production paths (tests may use it).

## Verification (manual)
1. `cd macht-api && DB_PATH=<throwaway> RUST_TEST_THREADS=1 cargo test` → green.
2. `cargo clippy --all-targets -- -D warnings` → clean.
3. Codecov on the PR reports a higher project coverage than MA-008.
