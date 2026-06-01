# FE-057 Result — Abteilung „Maintz" → „Mainz" korrigiert

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `a3643b0 FE-057: correct department typo Maintz to Mainz (#59)` (squash-merge PR #59)

## Was wurde gemacht
Der Legacy-Tippfehler „Maintz" wurde überall durch das korrekte „Mainz"
ersetzt; das Anzeige-Pflaster `displayDepartment` ist jetzt Pass-through.

## Geänderte Dateien
### frontend (PR #59)
- `lib/data/departments.ts` — `DEPARTMENTS` „Mainz"; `displayDepartment` Pass-through
- `scripts/demo_data.ts` — Seed-Abteilung „Mainz"
- `app/(app)/ranking/page.tsx` — Tab-Slug-Mapping `mainz: "Mainz"`
- `tests/unit/departments.test.ts`, `tests/unit/tip-upsert.test.ts` — angepasst

### workspace
- `docs/FRONTEND_FUNKTIONS_SPEC.md` — Schema-Kommentar + Mapping-Notiz auf „korrigiert" aktualisiert

## Lockstep / DB
- Rust: keine Änderung (kein `Maintz` hardcodiert — bestätigt).
- **DB neu seeden** (`pnpm db:reset && pnpm db:seed`), damit Bestandswerte „Mainz" sind.

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (low-risk, Wert-Korrektur).
