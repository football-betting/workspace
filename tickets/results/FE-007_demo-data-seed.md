# FE-007 — Idempotent demo-data seed

**Status:** done
**Merged:** 2026-05-28
**PR:** [football-betting/frontend#5](https://github.com/football-betting/frontend/pull/5) (squash → `0003710`)

## What was done

Deterministic seed script for dev + test DBs. Wipes and re-inserts the
canonical 8-user / 12-match / 48-tip dataset from spec §20 in a single
transaction. Reads `DATABASE_URL` so the same script seeds dev
(`shared/db/database.db`) and test (`shared/db/test.db`) based on the
active dotenv file.

## Files (~480 LOC / 3 files)

### `frontend/scripts/` (new)
- `demo_data.ts` (~440 LOC) — wipe + insert, Argon2id hashes 8
  passwords at seed time, tip matrix designed to expose all four point
  colors with no user ties
- `reset.ts` (~36 LOC) — rm DB file, spawn `pnpm db:migrate`, spawn
  `pnpm db:seed`

### `frontend/` (modified)
- `package.json` — `db:seed`, `db:seed:test`, `db:reset`, `db:fresh`

## Reviewer verdict — REJECT → fixed → APPROVE

Reviewer initially **REJECT**ed because the seed wrote `Mainz` (spec
§20.4 display spelling) instead of `Maintz` (the FE-001 `DEPARTMENTS`
enum, per spec §1 "Maintz ist Tippfehler in DB"). Fixed in-branch
before merge: both Mainz users now stored as `Maintz`, matching the
FE-001 validation enum and the `displayDepartment` UI helper.

## Quality gates

| Gate | Result |
|---|---|
| `pnpm exec tsc --noEmit` | ✅ clean |
| `pnpm build` | ✅ clean |
| `pnpm db:reset` cold | ✅ 1.17 s |
| `user/match/tip` counts | ✅ 8 / 12 / 48 |
| Department storage | ✅ Maintz=2, Mannheim=3, Langenfeld=3 |
| Idempotence (second `pnpm db:seed`) | ✅ same state |
| `MATCH_TABLE_FROZEN=1 pnpm db:seed` | ✅ match count unchanged |
| Icon greps + `any` audit | ✅ all clean |

## Decisions

1. **Department storage = `Maintz`** (typo) per spec §1. The `Mainz`
   spelling in spec §20.4 is just the display form. Reviewer caught
   the implementer's initial mistake and forced the fix.
2. **TestUser at rank 4 of 8** — gives neighbor-highlight tests a
   non-edge position in FE-003 ranking sidebar.
3. **Argon2id at seed time, not committed** — params verbatim from
   FE-002 (`memorySize: 19456, iterations: 2, tagLength: 32,
   parallelism: 1`).
4. **`db:seed:test` uses inline `DATABASE_URL`** instead of
   `dotenv-cli` — keeps zero new deps and works the same way.
5. **`MATCH_TABLE_FROZEN` flag** — allows running the seed against a
   DB that the Rust `macht-api` is already writing to, without nuking
   live match rows.

## Unblocks

- **FE-003** Dashboard — can now show live block + upcoming + ranking sidebar
- **FE-004** Ranking — `/table` displays all 4 department tabs populated
- **FE-005** Match detail — predictions table has real tip distribution
- **FE-006** Profile — stat tiles + history have real numbers
- **FE-010** Tests — Playwright suite runs against `shared/db/test.db`
