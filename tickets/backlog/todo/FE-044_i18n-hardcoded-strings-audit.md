# FE-044 i18n-Audit: keine hartcodierten user-sichtbaren Strings

## Repo
frontend

## Type
refactor

## Risk
medium

## Priority
high

## Status
todo

## Owner
implementer

## Background
FE-023 hat die **Anzeige**-Strings der Komponenten übersetzt, aber
**Validierungs- und Fehlermeldungen** laufen weiter als hartcodiertes Englisch
— sie tauchen im UI auf (Form-Fehler), umgehen aber die Übersetzung.
Beispiele:
- Zod-Messages in `lib/validation/auth.ts` (`"Only valantic.com email
  addresses are allowed."`, `"Winner and secret winner must differ."`,
  `"username"`, `"Invalid password"`, …) und `lib/validation/winners.ts`.
- API-Fehler-Responses in `app/api/**` (`"This username is already taken."`,
  `"Email or password incorrect."`, `"Too many requests, try again later."`,
  `"Failed to save tip."`, …) — die Clients zeigen `body.error` roh an.

Ziel: **alle** user-sichtbaren Strings kommen aus den Übersetzungs-Katalogen
(de **und** en), auch Fehler-/Validierungstexte.

## Vorgehen
- **Audit**: systematisch nach hartcodierten user-sichtbaren Strings suchen —
  Zod-`message`-Felder, `jsonError(...)`/`{ error: "…" }`-Responses in
  `app/api/**`, sowie evtl. übersehene JSX-Literale (nicht über `t()`).
- **Fix-Pattern** (Implementer wählt sauber):
  - Validierung/API liefern **Übersetzungs-Keys** (statt englischer Klartexte);
    der anzeigende Client/Server übersetzt via next-intl (`useTranslations` /
    serverseitig `getTranslations` mit Request-Locale). Zod-Schemas werden bei
    Modul-Load gebaut → Locale ist per-Request, daher Keys statt fixer Texte.
  - Neue Katalog-Keys in `messages/de.json` **und** `messages/en.json`,
    Key-Parität wahren (Test deckt das ab).

## Scope
- **In scope**: Validierungs-Messages (`lib/validation/**`), API-Fehler-Texte
  (`app/api/**`), übersehene Anzeige-Literale. Beide Locales (de/en).
- **Out of scope (explicit)**: Server-Log-/Konsolen-Texte (nicht user-sichtbar);
  weitere Sprachen; Eigennamen (Standorte, TOURNAMENT_NAME).

## References
- `frontend/lib/validation/auth.ts`, `frontend/lib/validation/winners.ts`
- `frontend/app/api/**` — Fehler-Responses
- `frontend/messages/de.json`, `messages/en.json`
- Anzeige-Stellen: `login-form.tsx`, `signup-form.tsx`, `TipForm.tsx`,
  `WinnerEditForm.tsx` (zeigen `error`/`body.error`)

## Acceptance Criteria
- [ ] Keine hartcodierten user-sichtbaren Strings mehr in `lib/validation/**`
      und in den Fehler-Responses von `app/api/**` (grep-Stichprobe leer).
- [ ] Validierungs-/API-Fehler erscheinen im UI **übersetzt** (de und en).
- [ ] de/en Key-Parität grün; keine leeren Werte.
- [ ] Bestehendes Verhalten (Statuscodes, Flow) unverändert; kein User-
      Enumeration-Leak neu eingeführt.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Sprache DE → Signup mit Nicht-valantic-Email (prod-Sim) / doppeltem
   Username / zu kurzem Passwort → Fehlertexte **deutsch**.
2. Sprache EN → dieselben Fehler **englisch**.
3. Login mit falschem Passwort → übersetzte Meldung.
