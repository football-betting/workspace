# FE-055 Avatar ändern: auch das Kamera-Icon klickbar machen

## Repo
frontend

## Type
feature

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
Beim Ändern des Profilbilds löst aktuell nur der **Text** (Link/Button) den
Datei-Dialog aus. Das **Kamera-Icon** auf dem Avatar (Overlay) ist nur
dekorativ. Erwartung: Auch ein Klick auf das Kamera-Icon (bzw. auf den Avatar
selbst) soll den Foto-Auswahl-Dialog öffnen — das ist das intuitive Affordance.

## Scope
- **In scope**: Das Kamera-Icon/Avatar-Overlay klickbar machen, sodass es
  denselben Datei-Dialog wie der bestehende Text auslöst. Zugänglichkeit
  beachten (Button-Semantik, `aria-label` via i18n de/en, Tastatur/Focus).
- **Out of scope**: Upload-/Verarbeitungs-Logik (unverändert); Validierung
  (SVG/zu groß) bleibt wie ist; Redesign.

## References
- Avatar-Editor-Komponente in `frontend/components/settings/` (Avatar-Upload/
  -Editor — exakte Komponente beim Start lokalisieren)
- Bestehender Text-Trigger + verstecktes `<input type="file">`

## Acceptance Criteria
- [ ] Klick auf das Kamera-Icon (und/oder den Avatar) öffnet denselben
      Datei-Dialog wie der Text-Trigger.
- [ ] Tastatur-/Screenreader-zugänglich (`aria-label` aus i18n, de/en), Focus-
      sichtbar.
- [ ] Bestehender Text-Trigger + Upload-Flow unverändert funktionsfähig.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Settings/Profil → Klick auf Kamera-Icon → Datei-Dialog öffnet sich.
2. Bild wählen → Upload/Vorschau wie beim Text-Trigger.
3. Tab-Fokus auf das Icon + Enter → Dialog öffnet sich.
