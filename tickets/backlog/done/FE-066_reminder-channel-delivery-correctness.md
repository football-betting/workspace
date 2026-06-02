# FE-066 Reminder: Push deaktiviert nicht Email + kein stilles Verschlucken

## Repo
frontend
## Type
bug
## Risk
medium
## Priority
high
> Projekt-Scan 2026-06-02 (2× Medium). Reminders-Korrektheit (FE-059/FE-060).

## Status
todo
## Owner
implementer

## Background
Zwei zusammenhängende Reminder-Defekte:

1. **Push aktivieren schaltet Email still ab.** `lib/reminders.ts` `channelsForUser`
   liefert die explizite Kanalmenge, sobald eine `reminder_channel`-Zeile existiert
   (sonst Default `["email"]`). Die UI hat nur einen additiv wirkenden **Push**-
   Toggle → wer Push einschaltet bekommt `["push"]` → **Email-Reminder stoppen**
   ohne Hinweis.
2. **„reserve-then-send" verschluckt fehlgeschlagene Zustellung.** Der Cron
   markiert den Slot via `markReminderSent` **vor** dem Senden; schlägt der
   Versand fehl — oder ist **Push aktiviert, aber es gibt keine Subscription**
   (`delivered` bleibt false) — ist der Slot trotzdem „gesendet" und wird nie
   erneut versucht. Der User bekommt nichts.

## Scope
- **Kanal-Modell/UI**: Email + Push als **unabhängige** Kanäle behandeln —
  Push aktivieren darf Email nicht abschalten. Entweder Email als eigenen Toggle
  exponieren, oder `channelsForUser` so, dass Email standardmäßig aktiv bleibt,
  solange nicht explizit deaktiviert. UI (`ReminderSettings`/`PushToggle`) +
  `channelsForUser` konsistent machen.
- **Zustellung**: pro Kanal erst **nach erfolgreicher** Zustellung als gesendet
  markieren (kleines Doppelsende-Risiko bei Parallel-Läufen akzeptieren ODER
  via kurzer Reservierung + Rollback bei Hard-Fail). Mindestens: für den
  Push-Kanal **ohne Subscription gar nicht reservieren** (nichts zuzustellen).
- Dedup-Eindeutigkeit pro `(user, match, lead, channel)` bleibt.

## Acceptance Criteria
- [ ] Push einschalten lässt Email-Reminder **aktiv** (beide Kanäle möglich).
- [ ] Fehlgeschlagene/zielen­lose Zustellung markiert den Reminder **nicht** als
      gesendet (nächster Lauf versucht erneut, solange im Fenster).
- [ ] Push-Kanal ohne Subscription verbrennt keine Slots.
- [ ] Kein Doppelversand desselben `(user,match,lead,channel)`.
- [ ] Tests für die neue Kanal-Auswahl + Mark-on-success-Logik.
- [ ] Quality Gate: `bash scripts/check.sh`.
