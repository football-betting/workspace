# FE-075 Profil-History-Sortierung: 3 Zustände (asc/desc/none)

## Repo
frontend
## Type
feature
## Risk
low
## Priority
medium
> User (2026-06-02): Sortierung soll 3 Klicks haben — asc, desc, none (Default).

## Background
`PredictionHistory` (Profil `/user/{id}`) sortiert per Klick aktuell nur 2-stufig
(asc ↔ desc). Gewünscht: **3 Zustände** pro Spalte: aufsteigend → absteigend →
**keine** (zurück zum Default = Datum absteigend).

## Scope
- `lib/history.ts`: `cycleSort(current, key)` mit 3 Zuständen (none-Repräsentation
  als `SortState | null`; `null` = Default `DEFAULT_SORT` = Datum desc).
- `PredictionHistory`: Sort-State `SortState | null`, effektiv `sort ?? DEFAULT_SORT`;
  Klick zykliert asc→desc→none; Indikator ↑/↓ nur bei aktiver Spalte, bei none neutral;
  `aria-pressed`/`aria-sort` korrekt; Seite auf 1 bei Sortwechsel.
- Test: `cycleSort` (3-Zyklus inkl. Spaltenwechsel).

## Acceptance Criteria
- [ ] Klick auf „Punkte"/„Datum" zykliert asc → desc → none (Default Datum desc).
- [ ] Bei „none" kein Sort-Pfeil; Liste in Default-Reihenfolge.
- [ ] Filter + Pagination greifen weiter; Seite resettet bei Sortwechsel.
- [ ] Test grün; Quality Gate `bash scripts/check.sh`.
