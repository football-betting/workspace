# MA-007 Update macht-api README

## Repo
macht-api

## Type
docs

## Risk
low

## Priority
low

## Background
The README was a minimal "how to" with no description of the service, and it
referenced a `key.json` file the importer no longer uses.

## Scope
- **In scope**: `Readme.md` — purpose (scheduled match importer), architecture
  (shared DB, sole writer of `match`), configuration (`X_AUTH_TOKEN`,
  `API_URI`, `DB_PATH`), incremental vs `--full` run, safe test instructions.
  Remove the stale `key.json` step.
- **Out of scope**: any `src/` change.

## Acceptance Criteria
- [x] README explains the importer's role and workspace context.
- [x] Run (`--full`) and safe test instructions documented.
- [x] Stale `key.json` step removed.

Delivered via PR football-betting/macht-api#8 (squash-merged into `master`).
