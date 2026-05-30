# FE-034 Länder-Namen und Datum lokalisieren

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

## Owner
implementer

## Background
FE-023 hat die statischen UI-Strings übersetzt, aber zwei dynamische Inhalte
bleiben einsprachig:
1. **Länder-/Team-Namen** — in der Live-Ansicht und im Match-Header wird der
   volle Name angezeigt (in den Daten als englischer Name gespeichert, z. B.
   „Germany"). Der soll lokalisiert werden (DE/EN). Der ISO-/TLA-Code (GER,
   ESP, …) darf unverändert bleiben.
2. **Datum/Uhrzeit** — `lib/format.ts` formatiert mit fest verdrahtetem
   `"de-DE"`, daher erscheinen Wochentage/Monate (z. B. „Samstag") auch im
   EN-Modus deutsch. Das Datumsformat soll der aktiven Sprache folgen.

## Scope
- **In scope**:
  - Länder-Namen über die aktive Sprache auflösen: Mapping TLA → lokalisierter
    Name (z. B. `Countries.GER` = „Deutschland"/„Germany"). Überall verwenden,
    wo der **volle** Name angezeigt wird (LiveBlock, MatchHeader,
    PredictionHistory). TLA/ISO-Code bleibt.
  - `lib/format.ts` (`formatDate`, `extractTime`) auf die aktive Locale
    umstellen — bevorzugt über next-intl (`useFormatter`/`getFormatter`) statt
    hartem `"de-DE"`.
  - Kataloge `de.json`/`en.json` um die Länder + ggf. Format-Hilfen erweitern,
    Key-Parität wahren (bestehender Test deckt das ab).
- **Out of scope (explicit)**: Flag-Icons (FE-035); neue Sprachen; Übersetzung
  von Eigennamen, die keine Länder sind.

## References
- `frontend/scripts/demo_data.ts` — `TEAM`-Map (GER/ESP/FRA/ITA/POR/ENG/NED/
  POL/CRO; volle Namen) als Grundbestand
- `frontend/components/dashboard/LiveBlock.tsx`,
  `frontend/components/match/MatchHeader.tsx` — zeigen volle Namen
- `frontend/lib/format.ts` — hartes `"de-DE"`
- `frontend/messages/de.json`, `messages/en.json`

## Acceptance Criteria
- [ ] Im EN-Modus erscheinen volle Länder-Namen englisch, im DE-Modus deutsch;
      TLA/ISO-Code bleibt unverändert.
- [ ] Datum/Uhrzeit folgen der aktiven Sprache (Wochentag/Monat lokalisiert);
      kein hartes `"de-DE"` mehr.
- [ ] Alle Länder der Demo-DB sind in beiden Katalogen abgedeckt.
- [ ] de/en Key-Parität bleibt grün.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. DE → „Deutschland", Datum „Samstag, 30. Mai 2026".
2. EN → „Germany", Datum „Saturday, May 30, 2026".
3. TLA-Codes in Tabellen unverändert.
