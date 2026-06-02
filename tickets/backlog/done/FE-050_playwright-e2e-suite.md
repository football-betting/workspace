# FE-050 Playwright-E2E-Test-Suite (positiv + negativ)

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
todo

## Owner
tester

## Background
Es gibt nur vereinzelte E2E-Specs (`tests/e2e/`). Gewünscht ist eine breitere
Playwright-Abdeckung der App — **positive** Flows (Happy Path) **und negative**
Fälle (Fehler, Validierung, Auth-Grenzen), mit verschiedenen Szenarien.

## Scope
- **In scope** (Playwright, gegen einen geseedeten Test-Stand):
  - **Auth**: Login Erfolg (Demo-User/`test1234`), Login falsch (gleiche
    generische Meldung), ausgeloggt → geschützte Seite → Redirect `/login`,
    Logout (inkl. Mobile-Pfad), „Remember me".
  - **Signup**: Erfolg; negativ: Passwörter ungleich, zu kurz, doppelter
    Username (409), `username == Email`-Hinweis, (prod-Sim) Nicht-valantic-Email
    abgelehnt.
  - **Tippen**: Tipp abgeben → View-Modus mit Text; Edit → Formular; gesperrtes/
    laufendes Spiel nicht tippbar; ungültige Eingaben.
  - **Passwort ändern** (`/settings`): Erfolg; falsches aktuelles PW; zu kurz;
    Re-Login mit neuem PW.
  - **Avatar-Upload**: gültiges Bild ok; negativ: SVG/zu groß/kein Bild
    abgelehnt; Fallback Initialen/Icon.
  - **i18n**: DE/EN-Umschalten persistiert; Auth-Seiten-Switcher.
  - **Profil/Ranking**: Anzeige, eigenes vs fremdes Profil (keine Email fremd),
    Winner-Edit-Sperre.
  - **Mobile-Viewport-Smoke** je Hauptseite (kein horizontales Scrollen,
    Kern-Elemente sichtbar).
- **Out of scope**: Unit-Tests (vitest, vorhanden); externe Mail/SMTP (FE-041);
  Last-/Performance-Tests.

## Hinweise
- Test-Setup: deterministischer Seed in einer **Test-DB** (nicht die Shared-DB),
  ggf. `pnpm db:seed:test`. Rate-Limit in Tests via `DISABLE_RATE_LIMIT` (FE-020).
- Playwright-Config hat `webServer`/`baseURL`; `reuseExistingServer` lokal.
- Negative Tests sind so wichtig wie positive.

## Acceptance Criteria
- [ ] Spec-Dateien je Bereich (auth, signup, tip, settings/password, avatar,
      i18n, profile/ranking, mobile-smoke) mit positiven **und** negativen Fällen.
- [ ] `pnpm exec playwright test` läuft grün gegen den geseedeten Test-Stand.
- [ ] Keine Abhängigkeit von der produktiven/Shared-DB.
- [ ] In `scripts/check.sh` optional ein E2E-Modus dokumentiert (separat von
      tsc/vitest).

## Verification (manual)
1. `pnpm exec playwright test` → grün.
2. Stichprobe: ein negativer Fall schlägt ohne den Fix fehl (sinnvoll, nicht
   trivial-grün).
