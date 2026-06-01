# FE-056 Klickbare Elemente: cursor-pointer (Tailwind v4)

## Repo
frontend

## Type
bug

## Risk
low

## Priority
high

> User-reported (2026-06-01) — springt vor FE-050.

## Status
todo

## Owner
implementer

## Background
Tailwind CSS v4 hat den Default-Cursor für `<button>` von `pointer` auf
`default` geändert. Dadurch zeigen Buttons (und andere interaktive Elemente,
die keine echten Links sind) **keinen** `cursor: pointer` mehr — sie fühlen sich
„tot" an. Gewünscht: alles Klickbare hat wieder `cursor: pointer`.

## Symptom (bugs only)
Über Buttons (Tippen, Filter-Kacheln, Tabs, „Foto ändern", Pagination,
Sprachumschalter, …) ist der Mauszeiger der Standard-Pfeil statt der Hand.

## Scope
- **In scope**: Globaler Base-Layer-Fix in `app/globals.css` (offizielles
  Tailwind-v4-Rezept): `button:not(:disabled)`, `[role="button"]:not(:disabled)`
  und weitere interaktive Elemente (`select`, `label[for]`, `summary`) bekommen
  `cursor: pointer`. Disabled-Buttons bleiben ohne Pointer.
- **Out of scope**: Einzelne `cursor-pointer`-Utilities pro Komponente; Redesign;
  `<a>`/Links (haben bereits Pointer).

## References
- `frontend/app/globals.css`
- Tailwind v4 Upgrade-Guide (Cursor-Default-Änderung für Buttons)

## Acceptance Criteria
- [ ] Buttons/`role="button"`/`select`/`label[for]`/`summary` zeigen
      `cursor: pointer` (außer disabled).
- [ ] Disabled-Buttons zeigen **keinen** Pointer.
- [ ] Eine zentrale Regel (kein Streuen von `cursor-pointer` über alle Komponenten).
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Über diverse Buttons hovern (Dashboard/Profil/Settings) → Hand-Cursor.
2. Disabled-Button (z. B. Pager am Rand) → kein Pointer.
