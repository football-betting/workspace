# FE-052 Match-Header: Team-Namen auf Mobile abgeschnitten

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
Im Match-Detail-Header werden auf Mobile die (lokalisierten) Team-Namen zu
einem Buchstaben + „…" abgeschnitten („F…" / „D…") — gefunden im Mobile-Audit
(FE-040). Die schmalen Spalten links/rechts des Scores reichen nicht, seit
FE-034 die vollen Namen lokalisiert (z. B. „Frankreich"/„Deutschland").

## Symptom (bugs only)
`/match/{id}` auf Mobile → Team-Name im Header ist „F…"/„D…" statt lesbar.

## Scope
- **In scope**: `components/match/MatchHeader.tsx` (`TeamBlock`) mobil lesbar
  machen — z. B. auf Mobile den **TLA-Code** (GER/FRA) statt des vollen Namens
  zeigen, ab Breakpoint den vollen Namen; oder Layout/Umbruch so anpassen, dass
  der Name nicht auf einen Buchstaben schrumpft. Konsistent mit der übrigen
  Flag+TLA-Darstellung.
- **Out of scope**: Redesign des Headers; Score-Anzeige.

## References
- `frontend/components/match/MatchHeader.tsx` — `TeamBlock` (`truncate w-full`)
- `frontend/lib/country.ts` — lokalisierte Namen (FE-034)

## Acceptance Criteria
- [ ] Mobile (360–414px): Team-Identität im Header ist lesbar (voller Name **oder**
      TLA-Code), kein Ein-Buchstaben-„…".
- [ ] Desktop unverändert (voller lokalisierter Name).
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. `/match/{live}` auf Mobile → beide Teams erkennbar (Name oder Code).
