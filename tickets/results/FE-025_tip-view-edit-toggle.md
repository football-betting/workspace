# FE-025 Result — Tip View/Edit-Toggle

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `f085114 FE-025/FE-027/FE-037: tip view-edit flow, responsive actions, dashboard layout & focus polish (#34)` (squash-merge von PR #34)

## Was wurde gemacht

`TipForm` zeigt einen abgegebenen Tipp als **Text** `H : A` (auf Input-Höhe);
Klick auf den Text oder die Edit-Affordance öffnet das Eingabe-Formular,
nach erfolgreichem Speichern zurück zur Text-Ansicht. Spiele ohne Tipp zeigen
wie bisher die Eingabefelder; gesperrte/laufende Spiele sind nicht editierbar.

Politur (live mit dem Owner abgestimmt):
- Aktive Edit-Zeile bekommt eine **primary-Border**, die **persistent** bleibt
  (via `data-editing` + CSS `:has()`, nicht fokus-abhängig) bis zum Speichern.
- Beim Edit-Klick wird das erste Input **auto-fokussiert**.
- Number-Input-Spinner ausgeblendet; **keine** native Weiß-Outline; Hover/Fokus
  in primary.
- Tastatur: nur **ein** Tab-Stopp pro Modus (Score-Text nicht fokussierbar).

## Geänderte Dateien (alle in `frontend/`)
- `components/dashboard/TipForm.tsx` — View/Edit-Toggle, Auto-Focus, Input-/
  Button-Politur
- `components/dashboard/MatchRow.tsx` — aktive Zeile (`has-[[data-editing]]`)
- `lib/tip-view.ts` (neu) — client-sichere Helfer (`initialTipEditing`,
  `formatTipScore`)
- `messages/de.json`, `messages/en.json` — `TipForm.editTip`
- `tests/unit/tip-view-mode.test.ts` (neu)

## Quality-Gate
- `pnpm exec tsc --noEmit` → 0; `pnpm exec vitest run` → grün (inkl. neuer Tests);
  `pnpm build` → ok.

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** auf den Kern (View/Edit-Logik, client-safe,
i18n-Parität). Die nachgelagerte UI-Politur wurde live mit dem Owner
abgestimmt/visuell abgenommen.
