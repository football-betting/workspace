# FE-053 Result — Ranking-Tabs auf Mobile nicht mehr abgeschnitten

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `6dea46e FE-053: wrap ranking location tabs so none are clipped on mobile (#48)` (squash-merge PR #48)

## Was wurde gemacht
Die Standort-Tabs auf `/ranking` waren `overflow-x-auto no-scrollbar` —
scrollbar ohne sichtbaren Hinweis, daher wirkte „MAINZ" hart abgeschnitten.
Umgestellt auf `flex flex-wrap gap-xs`: die Tabs brechen bei Platzmangel in eine
zweite Zeile um → alle Tabs vollständig lesbar/erreichbar, unabhängig von der
Anzahl Abteilungen. Aktiv-Zustand unverändert.

## Geänderte Dateien
- `frontend/components/ranking/RankingTabs.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (kosmetisch, responsive).
