# FE-034 Result — Länder-Namen + Datum lokalisieren

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `a1ff033 FE-034: localize country names (Countries catalog + fallback) and date/time (locale-aware) (#42)` (squash-merge von PR #42)

## Was wurde gemacht

- **Länder-Namen**: `Countries`-Namespace in `de.json`/`en.json` für die 9
  Demo-TLAs (GER…CRO). Helper `lib/country.ts`
  `resolveCountryName(tla, fallback, t)` = `t.has(tla) ? t(tla) : fallback`
  (unbekannte TLA → gespeicherter Name, kein Throw). Eingesetzt wo der **volle**
  Name steht (LiveBlock, MatchHeader); TLA/ISO-Codes in Tabellen/Badges bleiben.
- **Datum/Zeit**: `lib/format.ts` `formatDate`/`extractTime` nehmen jetzt einen
  `locale`-Param (kein hartes `"de-DE"`); Call-Sites übergeben `useLocale()`.
  DE → „Samstag, 31. Mai 2026", EN → „Saturday, May 31, 2026".

## Geänderte Dateien (frontend)
- `lib/format.ts`, `lib/country.ts` (neu), `components/dashboard/LiveBlock.tsx`,
  `components/dashboard/MatchRow.tsx`, `components/dashboard/UpcomingList.tsx`,
  `components/match/MatchHeader.tsx`, `components/profile/PredictionHistory.tsx`,
  `messages/de.json`, `messages/en.json`, `tests/unit/format.test.ts`,
  `tests/unit/country.test.ts` (neu)

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **108/108**; `--build` → ok.

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** — Fallback sicher, alle Datums-Call-Sites
aktualisiert, Parität grün, kein `any`, keine Verhaltensänderung.

## Folge (non-blocking)
`ProfileHeader` nutzt noch `points.toLocaleString("de-DE")` (Zahlen-Gruppierung,
nicht Datum/Land) → eigenes Mini-Ticket **FE-047**.
