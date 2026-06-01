# FE-059 Tipp-Reminder per Email (Vorlaufzeiten + Cron)

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
high

> User-reported (2026-06-01). v1 = **Email** (gewählt). Web Push = Folge-Ticket FE-060.

## Status
in-progress

## Owner
implementer

## Background
Nutzer sollen erinnert werden, wenn sie ein Spiel **noch nicht getippt** haben —
mit konfigurierbaren **Vorlaufzeiten** vor Anpfiff (z. B. 1 Tag, 12 h, 6 h, 3 h,
1 h), mehrere gleichzeitig aktivierbar. v1-Kanal: **Email** (Mailer aus FE-041).

## Scope
- **In scope**:
  - **Schema** (DB neu erzeugt, keine neue Migrationsdatei — wie FE-033):
    - `reminder_setting` (`id`, `user_id` FK, `lead_minutes`) — je aktivierter
      Vorlaufzeit eine Zeile; unique `(user_id, lead_minutes)`.
    - `reminder_sent` (`id`, `user_id`, `match_id`, `lead_minutes`, `sent_at`)
      — Dedup; unique `(user_id, match_id, lead_minutes)`.
  - **Settings-UI** (`/settings`): Abschnitt „Reminder" mit Toggles je
    Vorlaufzeit (fester Satz als Konstante), Hinweis „per Email". Speichern via
    neue API (`/api/user/reminders`, PUT) — nur eingeloggter User, eigene Settings.
  - **Cron-Endpoint** `/api/cron/notifications` (geschützt per `CRON_SECRET`
    Env, 401 ohne) — extern getriggert (System-Cron, alle ~10 min). Logik:
    für jedes SCHEDULED-Spiel mit Anpfiff in der Zukunft, je User-Vorlaufzeit:
    wenn `now >= utcDate - lead` und `now < utcDate` **und** der User hat das
    Spiel **nicht getippt** **und** für `(user, match, lead)` wurde noch **nicht**
    gesendet → Email senden + `reminder_sent` schreiben (einmalig).
  - **Eligibility-Logik** als reine, testbare Funktion (welche
    `(user, match, lead)`-Tupel sind fällig).
  - i18n (de/en) für Settings + Email-Texte. `CRON_SECRET` in `.env.example`.
- **Out of scope (explicit)**: Web Push / Browser-Push (→ FE-060); pro-User-
  Locale für Emails (v1: deutsche Email; Notiz für später); Änderung der
  Match-Importe/Cron in `macht-api`.

## Lockstep / DB
- Rust nutzt die neuen Tabellen nicht → **keine Rust-Änderung** (bestätigen).
- Laufende DB neu seeden (`pnpm db:reset`) für die neuen Tabellen.

## References
- `lib/mail.ts` (FE-041 Mailer), `lib/rate-limit.ts`, `lib/tip.ts`,
  `lib/match.ts` (`getUpcomingMatches`/Status), `db/schema.ts`,
  `app/(app)/settings/page.tsx`, `messages/*.json`

## Acceptance Criteria
- [ ] Settings: Vorlaufzeiten als Toggles aktiv-/deaktivierbar, persistiert pro User.
- [ ] Cron prüft un-getippte Spiele im eingestellten Fenster und sendet **eine**
      Email pro `(user, match, lead)` (Dedup über `reminder_sent`).
- [ ] Getippte Spiele lösen **keine** Erinnerung aus.
- [ ] Cron-Endpoint ohne gültiges `CRON_SECRET` → 401; keine Auslösung von außen.
- [ ] Eligibility-Logik unit-getestet (fällig/nicht fällig/bereits gesendet/getippt).
- [ ] Kein `NEXT_PUBLIC_`-Secret; `.env`/Secrets nicht committet.
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. Settings → „12 h vorher" aktivieren.
2. Cron-Endpoint mit `CRON_SECRET` triggern bei un-getipptem Spiel im Fenster →
   Email kommt (lokaler SMTP). Zweiter Trigger → keine zweite Email.
3. Spiel tippen → Trigger → keine Email.
