# FE-062 Result — Sessions bei Passwort-Reset/-Änderung invalidieren

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `498b120 FE-062: invalidate sessions on password reset and change (#64)` (PR #64)
**Risk**: high → reviewer-Pass (frischer Kontext): ID-Typen korrekt (`String(userId)`), Cookie-Attribution exakt wie Login, Reihenfolge invalidate→create→set verifiziert.

## Was wurde gemacht
- Reset (`app/api/auth/reset-password/route.ts`): nach Passwort-Update
  `lucia.invalidateUserSessions(String(record.userId))` → **alle** Sessions sterben.
- Change (`app/api/user/password/route.ts`): `invalidateUserSessions(sessionUser.id)`
  → dann frische Session erzeugen + Cookie setzen (Remember-me-Logik wie Login) →
  **andere** Sessions tot, Akteur bleibt eingeloggt.

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + 183 Tests).
