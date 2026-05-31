# FE-047 Zahlen-Formatierung lokalisieren (Punkte-Gruppierung)

## Repo
frontend

## Type
chore

## Risk
low

## Priority
low

## Status
todo

## Owner
implementer

## Background
Nach FE-034 (Datum/Land lokalisiert) bleibt eine letzte hartcodierte Locale:
`components/profile/ProfileHeader.tsx` formatiert die Punkte mit
`points.toLocaleString("de-DE")` — also immer deutsche Tausender-Gruppierung,
auch im EN-Modus. Zahlen sollen der aktiven Sprache folgen.

## Scope
- **In scope**:
  - `ProfileHeader.tsx`: `toLocaleString("de-DE")` durch die aktive Locale
    ersetzen (`useLocale()` bzw. next-intl `useFormatter().number(...)`).
  - Weitere `toLocaleString("de-DE")`/`toLocaleString("en-…")`-Stellen suchen
    und mitziehen, falls vorhanden.
- **Out of scope (explicit)**: Datum/Zeit (FE-034 erledigt); Währungen.

## References
- `frontend/components/profile/ProfileHeader.tsx` (~Z. 17)
- `frontend/lib/format.ts` (Muster Locale-Param), `useLocale`/`useFormatter`

## Acceptance Criteria
- [ ] Punkte-Zahlen folgen der aktiven Sprache (keine harte `de-DE`).
- [ ] Keine weitere hartcodierte Zahlen-Locale im UI.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Profil mit großer Punktzahl → DE-/EN-Gruppierung passend zur Sprache.
