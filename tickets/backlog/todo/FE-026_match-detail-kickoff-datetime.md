# FE-026 Match-Detail: Anstoßdatum und -zeit immer anzeigen

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
todo

## Background
Auf der Match-Detail-Seite (`/match/{id}`) soll erkennbar sein, **wann** das
Spiel angestoßen wurde — Datum und Uhrzeit. Aktuell zeigt der `MatchHeader`
diese Info nur für anstehende Spiele (Status `SCHEDULED`). Bei laufenden
Spielen erscheint stattdessen die Spielminute, bei beendeten nur "FULL TIME".
Für ein bereits gespieltes Spiel (z. B. `/match/4`) ist Datum/Uhrzeit damit
nicht sichtbar.

## Symptom (bugs only)
1. `/match/4` (beendetes oder laufendes Spiel) öffnen.
2. Im Header steht "FULL TIME" bzw. die Minute, aber **kein** Anstoßdatum und
   keine Uhrzeit.

## Scope
- **In scope**:
  - `components/match/MatchHeader.tsx` — Anstoßdatum + Uhrzeit auch für
    Status `FINISHED` und `LIVE` anzeigen (zusätzlich zum Status-Label), nicht
    nur für `SCHEDULED`.
- **Out of scope (explicit)**: Layout-Redesign des Headers; Zeitzonen-/
  Lokalisierungslogik über die bestehenden Format-Helfer hinaus; Änderungen an
  `getMatchById`.

## References
- `frontend/components/match/MatchHeader.tsx` — `StatusSublabel` rendert
  `formatDate · extractTime` nur im `SCHEDULED`-Zweig
- `frontend/lib/format.ts` — `formatDate`, `extractTime`
- `frontend/app/(app)/match/[id]/page.tsx` — Seite, nutzt `MatchHeader`

## Acceptance Criteria
- [ ] `/match/{id}` eines **beendeten** Spiels zeigt Anstoßdatum + Uhrzeit.
- [ ] `/match/{id}` eines **laufenden** Spiels zeigt Anstoßdatum + Uhrzeit
      (zusätzlich zur Live-Minute).
- [ ] `/match/{id}` eines **anstehenden** Spiels zeigt Datum + Uhrzeit wie
      bisher.
- [ ] Format über die bestehenden Helfer (`formatDate`, `extractTime`).
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. `/match/<beendetes Spiel>` → Datum + Uhrzeit sichtbar.
2. `/match/<laufendes Spiel>` → Datum + Uhrzeit + Minute sichtbar.
3. `/match/<anstehendes Spiel>` → unverändert Datum + Uhrzeit.
