# FE-035 Flaggen-Icons für alle Demo- und WM-2026-Länder

## Repo
frontend

## Type
chore

## Priority
medium

## Risk
low

## Status
todo

## Owner
implementer

## Background
Flaggen werden über `components/dashboard/Flag.tsx` als
`/svg/{TLA}.svg` aus `public/svg/` geladen (mit FIFA→IOC-Mapping für einige
Codes). Es müssen Flaggen-SVGs für **alle** Länder vorliegen, die (a) in der
Demo-DB vorkommen und (b) an der WM 2026 teilnehmen — sonst zeigen Match-/
Ranking-Ansichten kaputte Bilder. Welche Länder genau gebraucht werden, ist
**intern zu ermitteln**.

## Scope
- **In scope**:
  - Benötigte Länder ermitteln:
    - Demo-DB: `TEAM`-Map in `frontend/scripts/demo_data.ts`
      (GER, ESP, FRA, ITA, POR, ENG, NED, POL, CRO).
    - WM 2026: Teilnehmerfeld recherchieren/auflisten (TLA/IOC-Codes).
  - Für jeden benötigten Code ein `public/svg/{TLA}.svg` bereitstellen
    (fehlende ergänzen); FIFA→IOC-Sonderfälle in `Flag.tsx` (`TLA_MAP`) prüfen
    und bei Bedarf erweitern.
  - Quelle der SVGs dokumentieren (Lizenz beachten — gemeinfreie/Public-Domain
    Flaggensets wie z. B. die der ISO-3166-Sammlungen).
- **Out of scope (explicit)**: Länder-Namen-Übersetzung (FE-034); Redesign der
  `Flag`-Komponente; Flaggen für Länder, die weder in Demo noch WM 2026 sind.

## References
- `frontend/components/dashboard/Flag.tsx` — `src={/svg/{mapped}.svg}`,
  `TLA_MAP` (DEU→GER, NLD→NED, HRV→CRO, DNK→DEN, PRT→POR, CHE→SUI)
- `frontend/public/svg/` — Ablageort der Flaggen
- `frontend/scripts/demo_data.ts` — Demo-Länder

## Acceptance Criteria
- [ ] Für jedes Demo-DB-Land existiert ein `public/svg/{TLA}.svg` (keine
      kaputten Bilder im Dashboard/Match/Ranking).
- [ ] Für jeden WM-2026-Teilnehmer existiert das passende SVG; nötige
      FIFA→IOC-Mappings in `TLA_MAP` ergänzt.
- [ ] SVG-Quelle + Lizenz im Ticket-Ergebnis dokumentiert.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Dashboard/Match/Ranking mit Demo-Daten → alle Flaggen laden (kein Broken-Image).
2. Stichprobe WM-2026-Teilnehmer → `/svg/{TLA}.svg` vorhanden.
