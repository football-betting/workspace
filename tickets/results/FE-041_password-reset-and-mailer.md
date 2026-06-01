# FE-041 Result — Passwort-vergessen + Mail-Sende-Service

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `ef8c7e2 FE-041: add forgot/reset password flow with reusable SMTP mailer (#57)` (squash-merge PR #57)
**Risk**: high → **externe Security-Review durchgeführt** (frischer reviewer-Kontext): PASS. Host-Header-Injection geprüft (unter `next start` ohne `trustHostHeader` nicht ausnutzbar), Enumeration-Schutz (Response + Timing), Token gehasht/single-use/Ablauf, Mailer server-only ohne Secret-Leak, Argon2id-Konfig identisch zu Login — alles bestätigt.

## Was wurde gemacht
- **Mailer** `lib/mail.ts` (nodemailer, `import "server-only"`, Transport lazy aus
  `SMTP_*`-Env, keine Secrets im Log/Bundle) + `sendPasswordResetEmail`.
- **Forgot-Flow**: `/forgot-password` (Seite + API) — existierende Email → 60-min,
  einmaliges Token (nur SHA-256-Hash gespeichert) + Reset-Link per Mail; **immer
  dieselbe generische Antwort** (kein Enumeration-Leak, gleiche Vorarbeit in beiden
  Zweigen → kein Timing-Oracle). Rate-Limit.
- **Reset-Flow**: `/reset-password?token=…` (Seite + API) — Token nach Hash prüfen
  (gültig/nicht abgelaufen/einmalig) → neues Passwort (Regeln, Argon2id wie Login)
  setzen → alle Tokens des Users löschen. Rate-Limit, generische Fehler.
- „Passwort vergessen?"-Link auf `/login`; Sprachumschalter via Auth-Layout.
- **Schema**: neue Tabelle `password_reset_token` (`user_id` FK, `token_hash`
  unique, `expires_at`) in der **0000-Baseline** (kein neues Migrations-File, wie
  FE-033). **Lockstep**: Rust nutzt die Tabelle nicht → keine Rust-Änderung.
- **Config**: `APP_BASE_URL` (vertrauenswürdiger Link-Origin) + SMTP-Var-Namen in
  `.env.example` dokumentiert (leer, keine Werte). Reale Creds nur lokal in `.env`.

## Geänderte/neue Dateien (frontend)
- `lib/mail.ts`, `lib/password-reset.ts`, `lib/password-reset-store.ts` (neu)
- `app/api/auth/forgot-password/route.ts`, `app/api/auth/reset-password/route.ts` (neu)
- `app/(auth)/forgot-password/*`, `app/(auth)/reset-password/*` (neu), `app/(auth)/login/page.tsx`
- `db/schema.ts` + `db/migrations/0000_*.sql` + `meta/0000_snapshot.json`
- `lib/validation/password.ts` (`resetPasswordSchema`), `messages/de.json`/`en.json`
- `tests/unit/password-reset.test.ts`, `tests/unit/mail.test.ts`, `tests/stubs/server-only.ts`, `vitest.config.ts`
- `package.json` (nodemailer + @types/nodemailer), `.env.example`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + **166 Tests**, i18n-Parität)
- `bash scripts/check.sh --build` → Full Next-Build grün; kein nodemailer/SMTP im Client-Bundle

## Hinweis für manuellen Test
- **DB neu seeden** (`pnpm db:reset`) — die neue Tabelle `password_reset_token`
  ist Teil der Baseline; die laufende DB hat sie sonst noch nicht.
- Für echten Mailversand `SMTP_USER`/`SMTP_PASS`/`SMTP_FROM` lokal in `.env`
  füllen (Host/Port stehen). `APP_BASE_URL=http://localhost:3000` ist lokal gesetzt.
