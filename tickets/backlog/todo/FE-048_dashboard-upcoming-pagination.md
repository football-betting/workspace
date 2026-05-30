# FE-048 Dashboard: Upcoming-Liste begrenzen + nachladen

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Auf dem Dashboard kann man die anstehenden Spiele tippen. Bei vielen Spielen
wird die Liste am Anfang **zu lang**. Lösung: Wenn es **mehr als 30** Upcoming-
Spiele gibt, zunächst nur die **ersten 20** zeigen, plus zwei Buttons:
**„Nächste 10 laden"** und **„Alle laden"**.

## Scope
- **In scope**:
  - `components/dashboard/UpcomingList.tsx` (bzw. ein Client-Wrapper): Wenn
    Gesamtzahl der Upcoming-Spiele **≤ 30** → alle zeigen wie bisher. Wenn
    **> 30** → initial **20** zeigen, darunter zwei Buttons:
    - **„Nächste 10 laden"** → +10 sichtbar (mehrfach, bis alle).
    - **„Alle laden"** → alle sichtbar.
  - Reihenfolge bleibt wie bisher (nach Tag/Anpfiff sortiert); die Tag-
    Gruppierung (FE-024) muss mit der schrittweisen Anzeige konsistent bleiben.
  - Daten kommen weiter komplett vom Server (RSC); nur die **Anzeige** wird
    client-seitig begrenzt/erweitert.
- **Out of scope (explicit)**: Server-seitige Paginierung/Lazy-Fetch; Live-/
  Past-Spiele; Profil-Historie (FE-049).

## References
- `frontend/components/dashboard/UpcomingList.tsx`, `MatchRow.tsx`,
  `lib/match.ts` (`groupByDate`), `app/(app)/page.tsx`

## Acceptance Criteria
- [ ] ≤ 30 Upcoming → unverändert alle sichtbar, keine Buttons.
- [ ] > 30 → initial 20 sichtbar; „Nächste 10 laden" erhöht um 10; „Alle laden"
      zeigt alle. Buttons verschwinden, wenn alles sichtbar.
- [ ] Tag-Gruppierung bleibt korrekt; getippte Spiele bleiben editierbar.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Seed mit > 30 Upcoming → 20 sichtbar + zwei Buttons.
2. „Nächste 10" → 30; nochmal → 40 … „Alle" → komplett, Buttons weg.
