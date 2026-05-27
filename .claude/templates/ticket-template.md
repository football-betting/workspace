# [TICKET-ID] Title

<!--
Ticket ID format: <PREFIX>-<NUMBER>, e.g. FE-007, BA-003, MA-002, WS-001.
Filename: <PREFIX>-<NUMBER>_<slug>.md (e.g. FE-007_dashboard-empty-state.md)

Prefix → Repo mapping:
  FE  →  frontend         (Next.js)
  BA  →  betting-api      (Rust read API)
  MA  →  macht-api        (Rust importer)
  WS  →  workspace        (docs, .claude, scripts, this repo)
  XR  →  cross-repo / multi

Numbering is per-prefix and monotonically increasing. Do not reuse numbers.
Multiple developers can work in parallel on different prefixes — one terminal
per repo, no ID collisions.
-->

## Repo
frontend | betting-api | macht-api | workspace | multi

> If `multi`: list all repos affected in `Scope → In scope` and the
> implementation order in `Notes`.

## Type
feature | bug | refactor | docs | chore

## Risk
high | medium | low

> `high` → external review required before `done` (see `agents/reviewer.md`).

## Priority
high | medium | low

## Status
todo | in-progress | review | done

## Owner
implementer | reviewer | tester

## Background
Why is this change needed? What problem does it solve? Business / product
perspective. No implementation detail — this text feeds the PR description.

## Symptom (bugs only)
Observable behaviour and concrete reproduction steps.

## Scope
- **In scope**: ...
- **Out of scope (explicit)**: ...

## References
- `<repo>/<path/to/relevant/source/file>`
- Specs in `docs/` if the change touches documented behaviour

## Acceptance Criteria
Concrete and verifiable — name the input and the expected output, not a goal:

- [ ] `POST /api/x` with payload `Y` returns `201` + entity `Z`
- [ ] Duplicate id → `409` with body `{"error": "..."}`
- [ ] Quality Gate passes in `<repo>`:
  - Rust: `cargo clippy -- -D warnings && cargo test`
  - Next.js: `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
Steps a reviewer can replay, each with its expected result:

1. <action> → <expected result>
2. <action> → <expected result>

## Notes (multi-repo only)
Implementation order if multiple repos are affected:

1. `frontend/db/schema.ts` — add field
2. `frontend/db/migrations/...` — generate migration
3. `betting-api/src/db/mod.rs` — mirror struct
4. `macht-api/src/api/match_client.rs` — mirror struct
5. Tests in every touched repo
