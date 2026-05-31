# FE-051 Result — Mobile BottomNav: alle 4 Labels lesbar

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `a7f3656 FE-051: fit all four bottom-nav labels on mobile (#47)` (squash-merge PR #47)

## Was wurde gemacht
Die 4 BottomNav-Einträge teilen sich jetzt die Breite gleichmäßig (`flex-1
min-w-0`), horizontales Padding reduziert (`px-4`→`px-1`), Label kleiner/enger
und einzeilig zentriert (`text-[0.625rem] tracking-tight leading-none`). Damit
ist „Einstellungen" (längstes Label) auf 360–414px vollständig sichtbar — kein
„EINSTELLU…" mehr. i18n-Keys unverändert (de/en).

## Geänderte Dateien
- `frontend/components/dashboard/BottomNav.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest). Self-Review (kosmetisch, responsive).
