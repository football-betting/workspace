# FE-090 Add Siegen as a selectable location

## Repo
frontend

## Type
feature

## Risk
low

## Background
Registration let users pick an office location (Langenfeld, Mannheim, Mainz).
The Siegen office was missing, so Siegen colleagues could not be assigned and no
Siegen standing appeared in the leaderboard. Reported live: "man soll bei
Registrierung auswählen können welche Standort ... und auch Siegen, und das soll
auch in der Tabelle sein".

## Scope
- in: `lib/data/departments.ts` (the single `DEPARTMENTS` source of truth),
  `app/(app)/ranking/page.tsx` (deep-link `?tab=siegen` mapping).
- out: betting-api (groups departments dynamically — no hardcoded list),
  `db/schema.ts` (`department` is already free-text, no migration).

## What changed
- `DEPARTMENTS` += "Siegen". This single constant feeds the signup `<select>`,
  the `z.enum` registration validation, and the leaderboard / sidebar location
  tabs — so Siegen now appears in all three.
- Added `siegen → "Siegen"` to the ranking deep-link param map.

## Acceptance / verification
- Signup: Siegen selectable (verified live in the served HTML).
- Leaderboard: Siegen tab present (empty until someone registers there).
- No Rust/schema change required (dynamic grouping, text column).
- Quality gate: tsc clean, vitest 191 passed. PR #99, deployed.
