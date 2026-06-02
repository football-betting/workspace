# FE-073 Result — Unabhängige Email/Push-Kanäle (finales Modell)
**Geschlossen**: 2026-06-02 · **Commit**: `frontend` main `2a25732 (#75)` · Risk: medium → reviewer-Pass.

## Modell (user-bestätigt)
- **Email**: kontoweit, Default an, abschaltbar (Tabelle `reminder_email_off`,
  Zeile vorhanden = aus). `reminder_channel` entfernt.
- **Push**: pro Gerät, aus `push_subscription` abgeleitet; Toggle **nur in der
  installierten PWA** (standalone) nutzbar, im normalen Browser deaktiviert + Hinweis.
- **Vorlaufzeiten**: kontoweit, von jedem Gerät änderbar; nur aktiv, wenn ≥1 Kanal
  an ist (Email an ODER ≥1 Push-Subscription) — sonst ausgegraut + Hinweis.
- **Cron**: Email wenn an; Push an alle Subscriptions; Per-Kanal-Dedup unverändert.
- Keine Materialisierung/Floor-Guard mehr (Email/Push voll unabhängig).

## Geänderte/neue Dateien (frontend, PR #75)
- `lib/reminders.ts` (`activeChannels`/`remindersActive`), `lib/reminder-store.ts`,
  `lib/push-store.ts`, `app/api/cron/notifications/route.ts`
- `app/api/user/reminder-email/route.ts` (neu, ersetzt reminder-channels),
  `lib/validation/reminder-email.ts`
- `components/settings/ReminderPreferences.tsx` + `EmailReminderToggle.tsx` (neu),
  `PushToggle.tsx` (PWA-Gate), `ReminderSettings.tsx` (Gating), `settings/page.tsx`
- Schema: `reminder_channel` raus, `reminder_email_off` rein; `0001`-Migration
  neu generiert (`reminder_sent.channel` erhalten; drizzle-generate sauber).
- `messages/de.json`/`en.json`, `tests/unit/reminder-channels.test.ts`

## Lockstep / Gate
- Rust: keine Änderung (Tabellen frontend-only). **DB neu seeden** (`pnpm db:reset`).
- `bash scripts/check.sh` + `--build` → grün (190 Tests).
