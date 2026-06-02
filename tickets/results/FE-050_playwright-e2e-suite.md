# FE-050 — Playwright E2E suite (positive + negative)

## What was done

Replaced the small, drifted set of E2E specs with a broad, deterministic
Playwright suite covering the main user journeys with both happy-path and
failure/validation cases, running against a fully isolated test stand.

- **Isolated stand** (`playwright.config.ts`): boots its own frontend
  (`:3100`) and a real `betting-api` (`:8090`) — both on
  `../shared/db/test.db`, seeded deterministically in `globalSetup`. Never
  touches the shared/production DB or the developer's running stack
  (`:3000` / `:8080`). The frontend uses its own build dir
  (`NEXT_DIST_DIR=.next-e2e`) so it coexists with a running `next dev`. UI
  locale is forced to English via a `locale=en` cookie for determinism; the
  i18n spec clears it to exercise the real German default + persistence.
- **Real read API, not mocked**: ratings/scoring come from a live `betting-api`
  pointed at `test.db`, so the frontend↔Rust contract is exercised end-to-end.
- **Coverage** (positive + negative): auth (login success / generic wrong-creds /
  unknown email / logout incl. mobile path / remember-me / protected-route
  redirects), signup validation (mismatch, too short, winners-must-differ,
  duplicate username 409, duplicate email, hints; valantic prod-only rejection
  guarded as a documented skip), tipping (submit → view mode → persist, edit,
  live/finished not tippable, empty-input rejection), password change (success +
  re-login, wrong current, too short, mismatch), avatar upload (valid PNG, SVG /
  oversize / no-file rejections, fallback), i18n switch + persistence, profile
  privacy (no email on foreign profiles; own email only in settings), and a
  mobile-viewport smoke pass across the main pages.

## Files changed (by repo)

**frontend** (PR #81)
- `playwright.config.ts` — isolated two-server stand, dedicated ports, forced
  `locale=en`, `DISABLE_RATE_LIMIT`, `NEXT_DIST_DIR=.next-e2e`.
- `next.config.ts` — `distDir` overridable via `NEXT_DIST_DIR`.
- `.gitignore` — ignore `/.next-e2e/`.
- `tests/e2e/helpers.ts` — new shared helpers (login/logout/signup, seeded
  accounts, `ORIGIN`).
- `tests/e2e/*.spec.ts` — refactored 8 existing specs onto the helpers (removed
  stale `me@dev.local` login + hard-coded `localhost:3000`), rewrote `tip` and
  the match-detail upcoming-badge test; added `signup`, `login`,
  `settings-password`, `avatar`, `i18n`, `profile-privacy`, `mobile-smoke`.

**betting-api** (PR #8)
- `src/main.rs` — bind address configurable via `BIND_ADDR` (default unchanged
  `127.0.0.1:8080`), enabling the isolated test instance on a dedicated port.

**workspace** (PR #1)
- `scripts/check.sh` — documented `--e2e` mode (separate from tsc/vitest).

## Test results

- Frontend gate: `tsc --noEmit` clean; `vitest run` 191 passed.
- betting-api gate: `cargo fmt --check` clean; `cargo clippy -- -D warnings`
  clean; `cargo test` 39 passed.
- E2E: `pnpm exec playwright test` → **48 passed, 1 skipped** (the skipped case
  is the valantic-domain rejection, only enforceable under `NODE_ENV=production`;
  the domain logic is covered by unit tests and the hint copy is asserted
  unconditionally).
- CI: betting-api #8 (fmt · clippy · test · coverage) green; frontend #81
  (type-check · unit tests · coverage) green.

## Notes

- Run the suite via `bash scripts/check.sh --e2e` (needs the Rust toolchain for
  the `betting-api` server and `pnpm exec playwright install chromium`).
- Reviewer pass completed: no blockers; negatives verified meaningful; no `any`,
  no Rust panic path introduced.
