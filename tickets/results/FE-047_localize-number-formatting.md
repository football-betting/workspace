# FE-047 Result — Zahlen-Formatierung lokalisiert

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `693951e FE-047: format profile points using the active locale (#49)` (squash-merge PR #49)

## Was wurde gemacht
`ProfileHeader.formatPoints` nutzte hart `toLocaleString("de-DE")`. Jetzt wird
die aktive Sprache via `useLocale()` durchgereicht (`points.toLocaleString(locale)`),
Muster wie `lib/format.ts`. Punkte-Gruppierung folgt damit DE/EN.

Grep bestätigt: dies war die **einzige** hartcodierte Zahlen-Locale im UI
(keine weiteren `toLocaleString("de-DE")`/`Intl.NumberFormat`-Stellen).

## Geänderte Dateien
- `frontend/components/profile/ProfileHeader.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (low-risk, eine Locale-Quelle).
