# BA-006 Update betting-api README

## Repo
betting-api

## Type
docs

## Risk
low

## Priority
low

## Background
The README still called the service the "EM2024 Backend API" and pointed setup
steps at the archived predecessor project. It no longer matched how the service
is built or run.

## Scope
- **In scope**: `README.md` — title/intro, architecture (shared DB, schema
  authority, read-only), configuration (`DATABASE_URL`, `MODE`), run/test
  instructions. Keep the accurate endpoint/object reference.
- **Out of scope**: any `src/` change (betting-api was concurrently in use by
  other work).

## Acceptance Criteria
- [x] README describes the current betting-api service and workspace context.
- [x] Endpoint/object reference retained and accurate.

Delivered via PR football-betting/betting-api#9 (squash-merged into `main`).
