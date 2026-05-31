# FE-054 Dashboard-Mini-Rangliste: Profilbild wird nicht geladen

## Repo
frontend

## Type
bug

## Risk
low

## Priority
high

> User-reported (2026-05-31) — springt vor die geplanten Tickets.

## Status
todo

## Owner
implementer

## Background
Im Dashboard gibt es eine kleine Ranglisten-Tabelle. Dort wird das
Profilbild (Avatar) der User **nicht geladen/angezeigt** — vermutlich rendert
die kompakte Tabellen-Komponente den Avatar gar nicht, nutzt das falsche Feld,
oder die Avatar-URL/Fallback-Logik greift dort nicht (anders als in der
vollen Rangliste / im Profil, wo der Avatar korrekt erscheint).

## Symptom (bugs only)
Dashboard → kleine Rangliste: statt Profilbild kein Bild (bzw. nur Initialen/
leer), obwohl der User ein Avatar hochgeladen hat und es an anderer Stelle
angezeigt wird.

## Scope
- **In scope**: Avatar in der Dashboard-Mini-Rangliste korrekt laden/anzeigen,
  inkl. Fallback (Initialen/Icon) wie in der großen Rangliste. Konsistent mit
  der bestehenden Avatar-Anzeige-Komponente.
- **Out of scope**: Avatar-Upload/-Verarbeitung; volle Ranglisten-Seite (falls
  dort korrekt); Layout-Redesign der Tabelle.

## References
- Dashboard-Mini-Rangliste: `frontend/components/dashboard/TabBar.tsx` und die
  davon gerenderte Zeilen-/Ranking-Komponente (exakte Komponente beim Start
  lokalisieren)
- Avatar-Anzeige-Muster: bestehende Avatar-Komponente der Profil-/Ranglisten-
  Anzeige (gleiches Feld + Fallback wiederverwenden)

## Acceptance Criteria
- [ ] In der Dashboard-Mini-Rangliste wird das Profilbild geladen/angezeigt.
- [ ] Fallback (Initialen/Icon) greift, wenn kein Avatar vorhanden ist.
- [ ] Konsistent mit der Avatar-Anzeige in der großen Rangliste/Profil.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Dashboard öffnen → Mini-Rangliste zeigt Avatare der gelisteten User.
2. User ohne Avatar → sauberer Fallback (Initialen/Icon), kein kaputtes Bild.
