# FE-022 Result — Remember-me: Login mehrere Tage halten

**Geschlossen**: 2026-05-29
**Commits**:
- `frontend` (main) `8e3fa75 FE-022: add remember-me option controlling session cookie persistence (#27)` (squash-merge von PR #27)

## Was wurde gemacht

"Remember me"-Checkbox am Login. Angehakt → persistenter Session-Cookie
(30 Tage, Lucia-Default-Attribute); nicht angehakt → Session-Cookie ohne
`maxAge`/`expires` (endet beim Browser-Schließen). Da Lucias
Session-Cookie-Ablauf global ist, markiert ein Begleit-Cookie `auth_remember`
die Wahl; sowohl die Login-Route als auch der `session.fresh`-Refresh in
`lib/session.ts` lesen ihn, damit ein Session-Cookie beim Refresh nicht
heimlich persistent wird. `HttpOnly`, `SameSite` und `Secure` (prod) bleiben
in allen Pfaden erhalten.

## Geänderte Dateien

Alle in `frontend/`:

- `lib/auth.ts` — `REMEMBER_COOKIE` + `REMEMBER_MAX_AGE_SECONDS` exportiert
- `app/api/auth/login/route.ts` — `remember` aus FormData, persistent vs.
  session-scoped Cookie, Begleit-Cookie setzen/löschen
- `lib/session.ts` — Refresh respektiert `auth_remember`
- `app/(auth)/login/login-form.tsx` — "Remember me"-Checkbox

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **77/77 passed**

## Reviewer-Feedback

Reviewer-Agent: **APPROVE** (Security-fokussiert). Cookie-Sicherheitsattribute
in allen drei Pfaden erhalten, keine Session-Fixation, Refresh-Gotcha korrekt,
`delete` auf `CookieAttributes` typsicher. Hinweis (kein Blocker): kein
automatisierter Test ergänzt — natürlicher Ort wäre ein Playwright-Check der
Cookie-Lebensdauer; per Workflow ein Tester-Dispatch, kein Bounce.

## Notiz

Commit berührt nur die vier Dateien; gestagte `public/img/bg*.png` (FE-028)
ausgeschlossen.
