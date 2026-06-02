# FE-072 Settings-UI: rote Buttons entschärfen + klarer Push-Opt-in

## Repo
frontend
## Type
feature
## Risk
low
## Priority
medium
> User (2026-06-02): Settings-Buttons zu rot (stört); Notification soll erst klar fragen
> ob erlauben. Freie Bewertung was besser ist.

## Status
todo
## Owner
implementer

## Background
- Die Settings-Save-Buttons (Passwort, Reminder) nutzen `bg-primary-container`
  (`#ff5545`, knalliges Rot) und die Logout-Sektion ist error-rot → die Seite
  wirkt zu rot.
- Push-Benachrichtigungen sind als **Checkbox** umgesetzt, die beim Umschalten
  sofort den Browser-Permission-Prompt auslöst. Besser: erst **klar fragen/
  erklären** und per expliziten Button aktivieren; Permission-Zustände
  (granted/denied/default) sauber anzeigen.

## Scope
- **In scope**:
  - Settings-Save-Buttons (`PasswordChangeForm`, `ReminderSettings`) auf eine
    **ruhigere** Optik (tonal/weniger gesättigtes Rot) umstellen — weiterhin klar
    als Primär-Aktion erkennbar. Logout-Sektion entschärfen (neutraler Container,
    Logout bleibt erkennbar).
  - `PushToggle` als **expliziten Opt-in** gestalten: kurze Erklärung + Button
    „Benachrichtigungen aktivieren" (statt verstecktem Checkbox-Auto-Trigger),
    der den Permission-Flow startet. Zustände: aktiviert (mit Deaktivieren),
    `denied` → Hinweis „im Browser erlauben", nicht unterstützt. i18n de/en.
- **Out of scope**: Theme-Farben global ändern; Login/Signup-Buttons.

## Acceptance Criteria
- [ ] Settings wirkt nicht mehr „zu rot"; Save-Buttons ruhiger, aber klar.
- [ ] Push: erst expliziter Aktivieren-Schritt mit Erklärung, dann Permission;
      `denied`/unsupported sauber kommuniziert. Aktivieren/Deaktivieren funktioniert.
- [ ] i18n de/en Parität; keine `any`.
- [ ] Quality Gate: `bash scripts/check.sh`.
