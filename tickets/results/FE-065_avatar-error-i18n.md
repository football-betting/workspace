# FE-065 Result — Avatar-Upload-Fehler übersetzt

**Geschlossen**: 2026-06-02
**Commit**: `frontend` (main) `cb8e093 (#68)`

## Was wurde gemacht
`AvatarUpload` übersetzt Fehler jetzt via `useTranslations("Errors")` +
`extractErrorKey` mit `.has`-Fallback (Muster wie ReminderSettings/PushToggle) —
statt den rohen Key (`imageTooLarge` etc.) anzuzeigen.

## Geänderte Dateien
- `frontend/components/settings/AvatarUpload.tsx`

## Quality-Gate
- `bash scripts/check.sh` → grün.
