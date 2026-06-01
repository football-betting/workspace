# FE-059 Result — Tipp-Reminder per Email

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `fc6bf54 FE-059: email reminders for un-predicted matches with configurable lead times (#61)` (squash-merge PR #61)
**Risk**: medium → reviewer-Pass (Cron-Auth, Dedup/Send-Failure, Eligibility-Grenzen, Settings-API-Auth, Build — alle verifiziert).

## Was wurde gemacht
- **Schema** (in Baseline gefaltet): `reminder_setting` (`user_id`, `lead_minutes`,
  unique) + `reminder_sent` (`user_id`, `match_id`, `lead_minutes`, `sent_at`,
  unique = Dedup).
- **Reine Eligibility-Logik** `lib/reminders.ts` (db-frei, 9 Unit-Tests):
  Lead `L` fällig ⇔ SCHEDULED ∧ `utcDate−L ≤ now < utcDate` ∧ nicht getippt ∧
  nicht bereits gesendet. Lead-Set `[1440,720,360,180,60]`.
- **Settings-UI** `ReminderSettings` (Toggles je Vorlaufzeit, „per Email"),
  persistiert via auth-PUT `/api/user/reminders` (nur eigene Settings, validiert,
  rate-limited, transaktional).
- **Cron-Endpoint** `/api/cron/notifications` — per `CRON_SECRET` gegated (401
  wenn unset/falsch), extern triggerbar. Reserve-then-send + per-Item-try/catch
  (ein Fehler blockiert den Batch nicht), Email via FE-041-Mailer (v1 deutsch).
- i18n de/en, `CRON_SECRET` in `.env.example`.

## Geänderte/neue Dateien (frontend, PR #61)
- `lib/reminders.ts`, `lib/reminder-store.ts`, `lib/validation/reminders.ts` (neu)
- `app/api/user/reminders/route.ts`, `app/api/cron/notifications/route.ts` (neu)
- `components/settings/ReminderSettings.tsx` (neu), `app/(app)/settings/page.tsx`
- `db/schema.ts` + `db/migrations/0001_*.sql` + `meta/0001_snapshot.json`
- `lib/mail.ts` (`sendTipReminderEmail`), `lib/user.ts` (`getUserEmailsByIds`)
- `messages/de.json`/`en.json`, `.env.example`, `tests/unit/reminders.test.ts`

## Lockstep / DB
- Rust: keine Änderung (Tabellen nicht von Rust gelesen — bestätigt).
- **DB neu seeden** (`pnpm db:reset`) für die neuen Tabellen.

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + **175 Tests** inkl. 9 neue + i18n-Parität)
- `bash scripts/check.sh --build` → Full Next-Build grün; kein server-only-Leak im Client

## Folge-Tickets
- **FE-060** Web Push / Browser-Push (zweiter Kanal, deferred aus dieser Entscheidung).
- **FE-061** `0001`-Snapshot-Drift (fehlendes `password_reset_token`, Altlast FE-041)
  bereinigen, damit künftiges `drizzle-kit generate` sauber bleibt.

## Hinweis manueller Test
- `CRON_SECRET` lokal in `.env` setzen; Endpoint mit
  `Authorization: Bearer $CRON_SECRET` triggern (z. B. System-Cron alle ~10 min).
