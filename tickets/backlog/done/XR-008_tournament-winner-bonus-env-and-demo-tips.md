# XR-008 Tournament-winner bonus via env + demo tips before kickoff

## Repo
multi

> betting-api (scoring bonus) + frontend (demo seed).

## Type
bug

## Risk
low

## Background
The ranking showed a winner bonus (12/6) even though no champion has been
decided, and all EXACT/DIFF/WINS columns were 0. Two causes: the champion team
was hard-coded ("ESP") in the scoring, and every demo tip was timestamped at
seed time — after the already-finished matches' kickoff — so the scoring
(BA-003, `t.date < m.utcDate`) excluded them all.

## Scope
- betting-api: read the champion from `TOURNAMENT_WINNER` env; unset = no winner
  = no bonus. Winner pick match → +12, secret-winner pick match → +6.
- frontend seed: date demo tips shortly before each match's kickoff.

## Acceptance Criteria
- [x] `TOURNAMENT_WINNER` unset → every `extra_point` is 0.
- [x] Setting `TOURNAMENT_WINNER` awards 12/6 to matching picks.
- [x] Demo ranking shows realistic exact/diff/wins.
- [x] Quality gate green in both repos.
