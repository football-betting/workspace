# FE-048 Result — Dashboard Upcoming-Liste begrenzen + nachladen

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `b8c5ef5 FE-048: paginate dashboard upcoming list beyond 30 fixtures (#53)` (squash-merge PR #53)

## Was wurde gemacht
`UpcomingList` zu Client-Component gemacht (progressive Anzeige). ≤ 30 Spiele →
alle sichtbar, keine Buttons. > 30 → initial 20, „Nächste 10 laden" (+10),
„Alle laden" — letzteres **nur wenn > 10 versteckt** (≥ 2 „Nächste 10" nötig).
Flache Liste wird vor dem Slicing chronologisch sortiert, dann tagesweise
gruppiert (Gruppierung bleibt konsistent).

Build-Hürde gelöst: `groupByDate` lag in `lib/match.ts` (importiert `lib/db`,
server-only) → im Client-Component hätte das better-sqlite3 ins Browser-Bundle
gezogen. `groupByDate` lokal in `UpcomingList` inlined (nutzt nur `formatDateKey`
aus dem db-freien `lib/format`).

## Geänderte Dateien
- `frontend/components/dashboard/UpcomingList.tsx`
- `frontend/messages/de.json`, `messages/en.json` — `loadNext`/`loadAll`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest 127). **Full `--build` grün**
  (RSC-Boundary verifiziert: Map-Prop + Client/Server-Trennung sauber).
