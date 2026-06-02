# BA-005 — Modernize betting-api CI — Result

> The merged PR and squash commit carry the prefix `BA-004` (numbering slip).
> Canonical ticket: **BA-005**.

## What was done
Replaced the betting-api CI workflow with a modern pipeline:
- Toolchain via `dtolnay/rust-toolchain@stable` (rustfmt + clippy components)
  instead of `curl | sh`; dependency caching via `Swatinem/rust-cache@v2`.
- Hard gate added: `cargo fmt --all -- --check` and
  `cargo clippy --all-targets -- -D warnings`.
- Kept `cargo test` (now `--locked`) and tarpaulin coverage → Codecov.
- Modern action versions; `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` to clear the
  Node 20 deprecation.
- README status + Codecov badges fixed (pointed at the archived `em2024-api`,
  now `football-betting/betting-api`).

No `src/` changes (an unrelated uncommitted `src/main.rs` was left untouched).

## Files changed (betting-api)
- `.github/workflows/main.yml` — rewritten
- `README.md` — badges

Delivered via PR football-betting/betting-api#7 (squash-merged into `main`).

## Test results (CI, green)
- `cargo fmt --check`: clean
- `cargo clippy -- -D warnings`: clean
- `cargo test`: 39 passed
- Codecov upload: success (org `CODECOV_TOKEN`, token length 36)
- Run time ~2m25s
