# FE-039 Sprachumschalter auf Login- und Registrierungs-Seite

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
Der Sprachumschalter (DE/EN) sitzt aktuell nur in der `TopAppBar`, also auf
den eingeloggten Seiten. Auf **Login** und **Registrierung** gibt es keine
Möglichkeit, die Sprache zu wechseln. Das soll wie auf den normalen Seiten
funktionieren — Auswahl wird im selben `locale`-Cookie gespeichert (FE-023).

## Scope
- **In scope**:
  - `LocaleSwitcher` (existiert aus FE-023) auf der Login- und der
    Signup-Seite einbinden (gut sichtbar, z. B. oben/Ecke).
  - Persistenz über denselben `locale`-Cookie (kein neuer Mechanismus).
  - Wenn sinnvoll: ein gemeinsames `app/(auth)/layout.tsx`, das den Switcher
    einmal für beide Auth-Seiten rendert (statt Duplizierung).
- **Out of scope (explicit)**: Neues i18n-Setup; weitere Sprachen; Übersetzung
  zusätzlicher Strings über das Vorhandene hinaus.

## References
- `frontend/components/LocaleSwitcher.tsx` — vorhandener Umschalter
- `frontend/app/(auth)/login/page.tsx`, `frontend/app/(auth)/signup/page.tsx`
- `frontend/i18n/` — Request-Config / Cookie (FE-023)

## Acceptance Criteria
- [ ] Login- und Signup-Seite zeigen den Sprachumschalter (DE/EN).
- [ ] Umschalten wechselt die Sprache der Auth-Seite sofort und persistiert
      (gleicher `locale`-Cookie); bleibt nach Reload/Navigation erhalten.
- [ ] Kein doppelter Cookie-/Mechanismus — identisch zu den App-Seiten.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Ausgeloggt `/login` → Umschalter sichtbar; auf EN → Texte englisch, bleibt
   nach Reload.
2. `/signup` analog; nach Login ist die Sprache weiter gesetzt.
