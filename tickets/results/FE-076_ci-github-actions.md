# FE-076 — CI via GitHub Actions (frontend) — Result

## What was done
Added a GitHub Actions CI pipeline to the `football-betting/frontend` repo that
runs on every push to `main` and every pull request:

1. Installs dependencies with pnpm (`--frozen-lockfile`).
2. Runs `tsc --noEmit` as static analysis.
3. Runs the Vitest unit suite with V8 coverage.
4. Uploads the coverage report to Codecov.

Two badges (CI status + Codecov coverage) were added to the frontend README.

### Fixes required to make CI pass
- **pnpm 11 build approval**: the existing `pnpm-workspace.yaml` used the
  deprecated `onlyBuiltDependencies` list, which pnpm 11 silently ignores —
  native build scripts (`better-sqlite3`, `sharp`, `@swc/core`, `esbuild`,
  `@parcel/watcher`, `unrs-resolver`) were blocked, failing a clean install with
  `ERR_PNPM_IGNORED_BUILDS`. Migrated to the `allowBuilds` map. This only
  surfaced on a clean install (CI / fresh `node_modules`); locally it passed
  because the modules were already built.
- **Node 24 runtimes**: bumped `actions/checkout`, `actions/setup-node`, and
  `pnpm/action-setup` to v6 (Node 24) and set
  `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` to cover the `github-script` action
  bundled inside `codecov-action@v5`, clearing the Node 20 deprecation warning
  ahead of the 2026-06-16 forced switch.

## Files changed (frontend repo)
- `.github/workflows/frontend-ci.yml` (new) — CI workflow
- `vitest.config.ts` — added V8 coverage with `lcov` + `text` reporters
- `pnpm-workspace.yaml` — `onlyBuiltDependencies` → `allowBuilds`
- `README.md` — CI status + Codecov badges

Delivered via PR #80 (squash-merged into `main`), 4 commits prefixed `FE-076:`.

## Test results
- CI run on the merged branch: **green**.
- `tsc --noEmit`: clean.
- Vitest: all unit tests pass; coverage **75.83 %** statements
  (339/447), 69.63 % branches, 71.87 % functions, 75.74 % lines.
- Codecov upload: succeeded (org-level `CODECOV_TOKEN` secret, token length 36,
  "processing complete").

## Setup note
The `CODECOV_TOKEN` is configured as an organization-level secret on
`football-betting`, available to the frontend repo.
