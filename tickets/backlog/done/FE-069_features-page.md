# FE-069 „Funktionen"-Seite + Footer verlinkt dorthin

## Repo
frontend
## Type
feature
## Risk
low
## Priority
medium
> User (2026-06-02): aus der Footer-Feature-Liste eine eigene Seite mit Beschreibung machen + verlinken.

## Status
todo
## Owner
implementer

## Background
Der Footer (FE-058) listet die Funktionen inline. Gewünscht: eine **eigene
Seite**, die beschreibt, was die App kann (developer-/nutzer-sichtbar), und der
Footer **verlinkt** dorthin statt der Inline-Liste.

## Scope
- **In scope**:
  - Neue Seite `app/(app)/features/page.tsx` (`/features`) mit lokalisierten
    Beschreibungen der Funktionen (Live-Scoring, Tippen & Wertung 5/3/2,
    Ranglisten, PWA/Offline, DE/EN, Passwort-Reset, Avatare, Tipp-Reminder
    Email/Push). Konsistentes Layout (TopAppBar/BottomNav, Footer via Layout).
  - `Footer.tsx`: Inline-Feature-Liste durch einen **Link** „Funktionen" → `/features`
    ersetzen (kurzer Tagline ok). i18n de/en.
- **Out of scope**: Marketing-Design; öffentliche (ausgeloggte) Variante.

## Acceptance Criteria
- [ ] `/features` zeigt die Funktionen mit kurzer Beschreibung, lokalisiert.
- [ ] Footer verlinkt auf `/features` (keine lange Inline-Liste mehr).
- [ ] i18n de/en Parität.
- [ ] Quality Gate: `bash scripts/check.sh --build`.
