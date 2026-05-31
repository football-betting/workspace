# FE-049 Result — Profil-Tipp-Historie: Sortieren, Filtern, Paginieren

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `bc30d67 FE-049: sort, filter and paginate the profile prediction history (#54)` (squash-merge PR #54)
**Risk**: low → reviewer-Pass (Full-Build grün, kein db-Leak in den Client, alle Kriterien handverifiziert).

## Was wurde gemacht
Auf `/user/{id}` ist die `PredictionHistory` jetzt interaktiv:
- **Sortierung** nach Punkten/Datum, Klick dreht Richtung, **Default Datum
  absteigend**.
- **Filter** über die Stat-Kacheln (Exakt/Diff/Sieger) — Kategorie aus
  `tip.score` (5/3/2). **Bonus-Kachel nicht filterbar** (kein Per-Tip-Wert).
  Aktiver Filter markiert, ein-Klick-„Alle anzeigen".
- **Paginierung** client-seitig ab > 30 Einträgen (20/Seite, prev/next + Seite
  x/y); nie alle gleichzeitig gerendert.
- Reihenfolge Filter → Sortierung → Seite; Filter-/Sort-Wechsel → Seite 1.

Geteilter Filter-State via **Client-Context** (`HistoryFilterContext`) ums
Main-Content, ohne Layout-Umbau (StatTiles im Header-Grid, Historie darunter).
Reine Logik in db-freiem `lib/history.ts` (Kategorie/Filter/Sort/Pagination).
Pager-Handler auf geklemmtes `currentPage` gesetzt (kein stale-page-Wart).

## Geänderte/neue Dateien
- `frontend/lib/history.ts` (neu) — `tipCategory`, Filter, Sort-Comparator, Pagination
- `frontend/components/profile/HistoryFilterContext.tsx` (neu) — Client-Context
- `frontend/components/profile/PredictionHistory.tsx` — Client, Sort/Filter/Pager
- `frontend/components/profile/StatTiles.tsx` — Kacheln als Filter (Bonus statisch)
- `frontend/app/(app)/user/[id]/page.tsx` — Provider um `<main>`
- `frontend/messages/de.json`, `messages/en.json` — neue Profile-Keys
- `frontend/tests/unit/history.test.ts` (neu, 24 Tests)

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest **151**, inkl. 24 neue + i18n-Parität)
- `bash scripts/check.sh --build` → **Full Next-Build grün**, kein db-Import im Client-Bundle
