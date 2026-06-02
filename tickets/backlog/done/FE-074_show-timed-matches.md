# FE-074 WM-Spiele (Status TIMED) werden nicht angezeigt

## Repo
frontend
## Type
bug
## Risk
low
## Priority
high
> User (2026-06-02): alle WM-Spiele importiert, aber nicht sichtbar.

## Status
in-progress
## Owner
implementer

## Background
Die externe Football-API (von macht-api importiert) liefert für Spiele mit
fixem Anpfiff den Status **`TIMED`** (nicht `SCHEDULED`). Das Frontend filtert
„kommende" Spiele aber hart auf `status = "SCHEDULED"` → die 104 importierten
WM-Spiele (alle `TIMED`) tauchen nirgends auf. (Datum/Einheit ist korrekt.)

## Scope
- **In scope**: `TIMED` als „kommend/geplant" gleichwertig zu `SCHEDULED` behandeln:
  - `lib/match.ts` `getUpcomingMatches` (Dashboard-Liste)
  - `lib/match.ts` `getLiveState` (nächster Anpfiff)
  - `lib/reminders.ts` `dueLeadMinutes` (Reminder-Eligibility nur bei SCHEDULED)
  - Eine gemeinsame Konstante `UPCOMING_MATCH_STATUSES = ["SCHEDULED","TIMED"]`.
  - `MatchHeader`/`isScheduled` behandeln TIMED schon korrekt (kein Fix nötig).
- **Out of scope**: macht-api/Status-Mapping ändern; Live (IN_PLAY/PAUSED).

## Acceptance Criteria
- [ ] `TIMED`-Spiele erscheinen in der Upcoming-Liste (Dashboard) und sind tippbar.
- [ ] `nextKickoff`/Auto-Refresh berücksichtigt TIMED.
- [ ] Reminder feuern auch für TIMED-Spiele.
- [ ] Test für die Status-Konstante/Eligibility. Quality Gate: `bash scripts/check.sh`.
