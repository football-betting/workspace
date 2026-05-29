# FE-032 Profil (eigenes): Passwort ändern

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Auf dem **eigenen** Profil soll der Nutzer sein Passwort ändern können. Andere
Profile bieten diese Möglichkeit nicht.

## Scope
- **In scope**:
  - Passwort-ändern-Formular nur auf dem eigenen Profil (aktuelles Passwort,
    neues Passwort, Wiederholung).
  - Server-Endpoint, der die Session prüft (userId nur aus der Session, nie aus
    Body/URL — IDOR-sicher), das aktuelle Passwort per Argon2id verifiziert,
    die Passwort-Regeln (min. 8 Zeichen) anwendet und das neue Passwort
    hasht/speichert. Rate-Limit wie bei anderen Auth-Routen.
- **Out of scope (explicit)**: Passwort-vergessen/Reset per Email;
  Email-Änderung; Username-Änderung.

## References
- `frontend/app/api/auth/login/route.ts` — Argon2id-Konfiguration als Vorlage
- `frontend/lib/validation/auth.ts` — Passwort-Regeln
- `frontend/lib/rate-limit.ts` — Rate-Limiting
- `frontend/lib/user.ts` — User-Lese/Schreib-Helfer
- `frontend/app/(app)/user/[id]/page.tsx` — `isOwnProfile`

## Acceptance Criteria
- [ ] Eigenes Profil zeigt „Passwort ändern"; fremde Profile nicht.
- [ ] Falsches aktuelles Passwort → Fehler, kein Update.
- [ ] Neues Passwort < 8 Zeichen oder Wiederholung ≠ → Fehler, kein Update.
- [ ] Erfolgreicher Wechsel → neues Passwort gilt beim nächsten Login; userId
      stammt ausschließlich aus der Session.
- [ ] Tests: Validierung/Logik des Endpoints (Unit), wo testbar.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Eigenes Profil → Passwort ändern mit korrektem alten PW → Erfolg, Re-Login
   mit neuem PW klappt.
2. Falsches altes PW → Fehler. Zu kurzes neues PW → Fehler.
