# FE-075 Result — Profil-History 3-Zustands-Sortierung
**Geschlossen**: 2026-06-02 · **Commit**: `frontend` main `31a8479 (#79)`

## Was wurde gemacht
`PredictionHistory`-Sortierung jetzt 3-stufig pro Spalte: **asc → desc → none**
(none = Default = Datum absteigend, ohne Pfeil). `lib/history.ts`:
`toggleSort` → `cycleSort(current, key)` (Repräsentation von „none" als
`SortState | null`); Component-Sort-State nullable, effektiv `sort ?? DEFAULT_SORT`;
Indikator/`aria` bei none neutral; Seite resettet bei Sortwechsel. Test auf 3-Zyklus.

## Quality-Gate
- `bash scripts/check.sh` → grün (191 Tests).
