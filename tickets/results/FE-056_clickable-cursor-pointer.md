# FE-056 Result — cursor-pointer auf klickbaren Elementen (Tailwind v4)

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `7aa54aa FE-056: restore pointer cursor on interactive elements (Tailwind v4) (#58)` (squash-merge PR #58)

## Was wurde gemacht
Tailwind v4 setzt `<button>` standardmäßig auf `cursor: default`. Globaler
Base-Layer-Fix in `app/globals.css` (offizielles v4-Rezept):
`button:not(:disabled)`, `[role="button"]:not(:disabled)`, `select:not(:disabled)`,
`summary`, `label[for]` → `cursor: pointer`. Disabled-Buttons bleiben ohne
Pointer; Links hatten ihn ohnehin. Eine zentrale Regel deckt die ganze App ab.

## Geänderte Dateien
- `frontend/app/globals.css`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (CSS-only, low-risk).
