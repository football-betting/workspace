# FE-023 Zweisprachigkeit Deutsch / Englisch

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Die Oberfläche ist heute einsprachig (gemischt; `<html lang="de">` ist
hartcodiert, UI-Texte teils englisch). Sie soll zweisprachig werden — Deutsch
und Englisch. Standardsprache ist Deutsch; Nutzer können über einen
Umschalter in der UI manuell auf Englisch wechseln, die Wahl wird per Cookie
gemerkt und gilt für künftige Besuche.

## Scope
- **In scope**:
  - i18n-Setup mit `next-intl` (App-Router-Standard) — siehe Context7 für
    aktuelle Setup-/Konfigurationsschritte.
  - Übersetzungs-Kataloge `de` (Default) und `en` für alle nutzersichtbaren
    Texte der bestehenden Seiten und Komponenten.
  - Sprach-Umschalter in der UI (z. B. in `TopAppBar`), Auswahl persistiert
    per Cookie.
  - `<html lang>` folgt der aktiven Sprache statt hartcodiertem `"de"`.
- **Out of scope (explicit)**: Weitere Sprachen; Übersetzung von
  E-Mail-Templates oder serverseitigen Log-/Fehlermeldungen; lokalisierte
  Zahlen-/Datumsformate über das hinaus, was die Seiten schon nutzen.

## References
- `frontend/app/layout.tsx` — hartcodiertes `<html lang="de">`
- `frontend/components/dashboard/TopAppBar.tsx` — Kandidat für den Umschalter
- `frontend/components/**` und `frontend/app/**` — Quelle der UI-Strings
- `next-intl` (Doku via Context7 MCP)

## Acceptance Criteria
- [ ] Erstbesuch ohne Sprach-Cookie → Oberfläche auf Deutsch, `<html lang="de">`.
- [ ] Umschalter auf "EN" → alle sichtbaren Texte der aktuellen Seite englisch,
      `<html lang="en">`.
- [ ] Sprachwahl überlebt Reload und Navigation (Cookie-persistiert).
- [ ] Keine hartcodierten Anzeige-Strings mehr in den im Scope genannten
      Seiten/Komponenten — alle laufen über die Übersetzungs-Kataloge.
- [ ] `de`- und `en`-Katalog haben dieselben Schlüssel (keine fehlenden
      Übersetzungen).
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Inkognito öffnen → UI deutsch.
2. Auf "EN" schalten → Texte englisch, `lang="en"`.
3. Reload + auf andere Seite navigieren → bleibt englisch.
4. Zurück auf "DE" → wieder deutsch, bleibt nach Reload.
