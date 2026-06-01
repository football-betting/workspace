# FE-057 Abteilung „Maintz" → „Mainz" korrigieren (Tippfehler)

## Repo
frontend

## Type
bug

## Risk
low

## Priority
high

> User-reported (2026-06-01) — springt vor FE-050.

## Status
in-progress

## Owner
implementer

## Background
Die Abteilung wird als **Wert** „Maintz" gespeichert (Legacy-DB-Tippfehler,
Spec §1) und nur bei der Anzeige via `displayDepartment("Maintz") → "Mainz"`
gemappt. Der Tippfehler soll **richtig** behoben werden: überall echtes „Mainz",
Display-Pflaster entfernen.

## Symptom (bugs only)
An Stellen, die den rohen Abteilungs-Wert zeigen (bzw. in Daten/`/rating`),
erscheint „Maintz" statt „Mainz".

## Scope
- **In scope**:
  - `lib/data/departments.ts`: `DEPARTMENTS` → „Mainz"; `displayDepartment`
    ohne Sonderfall (Pass-through).
  - `scripts/demo_data.ts`: Seed-User-Abteilung „Maintz" → „Mainz".
  - Doc-Stand: Schema-Kommentar/Mapping-Notiz in
    `docs/FRONTEND_FUNKTIONS_SPEC.md` auf „korrigiert" aktualisieren.
- **Out of scope**: Rust (groupt nur nach DB-String, kein `Maintz` hardcodiert
  → keine Änderung); historische Ticket-/Result-Dateien (Records, unverändert).

## Lockstep / DB
- Rust: keine Änderung (bestätigt: kein `Maintz` in `betting-api`/`macht-api`).
- Laufende DB enthält noch „Maintz" → **`pnpm db:reset && pnpm db:seed`** nötig,
  damit die Werte „Mainz" sind.

## Acceptance Criteria
- [ ] `DEPARTMENTS` enthält „Mainz" (kein „Maintz").
- [ ] `displayDepartment` ohne Maintz-Sonderfall.
- [ ] Seed speichert „Mainz".
- [ ] Anzeige (Tabs, Labels, rohe Werte) zeigt „Mainz".
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. `pnpm db:reset && pnpm db:seed` → Ranking-Tabs/Profil zeigen „Mainz".
