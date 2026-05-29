# FE-029 Result — Profil-Navigation zeigt auf nicht existierende Route

**Geschlossen**: 2026-05-29
**Commits**:
- `frontend` (main) `e7c62b8 FE-029: add /profile route redirecting to the signed-in user's profile (#26)` (squash-merge von PR #26)

## Was wurde gemacht

Neue Route `app/(app)/profile/page.tsx` angelegt. Sie ermittelt die aktuelle
Session und leitet auf `/user/{user.id}` weiter — der "Profile"-Link in
Top-Bar und Bottom-Nav zeigt damit wieder das eigene Profil. Unauthentifiziert
leitet sie (wie alle `(app)`-Seiten seit FE-021) auf `/login` um. Es bleibt
eine einzige Profil-Implementierung (`/user/[id]`).

## Geänderte Dateien

Alle in `frontend/`:

- `app/(app)/profile/page.tsx` (neu) — Redirect-Route auf das eigene Profil

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **77/77 passed**
- Prettier-Hook lief auf dem neuen File

## Notiz

Commit berührt nur die neue Route; die gestageten `public/img/bg*.png`
(FE-028) wurden ausgeschlossen.
