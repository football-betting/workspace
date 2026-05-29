# FE-025 Tip: View/Edit-Umschalten nach Abgabe

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
`TipForm` zeigt aktuell immer die Eingabefelder, auch nachdem ein Tipp
abgegeben wurde — nach dem Speichern wird nur ein `saved`-Zustand gesetzt und
die Seite aktualisiert. Gewünscht ist eine kompaktere, klarere Darstellung:
sobald ein Tipp existiert, soll er als Text (das getippte Ergebnis) zusammen
mit einem "Edit"-Button erscheinen, statt der offenen Eingabefelder. Klickt
der Nutzer auf "Edit" oder auf das angezeigte Ergebnis, klappt das
Eingabeformular wieder auf.

## Scope
- **In scope**:
  - `TipForm` um einen View-Modus erweitern: liegt ein Tipp vor (`initialTip`
    bzw. gerade gespeichert), das Ergebnis als Text + "Edit"-Button zeigen
    statt der Eingabefelder.
  - Klick auf "Edit" **oder** auf das angezeigte Ergebnis → Edit-Modus
    (Formular sichtbar, mit den bisherigen Werten vorbefüllt).
  - Nach erfolgreichem Speichern zurück in den View-Modus.
- **Out of scope (explicit)**: Änderungen am Speicher-Endpunkt
  `/api/tip/{matchId}`; Tippen für gesperrte/laufende Spiele (bleibt über
  `disabled` deaktiviert); Profil-Historie (`PredictionHistory`).

## References
- `frontend/components/dashboard/TipForm.tsx` — Client-Komponente, Submit an
  `/api/tip/{matchId}`, hält `tipHome`/`tipAway`/`saved`-State
- `frontend/components/dashboard/MatchRow.tsx` — rendert `TipForm` mit
  `initialTip` und `disabled`

## Acceptance Criteria
- [ ] Spiel mit bereits abgegebenem Tipp → View-Modus: Ergebnis als Text
      (z. B. `2 : 1`) + "Edit"-Button, **keine** offenen Eingabefelder.
- [ ] Klick auf "Edit" → Eingabeformular sichtbar, mit den bisherigen Werten
      vorbefüllt.
- [ ] Klick auf das angezeigte Ergebnis → ebenfalls Edit-Modus.
- [ ] Erfolgreiches Speichern → zurück in den View-Modus mit dem neuen
      Ergebnis.
- [ ] Spiel ohne Tipp → wie bisher Eingabefelder (kein leerer View-Modus).
- [ ] `disabled` (gesperrt/laufend) → kein Edit möglich.
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Dashboard, Spiel ohne Tipp → Eingabefelder, Tipp `2:1` abgeben.
2. Nach Speichern → `2 : 1` als Text + "Edit"-Button.
3. Auf "Edit" klicken → Formular mit `2`/`1` vorbefüllt.
4. Auf das Ergebnis (statt Button) klicken → Formular öffnet ebenfalls.
5. Auf `3:0` ändern, speichern → View-Modus zeigt `3 : 0`.
