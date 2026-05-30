# FE-032 Result — „Profile Settings"-Seite (/settings)

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `b7c2ffa FE-032: profile settings page (/settings) with change-password, mobile logout, avatar placeholder (#41)` (squash-merge von PR #41)

## Was wurde gemacht

Neue Route `app/(app)/settings/page.tsx` (session-geschützt) nach
`design/account.html`: **Identity** (Avatar-Platzhalter + Username/Email
read-only), **Security** (Passwort ändern), **Session** (Logout).
- **Passwort-ändern-Endpoint** `app/api/user/password/route.ts`: userId **nur**
  aus Session (IDOR-sicher), aktuelles PW per **Argon2id** verifiziert (Config
  wie Login), Regeln server-validiert (min 8, neu==Wiederholung), neues PW
  gehasht gespeichert, Rate-Limit (`"password"`-Bucket), saubere JSON-Fehler.
- **Logout** auch auf **Mobile** erreichbar (BottomNav hatte keinen) — eigener
  Mobile-Header + Session-Card.
- **Avatar** „Foto ändern" ist ein inerter Platzhalter (Upload = FE-036).
- Settings-Zugang in Top-Nav (Zahnrad) + Bottom-Nav.
- 2FA aus dem Mock: **out of scope**.

## Geänderte Dateien (frontend)
- neu: `app/(app)/settings/page.tsx`, `app/api/user/password/route.ts`,
  `components/settings/PasswordChangeForm.tsx`, `lib/validation/password.ts`,
  `tests/unit/password-validation.test.ts`
- geändert: `lib/user.ts` (`updateUserPassword`), `components/dashboard/TopAppBar.tsx`,
  `components/dashboard/BottomNav.tsx`, `messages/de.json`, `messages/en.json`

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **104/104** (inkl. 6 Passwort-Tests);
  `--build` → ok.

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** — IDOR strukturell unmöglich (userId nur Session),
Argon2id-Verify vor Update, server-validiert, rate-limited, kein Leak,
i18n-Parität, kein `any`.

## Notiz
Server-Fehlertexte bleiben (wie Login) hartcodiert EN → wird von **FE-044**
(i18n-Audit) abgedeckt; client-gerenderte Strings laufen über next-intl.
