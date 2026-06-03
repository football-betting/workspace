# XR-008 Result — Tournament-winner bonus via env + demo tips before kickoff

## What was done
- **betting-api** (PR #10): the champion is read from `TOURNAMENT_WINNER`
  (`service::get_user_rating(..., tournament_winner)`, passed from the env in
  `routes::load_user_ratings`). Empty/unset → no winner → `extra_point = 0`;
  a user's `winner` pick matching → +12, `secretWinner` matching → +6
  (`ScoreConfig::WINNER_BONUS` / `SECRET_WINNER_BONUS`).
- **frontend** (PR #84): `scripts/demo_data.ts` dates each tip one hour before
  its match's kickoff (read from the DB `utcDate`), so the scoring no longer
  excludes them as post-kickoff.

## Test results
- betting-api: fmt + clippy clean; `cargo test` 39 passed (the bonus integration
  tests set `TOURNAMENT_WINNER=ESP`). CI green on #10.
- frontend: `tsc` clean; `vitest` 191 passed. CI green on #84.

## Deployment / verification
- Re-seeded the production DB; rebuilt + restarted betting-api with
  `TOURNAMENT_WINNER` unset. `GET /rating`: realistic exact/diff/wins, every
  `extra_point` = 0 (e.g. AdaLovelace exact 6 → total 30).

## Note
To award the bonus once a champion is known: set `TOURNAMENT_WINNER=<TLA>` in
`betting-api/.env` and `systemctl restart betting-api`.
