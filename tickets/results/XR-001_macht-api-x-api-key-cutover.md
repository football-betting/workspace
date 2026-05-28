# XR-001 — macht-api x-api-key cutover

**Status:** closed, superseded · **Date:** 2026-05-28

## Outcome
Not implemented. Superseded by [FE-019](FE-019_remove-match-import-endpoint.md):
the `/api/match/import` endpoint this ticket was supposed to align
with has been removed. `macht-api` continues to write to SQLite
directly via `rusqlite`; there is no HTTP gate to authenticate.

No code changes in `macht-api/` or `frontend/` traceable to this
ticket. Closing as wontfix.
