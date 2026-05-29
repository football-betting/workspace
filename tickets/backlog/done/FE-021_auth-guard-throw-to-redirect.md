# FE-021 Auth-Guard: throw durch Redirect ersetzen

## Repo
frontend

## Type
bug

## Risk
low

## Priority
high

## Status
todo

## Owner
implementer

## Background
Geschützte Seiten unter `app/(app)/` sollen unauthentifizierte Besucher auf
`/login` umleiten. Das Layout macht das korrekt. Dashboard- und Profil-Seite
re-implementieren den Check aber zusätzlich und werfen dabei einen harten
`Error` statt umzuleiten — entgegen der ausdrücklich in `lib/session.ts`
dokumentierten Konvention ("Do not re-implement the unauthenticated check in
individual pages"). Im App Router rendern Layout und Page parallel, daher
feuert der `throw` bei jedem unauthentifizierten Aufruf und wird als
Server-Fehler (mit `digest`) geloggt, obwohl der Redirect des Layouts die
Antwort gewinnt. In Produktion ist das ein Timing-Race, der den generischen
Fehler an die Error-Boundary / ins Monitoring spülen kann.

## Symptom (bugs only)
1. App-Server starten (`pnpm dev`), ohne eingeloggt zu sein.
2. `GET /` aufrufen → Konsole zeigt `⨯ Error: Dashboard rendered without a
   session — auth guard failed` (`app/(app)/page.tsx:27`), Response ist
   trotzdem `307 → /login`.
3. `GET /user/1` ohne Session → analoger `⨯ Error: Profile rendered without a
   session — auth guard failed` (`app/(app)/user/[id]/page.tsx:39`).

## Scope
- **In scope**:
  - `app/(app)/page.tsx` — `throw new Error(...)` entfernen; sich auf den
    Layout-Guard verlassen oder, falls die Page `user` typsicher braucht,
    `redirect("/login")` statt `throw` verwenden.
  - `app/(app)/user/[id]/page.tsx` — analog.
- **Out of scope (explicit)**: Änderungen am Layout-Guard oder an
  `lib/session.ts`; weitere Seiten unter `app/(app)/`, die das Muster nicht
  verletzen.

## References
- `frontend/app/(app)/page.tsx` (Z. 24–27)
- `frontend/app/(app)/user/[id]/page.tsx` (Z. 37–39)
- `frontend/app/(app)/layout.tsx` — korrektes `redirect("/login")`-Muster
- `frontend/lib/session.ts` — dokumentierte Guard-Konvention

## Acceptance Criteria
- [ ] `GET /` ohne Session → `307`/Redirect auf `/login`, **kein** `⨯ Error`
      und kein Error-`digest` im Server-Log.
- [ ] `GET /user/1` ohne Session → Redirect auf `/login`, kein Error-Log.
- [ ] Eingeloggt: Dashboard und Profil rendern unverändert.
- [ ] Kein `throw new Error(... auth guard ...)` mehr im `app/(app)/`-Baum
      (`grep` leer).
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Ausgeloggt `GET /` → landet auf `/login`, Server-Log sauber.
2. Ausgeloggt `GET /user/2` → landet auf `/login`, Server-Log sauber.
3. Einloggen, `/` und `/user/<eigene-id>` öffnen → Seiten rendern normal.
