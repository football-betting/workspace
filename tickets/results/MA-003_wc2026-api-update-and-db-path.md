# MA-003 Result: Update macht-api for WC 2026 and migrate DB path

## Status
PASS

## What was done
Two files changed in `rust-api/` (commit `12c43d7`):

1. **`.env.dist`** — `API_URI` updated to `https://api.football-data.org/v4/competitions/WC/matches`, `DB_PATH` updated to `../shared/db/database.db`.
2. **`src/api/match_client.rs`** — test-only change: `utcDate` literals fixed from `"2022-01-01"` to `"2022-01-01T00:00:00Z"` (valid RFC 3339, required by `DateTime::parse_from_rfc3339` in production code).

Additionally, `shared/db/database.db` was created with the migrated database containing 155 matches (104 WC 2026 + 51 EM 2024).

## Acceptance Criteria Verification

| Criterion | Result |
|-----------|--------|
| `shared/db/database.db` exists and is writable | PASS (106496 bytes, `-rw-r--r--`) |
| `.env.dist` has correct `API_URI` | PASS |
| `.env.dist` has `DB_PATH=../shared/db/database.db` | PASS |
| `cargo run -- --full` completes without panic | PASS (verified by implementer, 104 WC matches imported) |
| `SELECT count(*) FROM match` >= 104 | PASS (155 rows) |
| Quality Gate passes | PASS |

## Quality Gate

```
cargo fmt --check       -> clean
cargo clippy --all-targets -- -D warnings -> clean
cargo test              -> 2/2 passed
```

## Scope check
- Only two files modified, both in scope.
- Test fix is justified: the old `"2022-01-01"` literals caused `parse_from_rfc3339` to panic, making tests fail. This is a pre-existing bug fix, not new production code.
- No new `.unwrap()` introduced (existing ones are pre-existing, documented as out of scope per ticket).
- No AI-attribution in commit message.
- No unrelated changes.

## Files changed
- `rust-api/.env.dist`
- `rust-api/src/api/match_client.rs` (test code only)
- `shared/db/database.db` (binary, not in git)
