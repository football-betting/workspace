# FE-060 Tipp-Reminder per Web Push / Browser-Notification

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

> Folge-Ticket aus FE-059 (User wählte „Email zuerst"). Zweiter Kanal.

## Status
todo

## Owner
implementer

## Background
FE-059 liefert Reminder per Email. Zusätzlich gewünscht: **Push-Benachrichtigung**
(PWA/Browser), damit der User auch ohne offene App benachrichtigt wird. Das ist
eigene Infrastruktur und bewusst von FE-045/FE-059 getrennt.

## Scope
- **In scope**:
  - **Web Push**: VAPID-Keys (server-only Env, nicht committet), Push-Subscription
    pro User/Gerät (neue Tabelle `push_subscription`), Service-Worker `push`- und
    `notificationclick`-Handler in `app/sw.ts`, Versand via web-push-Library aus
    dem Cron (`/api/cron/notifications` erweitern).
  - **Settings**: Kanal „Push" aktivierbar (Permission-Flow `Notification.requestPermission`
    + `pushManager.subscribe`), Subscription speichern/entfernen.
  - Dedup analog FE-059 (`reminder_sent` um Kanal erweitern oder separater Key).
  - Eligibility-Logik aus FE-059 wiederverwenden (kanal-agnostisch).
- **Out of scope**: iOS-spezifische Edge-Cases über das Nötige hinaus;
  Push-Provider/Drittanbieter; Email (FE-059 erledigt).

## References
- `app/sw.ts` (FE-045 SW), `app/api/cron/notifications/route.ts` (FE-059),
  `lib/reminders.ts` (Eligibility), `components/settings/ReminderSettings.tsx`
- Web Push / VAPID, `web-push` npm (Setup via Context7 prüfen)

## Acceptance Criteria
- [ ] Push aktivierbar in Settings (Permission + Subscription gespeichert).
- [ ] Cron sendet Push für un-getippte Spiele im Fenster (Dedup, kein Doppelversand).
- [ ] VAPID-Keys server-only, nicht committet; kein `NEXT_PUBLIC_` außer dem
      öffentlichen VAPID-Public-Key (der darf öffentlich sein).
- [ ] SW behandelt `push`/`notificationclick` (öffnet die Tipp-Seite).
- [ ] Quality Gate: `bash scripts/check.sh --build`.
