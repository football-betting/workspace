# BA-007 Rating endpoint performance (serialized hot path)

## Repo
betting-api

## Type
refactor

## Risk
medium

## Background
Load tests showed /rating plateauing at ~280 req/s regardless of concurrency
with linearly rising latency — a serialized hot path, not a CPU limit.

## Root cause
Per-request overhead, not the live computation:
1. `dotenv()` was called inside `establish_connection()` → re-read the .env file
   and took the process-global env lock on every connection (~10×/request).
2. A fresh SQLite connection was opened per query (N+1 connections).
3. The rating loop issued one tips query per user (N+1 queries).

## What changed
1. `.env` loaded once in `main()`; removed from `establish_connection()`.
2. One connection per request, threaded through the db functions (`&Connection`).
3. `get_all_tips()` fetches every countable tip in one query; grouped in memory.
   (`get_tips_by_user` removed; its tests now use `get_all_tips`.)

## Result (wrk -t4 -c100 -d30s, on the server)
| | before | after |
|---|---|---|
| Requests/sec | 280 | 2791 (~10×) |
| Avg latency | 354 ms | 36 ms |
| Requests/30s | 8,419 | 83,829 |

Still computed fully live — no caching.

## Quality gate
fmt + clippy clean; `cargo test` 39 passed; CI green (#11).
