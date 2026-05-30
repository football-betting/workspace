# FE-037 Result — Dashboard-Rangliste-Platzierung + globaler Fokus

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `f085114 … (#34)` (squash-merge von PR #34)

## Was wurde gemacht
- **Rangliste-Platzierung** (`app/(app)/page.tsx`): `< 980px` sitzt die
  Mini-Rangliste zwischen Live-Block und Upcoming-Liste; `≥ 980px` als rechte
  Sidebar (Custom-Breakpoint `min-[980px]` statt `md`). Zwei responsive
  Instanzen.
- **Globaler Fokus** (`app/globals.css`): `:focus-visible`-Outline in
  `var(--color-primary)` statt der nativen Weiß/Blau-Outline.

## Geänderte Dateien
- `frontend/app/(app)/page.tsx`
- `frontend/app/globals.css`
(im selben PR #34 wie FE-025/FE-027)

## Quality-Gate
- `tsc --noEmit`, `vitest run`, `build` → grün.

## Notiz
Ticket rückwirkend dokumentiert — die Arbeit entstand während der
Live-Dashboard-Politur mit dem Owner.
