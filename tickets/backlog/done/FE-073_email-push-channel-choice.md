# FE-073 Reminder-Kanäle frei wählbar (Email abschaltbar, z. B. nur Push)

## Repo
frontend
## Type
feature
## Risk
medium
## Priority
high
> User (2026-06-02): User soll Email/Push bestimmen — Email ausschaltbar, dann nur Push (z. B. mit installierter PWA).

## Status
in-progress
## Owner
implementer

## Background
FE-066 machte Email „immer an" (Push additiv). Der User möchte aber Email
**abschalten** und nur Push nutzen können. Email und Push sollen **unabhängige**
Kanäle sein.

## Scope (Frontend)
- **Modell** (`lib/reminders.ts` `channelsForUser`): keine Channel-Zeilen → Default
  `["email"]` (Bestandsschutz FE-059); sonst die **explizite** Menge (Email nur wenn
  Email-Zeile da, Push nur wenn Push-Zeile da). (Revert von „immer Email".)
- **UI** (Settings, Reminder-Sektion): **beide** Kanäle als Toggles —
  **Email** + **Push** (Push behält den FE-072-Opt-in-Flow inkl. Permission).
- **Materialisierung (Kernpunkt!)**: Beim **Aktivieren von Push** aus dem
  Default-Zustand (noch keine Channel-Zeilen) muss Email **explizit** mitgeschrieben
  werden, damit Push-an Email **nicht** still abschaltet. Danach kann der User Email
  separat ausschalten.
- **Floor-Guard**: Mindestens ein Kanal aktiv, solange Vorlaufzeiten gesetzt sind.
  Email ausschalten nur erlaubt, wenn Push aktiv ist (sonst Email-Toggle deaktiviert/
  forced-on mit Hinweis). Push ausschalten als letzter Kanal → fällt auf Email-Default
  zurück (ok).
- Optional sauberer: API/Helper, der die **gewünschte Kanalmenge** atomar setzt
  (statt nur inkrementell pro Kanal), um die Materialisierung robust zu machen.
- i18n de/en für die neuen Labels/Hinweise. Dedup `(user,match,lead,channel)` bleibt.

## Acceptance Criteria
- [ ] Email + Push einzeln an/aus; „nur Push" (Email aus) möglich.
- [ ] Push aktivieren schaltet Email **nicht** still ab (Materialisierung).
- [ ] Nicht beide Kanäle gleichzeitig abschaltbar, solange Vorlaufzeiten gesetzt (Floor).
- [ ] `channelsForUser` korrekt (Default email; sonst explizit); Cron fan-out unverändert korrekt.
- [ ] Tests für die Kanal-Logik (inkl. Materialisierung + Floor). de/en Parität. Kein `any`.
- [ ] Quality Gate: `bash scripts/check.sh`.
