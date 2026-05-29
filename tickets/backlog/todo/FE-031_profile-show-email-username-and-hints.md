# FE-031 Profil: Email + Username anzeigen, Pick-Deadline-Hinweis

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Das Profil soll den **Username** und die **Email** anzeigen. Die Email ist
PII und wird nur auf dem **eigenen** Profil gezeigt, nicht beim Ansehen
fremder Profile (`/user/{andere-id}`). Außerdem soll ein kurzer Hinweis
erklären, dass Weltmeister-/Secret-Tipp nur bis zum ersten Spiel editierbar
sind (die Edit-Logik existiert bereits aus FE-018).

## Scope
- **In scope**:
  - Profil zeigt Username (bereits) + Email.
  - Email nur sichtbar, wenn `isOwnProfile` (Session-User == Profil-User).
  - Hinweistext an den Winner-Cards: „Editierbar bis zum ersten Spiel"
    (nur sinnvoll im editierbaren/eigenen, ungesperrten Zustand).
- **Out of scope (explicit)**: Winner-Edit-Logik (FE-018, fertig);
  Passwort-Änderung (FE-032); Registrierung/Schema (FE-033).

## References
- `frontend/app/(app)/user/[id]/page.tsx` — `isOwnProfile`, `editable`,
  `localUser`, `locked`
- `frontend/components/profile/ProfileHeader.tsx` — Username-Anzeige
- `frontend/components/profile/WinnerCards.tsx` — Ort für den Hinweis
- `frontend/lib/user.ts` — `getUserById` (liefert `email`)

## Acceptance Criteria
- [ ] Eigenes Profil: Username **und** Email sichtbar.
- [ ] Fremdes Profil: Username sichtbar, Email **nicht**.
- [ ] Hinweis „bis zum ersten Spiel editierbar" erscheint am Winner-Bereich im
      editierbaren Zustand; im gesperrten Zustand nicht (oder als „gesperrt").
- [ ] Tests: wo testbare Logik entsteht (z. B. Email-Sichtbarkeits-Helper),
      Unit-Test ergänzen. Reine RSC-Anzeige ohne testbare Logik ausgenommen.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Eigenes Profil → Email + Username sichtbar, Pick-Hinweis am Winner-Bereich.
2. Fremdes Profil (`/user/<andere-id>`) → keine Email.
