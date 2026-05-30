# FE-039 Result — Sprachumschalter auf Login/Register

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `dc67b60 FE-039: language switcher on login/register via (auth) layout (#36)` (squash-merge von PR #36)

## Was wurde gemacht

Neues `app/(auth)/layout.tsx` rendert den bestehenden `LocaleSwitcher`
(fixiert oben rechts) einmal für beide Auth-Seiten (Login + Signup). Persistenz
über denselben `locale`-Cookie wie überall (FE-023) — kein neuer Mechanismus.

## Geänderte Dateien
- `frontend/app/(auth)/layout.tsx` (neu)

## Quality-Gate
- `bash scripts/check.sh --build` → tsc 0, vitest **91/91**, build ok.

## Review
Trivial (Layout rendert bereits reviewte Komponente) → Self-Review + Gate,
kein Reviewer-Agent. Design unverändert.
