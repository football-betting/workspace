# FE-074 Result — WM-Spiele (Status TIMED) sichtbar
**Geschlossen**: 2026-06-02 · **Commit**: `frontend` main `8e2e441 (#77)`

## Ursache
Die externe Football-API (macht-api-Import) liefert für Spiele mit fixem Anpfiff
den Status **`TIMED`**, nicht `SCHEDULED`. Das Frontend filterte „kommend" hart
auf `SCHEDULED` → die 104 importierten WM-Spiele (`TIMED`) waren unsichtbar.
(Datum/Einheit war korrekt — Drizzle `mode:"timestamp"` = Sekunden.)

## Fix
- Gemeinsame Konstante `UPCOMING_MATCH_STATUSES = ["SCHEDULED","TIMED"]` +
  `isUpcomingStatus` in `lib/reminders.ts`.
- `lib/match.ts` `getUpcomingMatches` + `getLiveState` → `inArray(status,[SCHEDULED,TIMED])`.
- `lib/reminders.ts` `dueLeadMinutes` → `isUpcomingStatus` (Reminder feuern auch für TIMED).
- `MatchHeader`/`isScheduled` behandelten TIMED bereits korrekt.
- **Seed** (`scripts/demo_data.ts`, auch Test-Seed): Upcoming jetzt 7× `TIMED` + 1× `SCHEDULED` — spiegelt die echte Import-Realität.
- Test: `dueLeadMinutes` mit `TIMED` ist eligible.

## Verifikation
- Reale DB: **112 Spiele** jetzt „upcoming" sichtbar (vorher 8).
- `bash scripts/check.sh` + `--build` grün.
