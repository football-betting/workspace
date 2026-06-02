# FE-065 Avatar-Upload: Fehlermeldungen übersetzen

## Repo
frontend
## Type
bug
## Risk
low
## Priority
medium
> Projekt-Scan 2026-06-02 (Medium). FE-044-Lücke.

## Status
todo
## Owner
implementer

## Background
`components/settings/AvatarUpload.tsx:79` zeigt bei Fehler `body.error` roh an —
das ist seit FE-044 ein i18n-**Key** (`imageTooLarge`, `unsupportedImageType`,
`invalidImage`, `failedToSaveAvatar`), der dem User wörtlich angezeigt wird statt
übersetzt. Alle anderen Settings-Formulare übersetzen (`useTranslations("Errors")`
mit `.has`-Fallback) — diese Komponente nicht.

## Scope
- `AvatarUpload.tsx`: `useTranslations("Errors")` ergänzen, den zurückgegebenen
  Key über den Katalog übersetzen (Muster wie `PushToggle`/`ReminderSettings`),
  Fallback auf eine generische Meldung bei unbekanntem Key.

## Acceptance Criteria
- [ ] Upload-Fehler (zu groß, falscher Typ, ungültig) erscheinen **übersetzt** (de/en).
- [ ] Unbekannter Key → generischer Fallback, nie der rohe Key.
- [ ] Quality Gate: `bash scripts/check.sh`.
