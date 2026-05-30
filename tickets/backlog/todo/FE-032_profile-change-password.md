# FE-032 „Profile Settings"-Seite (/settings): Passwort, Logout, Avatar

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
Es soll eine eigene Settings-Seite geben (Design: `design/account.html`, h1
„Profile Settings"), erreichbar nur für den eigenen Account. Sie bündelt:
Avatar, Passwort ändern und **Logout** — Letzteres besonders, weil die
Mobile-Navigation aktuell **keinen** Logout-Eintrag hat. Route: **/settings**.

## Scope
- **In scope**:
  - Neue, session-geschützte Route `app/(app)/settings/page.tsx`
    (eigener Account; Layout-Guard wie andere `(app)`-Seiten).
  - **Identity**: Avatar-Anzeige + „Foto hochladen"-Button (Funktionalität
    liefert FE-036; hier nur die UI/Einbindung), Username + Email (read-only,
    eigener Account — Email hier OK).
  - **Security**: Passwort-ändern-Formular (aktuelles / neues / Wiederholung).
    Server-Endpoint: Session prüfen (userId **nur** aus Session, IDOR-sicher),
    aktuelles Passwort per Argon2id verifizieren, Regeln (min. 8 Zeichen),
    neues Passwort hashen/speichern, Rate-Limit wie andere Auth-Routen.
  - **Session**: Logout-Button, der auch auf Mobile funktioniert.
  - Zugang von Profil/Nav zur Settings-Seite.
- **Out of scope (explicit)**: Avatar-Upload-Funktionalität selbst (FE-036);
  2FA aus dem Design; Email-/Username-Änderung; Passwort-Reset per Email.

## References
- `frontend/design/account.html` — Design-Vorlage
- `frontend/app/api/auth/login/route.ts` — Argon2id-Konfiguration als Vorlage
- `frontend/app/api/auth/logout/route.ts` — Logout
- `frontend/lib/validation/auth.ts` — Passwort-Regeln
- `frontend/lib/rate-limit.ts`, `frontend/lib/user.ts`
- `frontend/components/dashboard/BottomNav.tsx` — Mobile-Nav (kein Logout)

## Acceptance Criteria
- [ ] `/settings` nur eingeloggt erreichbar (sonst Redirect `/login`).
- [ ] Passwort ändern: falsches altes PW → Fehler; neues < 8 Zeichen oder
      Wiederholung ≠ → Fehler; Erfolg → neues PW gilt beim nächsten Login;
      userId nur aus Session.
- [ ] Logout-Button funktioniert (auch auf Mobile erreichbar/sichtbar).
- [ ] Avatar-Bereich mit Upload-Button vorhanden (verdrahtet mit FE-036).
- [ ] 2FA wird **nicht** implementiert.
- [ ] Tests: Endpoint-Validierung/-Logik (Unit), wo testbar.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. `/settings` ausgeloggt → `/login`.
2. Eingeloggt → Passwort ändern (korrekt/falsch/zu kurz) verhält sich korrekt.
3. Logout-Button → ausgeloggt; auf Mobile sichtbar/erreichbar.
