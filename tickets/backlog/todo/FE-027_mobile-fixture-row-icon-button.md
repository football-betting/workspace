# FE-027 Mobile Dashboard: Tipp-Button als Icon am Breakpoint

## Repo
frontend

## Type
bug

## Risk
low

## Priority
medium

## Status
todo

## Background
In der mobilen Ansicht des Dashboards wirken die Upcoming-Fixture-Zeilen
gedrängt: Flagge, Kürzel, Anstoßzeit, zwei Score-Eingaben **und** ein
Text-Button (SAVE/EDIT) konkurrieren um die schmale Breite. Auf kleinen
Viewports soll der Text-Button durch ein kompaktes Icon ersetzt werden, damit
die Zeile sauber passt; auf größeren Viewports bleibt der Text-Button.

## Symptom (bugs only)
1. Dashboard auf schmalem Viewport (Mobile-Breite) öffnen.
2. Upcoming-Fixture-Zeile: der SAVE/EDIT-Text-Button drängt das Layout / wirkt
   zu groß für die verfügbare Breite.

## Scope
- **In scope**:
  - `components/dashboard/TipForm.tsx` (und ggf. `MatchRow.tsx`) — Aktions-
    Button unterhalb eines Breakpoints als Icon-Button (z. B. Speichern-/
    Bearbeiten-Icon) darstellen, ab dem Breakpoint wieder mit Text.
  - Icon-Variante mit zugänglichem `aria-label`.
- **Out of scope (explicit)**: Neugestaltung der gesamten Zeile;
  Funktionsänderung des Speicherns/Tippens; Desktop-Darstellung.

## References
- `frontend/components/dashboard/TipForm.tsx` — enthält den SAVE/EDIT-Button
- `frontend/components/dashboard/MatchRow.tsx` — `flex-col md:flex-row`-Zeile,
  rendert `TipForm`
- `frontend/components/dashboard/UpcomingList.tsx` — Liste der Zeilen

## Notes
Sollte mit FE-025 (Tip View/Edit-Umschalten) abgestimmt werden, da beide den
Button-Bereich von `TipForm` betreffen — Reihenfolge im Backlog beachten.

## Acceptance Criteria
- [ ] Unterhalb des Mobile-Breakpoints: Aktions-Button als Icon (kein
      abgeschnittener/überbreiter Text-Button), Zeile passt ohne Überlauf.
- [ ] Ab dem Breakpoint: Text-Button wie bisher.
- [ ] Icon-Button hat ein `aria-label` (SAVE bzw. EDIT).
- [ ] Funktion (Tipp speichern / bearbeiten) unverändert.
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. DevTools → schmale Viewport-Breite → Fixture-Zeile zeigt Icon-Button, kein
   Überlauf.
2. Breite vergrößern → Text-Button erscheint wieder.
3. Icon-Button antippen → speichert/bearbeitet wie zuvor.
