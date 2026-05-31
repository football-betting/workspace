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
    - **„Alle laden"** → alle sichtbar. **Nur anzeigen, wenn „Nächste 10"
      mindestens zweimal nötig wäre** — d. h. wenn aktuell **mehr als 10**
      weitere Spiele versteckt sind (versteckt − sichtbar > 10). Bleibt nur
      **ein** „Nächste 10"-Klick übrig (≤ 10 Rest), wird **kein** „Alle laden"
      gezeigt (überflüssig). Mit jedem „Nächste 10"-Klick neu auswerten —
      sobald nur noch ≤ 10 Rest bleiben, verschwindet „Alle laden".
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
- [ ] ≤ 30 Upcoming → unverändert **alle** sichtbar, keine Buttons (z. B. 29
      oder 30 Spiele → alle sichtbar). Erst ab **31** wird begrenzt.
- [ ] > 30 → initial 20 sichtbar; „Nächste 10 laden" erhöht um 10; „Alle laden"
      zeigt alle. Buttons verschwinden, wenn alles sichtbar.
- [ ] „Alle laden" erscheint nur, wenn > 10 weitere Spiele versteckt sind
      (≥ 2 „Nächste 10"-Klicks nötig); bei ≤ 10 Rest nur „Nächste 10".
      Beispiel: 31 Spiele → 20 sichtbar, 11 Rest → beide Buttons; nach einem
      „Nächste 10" → 30 sichtbar, 1 Rest → nur „Nächste 10".
- [ ] Tag-Gruppierung bleibt korrekt; getippte Spiele bleiben editierbar.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Seed mit > 30 Upcoming → 20 sichtbar + zwei Buttons.
2. „Nächste 10" → 30; nochmal → 40 … „Alle" → komplett, Buttons weg.
