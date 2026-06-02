# FE-067 Result — Kleine Aufräumarbeiten

**Geschlossen**: 2026-06-02
**Commit**: `frontend` (main) `9f67230 (#69)`

## Was wurde gemacht
- Toter Export `hasReminderBeenSent` (`lib/reminder-store.ts`) entfernt.
- Redundantes `clampPerMatchPoints` (`components/profile/PredictionHistory.tsx`)
  entfernt — `tip.score` (0/2/3/5 aus Rust) direkt genutzt.
- Avatar-Cache-Busting vereinheitlicht: die Route speichert jetzt einen
  versionierten Pfad (`/uploads/avatars/{id}.webp?v=<ts>`) → Re-Upload ist
  überall (Profil, Mini-Rangliste, SW-Cache) sofort aktuell. Der `?t=`-Hack nur
  in der Upload-Vorschau entfällt.

## Geänderte Dateien
- `frontend/lib/reminder-store.ts`, `components/profile/PredictionHistory.tsx`,
  `app/api/user/avatar/route.ts`, `components/settings/AvatarUpload.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün (189 Tests).
