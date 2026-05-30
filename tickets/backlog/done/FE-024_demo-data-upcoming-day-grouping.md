# FE-024 Demo-Daten: Upcoming Fixtures über mehrere Tage

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
todo

## Background
Die Dashboard-Liste "Upcoming Fixtures" gruppiert Spiele bereits nach Tag
(`UpcomingList` + `groupByDate`, eine Überschrift pro Kalendertag). Mit den
aktuellen Demo-Daten lässt sich das aber kaum prüfen, weil zu wenige
anstehende Spiele über zu wenige Tage verteilt sind. Der Seed soll mehr
zukünftige Spiele über mehrere Tage erzeugen, damit die Tag-Gruppierung in der
UI sichtbar wird.

## Scope
- **In scope**:
  - `scripts/demo_data.ts` so erweitern, dass die anstehenden Spiele über
    mindestens drei verschiedene Kalendertage verteilt sind, mit mehreren
    Spielen pro Tag.
- **Out of scope (explicit)**: Änderungen an der Gruppierungslogik
  (`UpcomingList`, `groupByDate`) — die funktioniert; Änderungen an
  Live-/vergangenen Spielen über das für die Verteilung Nötige hinaus;
  Schema-Änderungen.

## References
- `frontend/scripts/demo_data.ts` — Seed
- `frontend/lib/match.ts` — `getUpcomingMatches`, `groupByDate`
- `frontend/components/dashboard/UpcomingList.tsx` — rendert eine
  Tages-Überschrift pro Datums-Key

## Acceptance Criteria
- [ ] Nach `pnpm db:reset` liefert `getUpcomingMatches()` Spiele über
      mindestens 3 verschiedene Kalendertage.
- [ ] Mindestens ein Tag enthält ≥2 Spiele (Gruppierung pro Tag sichtbar).
- [ ] Dashboard zeigt entsprechend mehrere Tages-Überschriften mit den
      jeweils darunter gruppierten Spielen.
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. `cd frontend && pnpm db:reset`.
2. betting-api + `pnpm dev` starten, einloggen.
3. Dashboard → "Upcoming Fixtures" zeigt mehrere Tages-Überschriften, jeweils
   mit den Spielen dieses Tages gruppiert.
