# FE-066 Result — Reminder-Kanal/-Zustellung korrekt

**Geschlossen**: 2026-06-02
**Commit**: `frontend` (main) `8d6393c (#67)`

## Was wurde gemacht
- **Push additiv**: `channelsForUser` liefert jetzt immer `["email"]` + ggf.
  `"push"` → Push einschalten schaltet Email **nicht** mehr ab.
- **Mark-on-success**: der Cron reserviert den Dedup-Slot erst **nach**
  erfolgreicher Zustellung (neuer reiner Helper `shouldMarkDelivery`). Fehlgeschlagene
  Zustellung wird nicht markiert → nächster Lauf versucht erneut (im Fenster).
- **Push ohne Subscription** wird übersprungen (kein verbrannter Slot).
- Per-Kanal-Dedup `(user,match,lead,channel)` unverändert → erfolgreicher Slot
  kein Doppelversand. Akzeptierter Rest-Doppelsende-Fall (überlappende Läufe)
  durch Rate-Limit + Single-Scheduler vernachlässigbar.

## Geänderte Dateien
- `frontend/lib/reminders.ts`, `app/api/cron/notifications/route.ts`, `tests/unit/reminder-channels.test.ts`

## Quality-Gate
- `bash scripts/check.sh` → grün (189 Tests). Self-Review (Delivery-Logik handverifiziert).
