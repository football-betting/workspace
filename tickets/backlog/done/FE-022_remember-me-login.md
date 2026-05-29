# FE-022 Remember-me: Login mehrere Tage halten

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
Aktuell entscheidet allein die Lucia-Default-Konfiguration, wie lange ein
Login gilt. Nutzer wollen optional über mehrere Tage eingeloggt bleiben, ohne
sich bei jedem Besuch neu anzumelden. Es soll eine "Remember me"-Option am
Login geben: angehakt bleibt die Sitzung über einen persistenten Cookie 30
Tage bestehen; nicht angehakt verhält sich der Login wie ein reiner
Session-Cookie, der beim Schließen des Browsers endet.

## Scope
- **In scope**:
  - "Remember me"-Checkbox im Login-Formular.
  - Login-Flow: bei aktiver Checkbox persistenten Session-Cookie mit 30 Tagen
    Lebensdauer setzen; sonst Session-Cookie ohne `expires`/`maxAge`.
  - Sicherstellen, dass die serverseitige Session-Gültigkeit zur
    Cookie-Lebensdauer passt.
- **Out of scope (explicit)**: "Stay signed in"-Verwaltung in den
  Account-Einstellungen; Geräte-/Session-Übersicht; Änderungen am
  Signup-Flow.

## References
- `frontend/app/(auth)/login/login-form.tsx` — Formular, postet an
  `/api/auth/login`
- `frontend/app/api/auth/login/route.ts` — Login-Handler, setzt Session-Cookie
- `frontend/lib/auth.ts` (Z. 16–21) — Lucia `sessionCookie.attributes`; aktuell
  kein `sessionExpiresIn` gesetzt (Default 30 Tage)
- `frontend/lib/session.ts` — Cookie-Refresh bei `session.fresh`

## Notes
Lucias `sessionExpiresIn` ist global, nicht pro Login. Für die zwei Modi muss
beim Setzen des Cookies (`createSessionCookie`) das `maxAge`/`expires`-Attribut
je nach Checkbox überschrieben werden: persistent (30 Tage) vs. Session-Cookie
(kein `maxAge`). Der `secure`-Flag aus `lib/auth.ts` bleibt erhalten;
`httpOnly` und `sameSite` nicht abschwächen.

## Acceptance Criteria
- [ ] Login-Seite zeigt eine "Remember me"-Checkbox (Default: aus).
- [ ] Login mit angehakter Checkbox → Session-Cookie mit `Max-Age`/`Expires`
      ~30 Tage in der Zukunft.
- [ ] Login ohne Checkbox → Session-Cookie ohne `Max-Age`/`Expires`
      (endet beim Browser-Schließen).
- [ ] Cookie behält `HttpOnly`, `SameSite` und (in production) `Secure`.
- [ ] Bestehende Sessions/Logins funktionieren unverändert.
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Login mit "Remember me" an → DevTools → Cookie hat Ablauf ~30 Tage.
2. Browser komplett schließen/neu öffnen → noch eingeloggt.
3. Login ohne "Remember me" → Cookie ist Session-Cookie (kein Ablaufdatum).
4. Browser schließen → ausgeloggt.
