# FE-060 Result — Tipp-Reminder per Web Push

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `fa2d0d5 FE-060: add web push as a second reminder channel (#62)` (squash-merge PR #62)
**Risk**: medium → reviewer-Pass (VAPID-Hygiene, per-Kanal-Dedup, Email-Regression, Push-API-Auth, SW-Handler, Cron-Resilienz, Schema — alle verifiziert; Context7-gestützt).

## Was wurde gemacht
Zweiter Reminder-Kanal **Web Push** zusätzlich zu Email (FE-059):
- **Schema**: `push_subscription` (Endpoint unique), `reminder_channel`
  (aktivierte Kanäle pro User), `reminder_sent.channel` + 4-Spalten-Unique
  `(user, match, lead, channel)` → **per-Kanal-Dedup** (Email/Push unabhängig).
- **VAPID**: `VAPID_PRIVATE_KEY`/`VAPID_SUBJECT` server-only, nur
  `NEXT_PUBLIC_VAPID_PUBLIC_KEY` exponiert (für `applicationServerKey`). Keine
  Werte committet; Generierung via `npx web-push generate-vapid-keys`.
- **SW** `app/sw.ts`: `push`- + `notificationclick`-Handler (öffnet Tipp-Seite),
  robust gegen fehlende/ungültige Payload; Serwist-Caching unangetastet.
- **Settings** `PushToggle`: Permission-Flow + `pushManager.subscribe` →
  `/api/user/push-subscription` (POST/DELETE, auth, validiert, rate-limited).
  Kanal-Toggle via `/api/user/reminder-channels` (PUT).
- **Cron** erweitert: fan-out je aktiviertem Kanal, per-Kanal-Reserve-then-send,
  per-Item-try/catch, Dead-Subscriptions (404/410) werden gelöscht.
- Email-Default erhalten: User ohne Kanal-Zeilen bekommen weiter Email.

## Geänderte/neue Dateien (frontend, PR #62)
- `lib/push.ts`, `lib/push-store.ts`, `lib/push-client.ts`,
  `lib/validation/push-subscription.ts`, `lib/validation/reminder-channels.ts` (neu)
- `app/api/user/push-subscription/route.ts`, `app/api/user/reminder-channels/route.ts` (neu)
- `components/settings/PushToggle.tsx` (neu), `app/(app)/settings/page.tsx`
- `app/sw.ts`, `app/api/cron/notifications/route.ts`
- `lib/reminders.ts` (`REMINDER_CHANNELS`/`channelsForUser`), `lib/reminder-store.ts`
- `db/schema.ts` + `db/migrations/0001_*.sql` + `meta/0001_snapshot.json`
- `messages/de.json`/`en.json`, `.env.example`, `package.json` (`web-push`)
- `tests/unit/push.test.ts`, `tests/unit/reminder-channels.test.ts`

## Lockstep / DB
- Rust: keine Änderung (Tabellen frontend-only — bestätigt).
- **DB neu seeden** (`pnpm db:reset`) für die neuen/geänderten Tabellen.

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + **183 Tests** inkl. neue + i18n-Parität)
- `bash scripts/check.sh --build` → Full Next-Build grün; kein VAPID-Private/web-push im Client-Bundle

## Hinweis manueller Test
- VAPID-Keys generieren, lokal in `.env`: `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT`,
  `NEXT_PUBLIC_VAPID_PUBLIC_KEY`. Push braucht den **gebauten** Stand
  (`pnpm build && pnpm start`) — SW ist in `pnpm dev` deaktiviert.
