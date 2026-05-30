# FE-052 Result — Match-Header Team-Namen auf Mobile lesbar

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `2cd891d FE-052: show team TLA on mobile (full localized name on desktop) in match header (#45)` (squash-merge von PR #45)

## Was wurde gemacht
`MatchHeader` `TeamBlock`: auf Mobile (`md:hidden`) den **TLA-Code** (FRA/GER),
ab `md` den vollen lokalisierten Namen. Behebt das Ein-Buchstaben-„F…"/„D…"
aus dem Mobile-Audit (FE-040).

## Geänderte Dateien
- `frontend/components/match/MatchHeader.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün. Self-Review (kosmetisch, responsive Klassen).
