# FE-094 FAQ page

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
done

## Owner
implementer

## Background
Der Footer verlinkt bisher nur die `/features`-Seite. Nutzer haben keinen
gebündelten Ort, an dem die wichtigsten Fragen zum Tipspiel (Tippen, Wertung,
Boni, Rangliste, Konto/Technik) beantwortet werden. Eine eigene FAQ-Seite senkt
Support-Rückfragen und erklärt das Spielprinzip an einer Stelle — zweisprachig
(Deutsch/Englisch) wie der Rest der App.

## Scope
- **In scope**:
  - Neue Seite `frontend/app/(app)/faq/page.tsx` (Server Component, Muster wie
    `/features`), Inhalte als aufklappbares Accordion (`<details>/<summary>`,
    kein Client-JS).
  - FAQ-Texte in `frontend/messages/de.json` und `frontend/messages/en.json`
    unter neuem Key `FAQ` (identischer Key-Baum).
  - Footer-Link zu `/faq` (`frontend/components/Footer.tsx`) +
    `Footer.faqHeading` in beiden Sprachen.
  - Vitest-Tests: Render-Test + Übersetzungs-Paritäts-Test (de/en).
  - Spec-Sync in `docs/FRONTEND_FUNKTIONS_SPEC.md`: `/faq` in Routen-Tabelle
    aufnehmen; veralteten „Passwort-Reset = Stub"-Hinweis auf „implementiert"
    korrigieren (Reset existiert: `app/(auth)/forgot-password`,
    `reset-password`, zugehörige API-Routen).
- **Out of scope (explicit)**:
  - Kein Eintrag in TopAppBar/BottomNav (nur Footer).
  - Keine Suche/Filterung der FAQ.
  - Keine Änderung an Spiellogik oder Punkteberechnung.

## References
- `docs/specs/2026-06-09-faq-page-design.md` (Design + FAQ-Inhalte)
- `frontend/app/(app)/features/page.tsx` (Seiten-Muster)
- `frontend/components/Footer.tsx`
- `frontend/messages/de.json`, `frontend/messages/en.json`
- `betting-api/src/service/mod.rs` (`WINNER_BONUS=12`, `SECRET_WINNER_BONUS=6` — Quelle der Bonus-Werte)
- `docs/FRONTEND_FUNKTIONS_SPEC.md` (§3 Routen, §6 Passwort-Reset)

## Acceptance Criteria
- [ ] `GET /faq` rendert die Seite mit Titel und 3 Themenblöcken
      (Tippen & Regeln, Rangliste & Abteilungen, Konto & Technik).
- [ ] Alle 14 Fragen werden als `<details>`-Accordion gerendert
      (Anzahl `<details>` == Anzahl Fragen).
- [ ] In der K.-o.-Phase wird klargestellt, dass nur die reguläre Spielzeit
      (90 Min.) zählt — keine Verlängerung/Elfmeterschießen.
- [ ] Erinnerungs-Antwort macht klar, dass ein Kanal (Push und/oder E-Mail)
      in den Einstellungen aktiviert werden muss.
- [ ] Punktangaben stimmen mit dem Backend überein: 5/3/2/0, Sieger-Bonus +12,
      Secret-Winner-Bonus +6.
- [ ] Footer zeigt zusätzlich zum Features-Link einen `/faq`-Link,
      übersetzt in DE und EN.
- [ ] `FAQ`-Key-Baum ist in `de.json` und `en.json` strukturgleich
      (Paritäts-Test grün, keine leeren Strings).
- [ ] `docs/FRONTEND_FUNKTIONS_SPEC.md`: `/faq` in §3 gelistet, Passwort-Reset
      nicht mehr als Stub beschrieben.
- [ ] Quality Gate `frontend`:
      `pnpm exec prettier --check` betroffene Dateien,
      `pnpm exec tsc --noEmit && pnpm exec vitest run` grün.

## Verification (manual)
1. `/faq` im eingeloggten Zustand öffnen → Seite mit 3 Blöcken sichtbar.
2. Eine Frage anklappen → Antwort erscheint, andere bleiben zu.
3. Sprache auf Englisch umschalten → Fragen/Antworten auf Englisch.
4. Footer → „FAQ"-Link führt nach `/faq`.
