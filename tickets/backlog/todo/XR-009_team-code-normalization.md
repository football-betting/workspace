# XR-009 Normalize team codes across signup ↔ seed ↔ scoring (GER vs DEU)

## Repo
multi

## Type
bug

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
The team code for Germany is inconsistent across the system, surfaced while
adding E2E to CI (FE-095):

- **Signup form** (`frontend/lib/data/teams.ts`): Germany = `"GER"` (the
  football-data.org TLA). A user who registers and picks Germany stores
  `user.winner = "GER"` / `secretWinner = "GER"`.
- **Seed + scoring**: the demo seed and the `TOURNAMENT_WINNER` convention use
  ISO3 (`"DEU"`, `"NLD"`, `"HRV"`, …). The betting-api winner bonus compares
  `user.winner == TOURNAMENT_WINNER`.

So a form-registered Germany pick (`"GER"`) would **never** match a tournament
winner recorded as `"DEU"` → the +12 winner / +6 secret-winner bonus silently
never fires for affected users. The frontend spec already documents the mixed
FIFA-vs-ISO3 code problem (`docs/FRONTEND_FUNKTIONS_SPEC.md` §1) and a
`countryMapping` in the old `Flag.astro`; this ticket is to make the codes used
for `user.winner`/`secretWinner` consistent end to end.

## Symptom (bugs only)
A user registering via the signup form and selecting Germany stores
`winner="GER"`. If the tournament winner is configured/seeded as `"DEU"`, the
winner bonus is not awarded despite a correct pick. Same class of bug for any
team whose signup code (TLA) differs from its ISO3 seed code.

## Scope
- **In scope**:
  - Decide the single canonical code for `user.winner`/`secretWinner` (TLA vs
    ISO3) and apply it consistently in: the signup form options
    (`frontend/lib/data/teams.ts`), the seed (`frontend/scripts/demo_data.ts`),
    and the `TOURNAMENT_WINNER` env/comparison in
    `betting-api/src/service/mod.rs`.
  - A data migration/normalization for any already-stored mismatched codes.
  - Tests proving a form-registered winner pick earns the bonus when that team
    wins.
- **Out of scope (explicit)**:
  - Flag rendering / `countryMapping` display logic.

## References
- `frontend/lib/data/teams.ts` (signup option codes — Germany `"GER"`)
- `frontend/scripts/demo_data.ts` (seed winners — ISO3)
- `betting-api/src/service/mod.rs` (`WINNER_BONUS`, `SECRET_WINNER_BONUS`,
  `TOURNAMENT_WINNER` comparison)
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §1 (documented mixed-code problem)
- Discovered in FE-095 (E2E signup specs).

## Acceptance Criteria
- [ ] `user.winner`/`secretWinner` use one canonical code from signup through
      seed through the betting-api comparison.
- [ ] A user who picks the eventual champion via the signup form is awarded the
      +12 (or +6 secret) bonus — covered by a test.
- [ ] Existing mismatched stored codes are migrated.
- [ ] Quality Gate green in every touched repo.
