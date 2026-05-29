# FE-029 Profil-Navigation zeigt auf nicht existierende Route

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
Die Navigation (Top-Bar und Bottom-Nav) hat einen "Profile"-Eintrag, der auf
`/profile` verlinkt. Eine solche Route existiert nicht — Profile leben unter
`/user/{id}`. Ein Klick auf "Profile" landet daher auf einer 404-Seite.

## Symptom (bugs only)
1. Eingeloggt, im Dashboard auf "Profile" (Top-Bar oder Bottom-Nav) klicken
   bzw. `http://localhost:3000/profile` aufrufen.
2. → 404 / Seite kaputt, statt das eigene Profil zu zeigen.

## Scope
- **In scope**:
  - `/profile` auflösen, sodass der "Profile"-Link das **eigene** Profil des
    eingeloggten Nutzers zeigt. Bevorzugt: neue Route
    `app/(app)/profile/page.tsx`, die auf `/user/{session.user.id}`
    weiterleitet (eine einzige Profil-Implementierung bleibt erhalten).
- **Out of scope (explicit)**: Redesign der Profilseite; Änderung der
  `/user/{id}`-Logik; neue Nav-Einträge.

## References
- `frontend/components/dashboard/TopAppBar.tsx` (Z. 10) — `href: "/profile"`
- `frontend/components/dashboard/BottomNav.tsx` (Z. 10) — `href: "/profile"`
- `frontend/app/(app)/user/[id]/page.tsx` — bestehende Profilseite
- `frontend/lib/session.ts` — `getCurrentSession`

## Acceptance Criteria
- [ ] `GET /profile` eingeloggt → eigenes Profil (Redirect auf
      `/user/{eigene-id}` oder direkte Anzeige), **kein** 404.
- [ ] `GET /profile` ausgeloggt → Redirect `/login` (kein 404, kein
      geworfener Error — konsistent mit FE-021).
- [ ] "Profile"-Link in Top-Bar und Bottom-Nav führt zum eigenen Profil.
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Eingeloggt → "Profile" klicken → eigenes Profil erscheint.
2. `http://localhost:3000/profile` direkt → eigenes Profil.
3. Ausgeloggt `/profile` → landet auf `/login`.
