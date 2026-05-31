# FE-055 Result — Avatar-Kamera-Icon klickbar

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `cfce56d FE-055: make avatar camera icon trigger the photo picker (#52)` (squash-merge PR #52)

## Was wurde gemacht
Der Avatar + Kamera-Badge in `AvatarUpload` war ein dekoratives `aria-hidden`-
Overlay; nur der Text-Button löste den Datei-Dialog aus. Jetzt ist der
Avatar-Block selbst ein `<button>`, der denselben `inputRef.click()` auslöst —
mit `aria-label` (vorhandener i18n-Key `changePhoto`, de/en), sichtbarem
Fokus-Ring und Hover-Affordanz (Kamera-Badge färbt sich). Text-Button + Upload-
Flow unverändert.

## Geänderte Dateien
- `frontend/components/settings/AvatarUpload.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (low-risk, a11y beachtet).
