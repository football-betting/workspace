# FE-026 Result — Match-Detail: Anstoßdatum und -zeit immer anzeigen

**Geschlossen**: 2026-05-29
**Commits**:
- `frontend` (main) `7b6f4ef FE-026: show kickoff date and time on match detail for all match states (#25)` (squash-merge von PR #25)

## Was wurde gemacht

`StatusSublabel` in `MatchHeader` zeigt das Anstoßdatum + Uhrzeit jetzt für
**alle** Spielzustände, nicht nur `SCHEDULED`:
- `FINISHED` → Datum + Uhrzeit (statt redundantem "FULL TIME"; das
  FULL-TIME-Badge bleibt oben über `StatusBadge`).
- `LIVE` → Live-Minute **und** Datum + Uhrzeit.
- `SCHEDULED` → Datum + Uhrzeit (unverändert).

Genutzt werden die bestehenden Helfer `formatDate` / `extractTime`.

## Geänderte Dateien

Alle in `frontend/`:

- `components/match/MatchHeader.tsx` — `StatusSublabel` umstrukturiert
  (gemeinsame `kickoffLine`, in allen Zweigen gerendert)

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **77/77 passed**
- Prettier-Hook lief auf dem Edit

## Notiz

Commit berührt nur `MatchHeader.tsx`; die gestageten `public/img/bg*.png`
(FE-028) wurden ausgeschlossen.
