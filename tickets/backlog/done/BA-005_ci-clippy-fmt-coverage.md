# BA-005 Modernize betting-api CI (clippy, fmt, coverage)

> Note: the merged PR (football-betting/betting-api#7) and its squash commit
> use the prefix `BA-004` due to a numbering slip; the canonical ticket number
> is **BA-005** (BA-004 was already taken by the panic/DoS hardening ticket).

## Repo
betting-api

## Type
chore

## Risk
low

## Priority
medium

## Background
betting-api has a CI workflow (`main.yml`) that builds, tests, and uploads
tarpaulin coverage, but it installs Rust via `curl | sh`, runs no linting, uses
outdated actions (Node 20), and its README badges point at the archived
`em2024-api` repo. We want the same quality signal the frontend now has:
fmt-check + clippy as a hard gate, plus a status badge and correct Codecov
badge.

## Scope
- **In scope**:
  - `.github/workflows/main.yml` — rust-toolchain action (clippy+rustfmt),
    rust-cache, `cargo fmt --check`, `cargo clippy -- -D warnings`,
    `cargo test`, tarpaulin coverage → Codecov. Modern actions (Node 24).
  - `README.md` — fix status + Codecov badges to `football-betting/betting-api`.
- **Out of scope (explicit)**:
  - Any change to `src/` (uncommitted `src/main.rs` belongs to other work).

## Acceptance Criteria
- [ ] Push/PR triggers CI; `cargo fmt --check`, `cargo clippy -- -D warnings`,
      `cargo test` all green.
- [ ] Coverage uploaded to Codecov (org `CODECOV_TOKEN`).
- [ ] README badges resolve to the betting-api repo.

## Verification (manual)
1. Open PR → CI green, all four steps pass.
2. README badges render against `football-betting/betting-api`.
