# FE-049 Profil-Tipp-Historie: Sortieren, Filtern, Paginieren

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
Auf dem Profil (`/user/{id}`) sieht man alle getippten Spiele eines Nutzers
(`PredictionHistory`). Bei vielen Spielen wird das unübersichtlich/zu lang.
Gewünscht: **Sortierung**, **Paginierung** und **Filter** über die Stat-
Kacheln.

## Scope
- **In scope**:
  - **Sortierung** (klickbar): nach **Punkten** und nach **Datum**. Klick
    wechselt Richtung (asc/desc). **Default: Datum absteigend** (neueste Spiele
    oben).
  - **Paginierung**: Server liefert **alle** Tipps; die **Anzeige** wird
    client-seitig paginiert — bei **> 30** Einträgen Seiten/Blättern (nicht
    alle gleichzeitig rendern).
  - **Filter über Stat-Kacheln**: Klick auf eine Kachel in `StatTiles`
    (Exakt / Tordifferenz / Sieger / [Bonus]) filtert die Historie auf genau
    diese Trefferart (Kategorie aus dem per-Spiel-`score` ableiten). Erneuter
    Klick/„Alle" hebt den Filter auf. Aktiver Filter sichtbar markiert.
  - Sort/Filter/Pagination interagieren sauber (Filter zuerst, dann Sortierung,
    dann Seitenaufteilung).
- **Out of scope (explicit)**: Server-seitige Sortierung/Paginierung; Dashboard-
  Upcoming (FE-048); Änderung der Scoring-Werte (XR-003).

## References
- `frontend/components/profile/PredictionHistory.tsx` — Tabelle/Liste
- `frontend/components/profile/StatTiles.tsx` — Kacheln (Exakt/Diff/Wins/Bonus)
- `frontend/app/(app)/user/[id]/page.tsx` — liefert `tips`, `ratingLoad`
- Scoring-Kategorie pro Tipp aus `score` (vgl. `lib/score.ts`/Rating)

## Acceptance Criteria
- [ ] Default: Historie nach Datum **absteigend** (neuestes oben).
- [ ] Klick auf „Punkte"/„Datum" sortiert; erneuter Klick dreht die Richtung.
- [ ] > 30 Einträge → Paginierung; es werden nie alle gleichzeitig gerendert.
- [ ] Klick auf eine Stat-Kachel filtert die Historie auf diese Trefferart;
      Filter aufhebbar; aktiver Filter markiert.
- [ ] Filter + Sortierung + Paginierung greifen korrekt ineinander.
- [ ] Tests: reine Sort-/Filter-/Kategorie-Logik (Unit), wo testbar.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Profil mit vielen Tipps → neueste oben; „Punkte" klicken → nach Punkten;
   nochmal → Richtung dreht.
2. > 30 → Blättern funktioniert.
3. Kachel „Exakt" klicken → nur exakte Treffer; aufheben → wieder alle.
