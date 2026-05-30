# FE-031 Result — Profil „My Stats": Username + Name aus Email, Winner-Flagge

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `e0860fb FE-031: profile shows username + email-derived name (no email), winner flags always coloured, pick-deadline hint (#37)` (squash-merge von PR #37)

## Was wurde gemacht

- Profil (`/user/[id]`) zeigt **Username** + den aus der Email **abgeleiteten
  Anzeigenamen** (`displayNameFromEmail`, FE-033) — **keine** Email (PII).
  `ProfileHeader` um `displayName`-Prop erweitert.
- `WinnerCards`: `grayscale group-hover:grayscale-0 …` an der `Flag` entfernt →
  Flaggen **immer farbig**, kein Hover-Effekt.
- Pick-Deadline-Hinweis (`Profile.pickDeadlineHint`, de/en) an den
  Winner-Karten, nur im editierbaren Zustand (FE-018-Lock).

## Geänderte Dateien (frontend)
- `app/(app)/user/[id]/page.tsx`, `components/profile/ProfileHeader.tsx`,
  `components/profile/WinnerCards.tsx`, `messages/de.json`, `messages/en.json`

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **91/91**; `--build` → ok.

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** (keine Email gerendert, Flag-Fix korrekt, Hint
editable-only, i18n-Parität, kein `any`).

## Notiz / Scope-Slip
`public/icon/icon.png` war im Index vorgestaged und ist durch ein
`git commit` ohne Pathspec versehentlich in diesem PR mitgelandet. Die Datei
ist korrekt und wird ohnehin gebraucht (gehört zu **FE-043**); FE-043 muss sie
nun nicht mehr neu hinzufügen, nur Größen/Manifest erzeugen. Lehre: immer
`git commit -- <pfade>` mit explizitem Pathspec.
