# FE-041 Passwort-vergessen + Mail-Sende-Service

## Repo
frontend

## Type
feature

## Risk
high

## Priority
medium

## Status
todo

## Owner
implementer

> `high` → externer Review erforderlich vor `done` (Auth-/Security-Flow).

## Background
Nutzer sollen ihr Passwort zurücksetzen können („Passwort vergessen"). Dafür
braucht es (a) einen wiederverwendbaren **Mail-Sende-Service** und (b) den
Reset-Flow per Email-Link.

## Konfiguration (KEINE Secrets hier)
Die SMTP-Zugangsdaten kommen ausschließlich aus **Umgebungsvariablen**
(`SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`)
und liegen **lokal** in der gitignored `.env` — **niemals committen, keine
Werte in diesem Ticket**. Port 587 nutzt STARTTLS (`SMTP_SECURE=false`).
Server-only (kein `NEXT_PUBLIC_`).

## Scope
- **In scope**:
  - **Mailer** (`lib/mail.ts`): eine gekapselte Klasse/Funktion zum
    Mailversand (nodemailer), Transport aus den o. g. Env-Vars. Nur
    serverseitig importierbar (kein Client-Bundle-Leak). Liefert klare Fehler,
    loggt keine Secrets.
  - **Forgot-Password**: Seite + API — Eingabe der Email → falls Nutzer
    existiert, zeitlich begrenztes Reset-Token erzeugen (gehasht speichern) und
    Reset-Link per Mail senden. **Kein User-Enumeration-Leak** (immer gleiche
    generische Antwort, egal ob Email existiert). Rate-Limit wie andere
    Auth-Routen.
  - **Reset-Password**: Seite + API — Token validieren (gültig, nicht
    abgelaufen, einmalig) → neues Passwort (Regeln, Argon2id) setzen → Token
    invalidieren.
  - **Schema**: Reset-Token-Speicher (neue Tabelle, z. B.
    `password_reset_token` mit `user_id`, Token-Hash, `expires_at`). DB wird
    neu erzeugt — keine Migrationsdatei (wie FE-033). Lockstep: Rust-Structs
    nutzen die Tabelle nicht → keine Rust-Änderung (bestätigen).
  - „Passwort vergessen?"-Link auf der Login-Seite.
  - Abhängigkeit `nodemailer` hinzufügen (+ Build-Approval falls nötig).
- **Out of scope (explicit)**: 2FA; Email-Verifikation bei Registrierung;
  Magic-Link-Login; HTML-Email-Templates über das Nötige hinaus.

## References
- `frontend/app/api/auth/login/route.ts` — Argon2id-Konfiguration als Vorlage
- `frontend/lib/validation/auth.ts` — Passwort-Regeln
- `frontend/lib/rate-limit.ts`
- `frontend/db/schema.ts` — neue Token-Tabelle
- Mailer-Config: Env-Vars (Werte lokal in `.env`, nicht committet)

## Acceptance Criteria
- [ ] `lib/mail.ts` versendet Mail über die Env-SMTP-Config; server-only;
      keine Secrets im Log/Bundle.
- [ ] Forgot-Password: existierende Email → Reset-Mail mit gültigem Link;
      nicht existierende Email → **dieselbe** generische Antwort (kein Leak).
- [ ] Reset-Link mit gültigem, nicht abgelaufenem, einmaligem Token → neues
      Passwort setzbar; gilt beim nächsten Login. Abgelaufenes/benutztes Token
      → Fehler.
- [ ] Rate-Limit auf Forgot/Reset.
- [ ] „Passwort vergessen?"-Link auf `/login`.
- [ ] Kein `NEXT_PUBLIC_`-SMTP; `.env` bleibt ungetrackt; keine Secrets im Repo.
- [ ] Tests: Token-Validierung/-Ablauf, Mailer-Konfig (gemockt), wo testbar.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. `/login` → „Passwort vergessen?" → Email eingeben → Reset-Mail kommt an
   (lokaler SMTP-Test mit echten `.env`-Creds).
2. Link öffnen → neues Passwort setzen → Login mit neuem Passwort klappt.
3. Link erneut/abgelaufen → abgelehnt.
4. Unbekannte Email → gleiche generische Antwort.
