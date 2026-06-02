# FE-072 Result — Settings-UI: ruhigere Buttons + expliziter Push-Opt-in
**Geschlossen**: 2026-06-02 · **Commit**: `frontend` main `2991a84 (#74)`
- Save-Buttons (Passwort/Reminder) `bg-primary-container` (knallrot) → `bg-primary` (sanft).
- Logout-Sektion + Button neutralisiert (kein error-rot).
- `PushToggle` neu: expliziter Opt-in (Erklärung + Button „Benachrichtigungen aktivieren"),
  Zustände aktiviert/denied/unsupported sauber; statt versteckter Checkbox.
- i18n de/en: pushEnableButton/DisableButton/EnabledStatus. Gate grün.
