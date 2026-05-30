# FE-031 Profil als „My Stats": Username + Name aus Email, Winner-Flagge fix

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
Das Profil (`/user/{id}`) soll sich an `design/profile.html` orientieren („My
Stats"): oben **Username** und der aus der Email **abgeleitete Name**
(Vor-/Nachname) — **keine** Email-Adresse (die ist PII und steht nur auf der
Settings-Seite, FE-032). Zusätzlich sind die Flaggen in den Winner-/
Secret-Winner-Karten aktuell standardmäßig entsättigt und werden nur beim
Hover farbig (`grayscale group-hover:grayscale-0`) — das soll weg: **immer
richtige Farben, kein Hover-Effekt**.

## Scope
- **In scope**:
  - Profil zeigt **Username** + **abgeleiteten Anzeigenamen** aus der Email
    (`displayNameFromEmail`, kommt aus FE-033). **Keine** Email auf dem Profil.
  - Layout/Anmutung an `design/profile.html` anlehnen (Stats, Winner-Karten,
    Prediction History bleiben).
  - `WinnerCards`: `grayscale group-hover:grayscale-0 transition-all
    duration-500` an der `Flag` entfernen → Flagge immer farbig, kein Hover.
  - Pick-Deadline-Hinweis an den Winner-Karten („editierbar bis zum ersten
    Spiel") beibehalten/ergänzen (klein, sekundär).
- **Out of scope (explicit)**: Settings/Avatar/Passwort (FE-032, FE-036);
  Schema/Registrierung (FE-033); Winner-Edit-Logik (FE-018, fertig).

## Dependencies
- **FE-033** liefert `displayNameFromEmail` und die Demo-Emails
  (`vorname.nachname@local.dev`) — ohne die ist der abgeleitete Name leer.

## References
- `frontend/design/profile.html` — Design-Vorlage
- `frontend/app/(app)/user/[id]/page.tsx` — Profil-Seite, `localUser`
- `frontend/components/profile/ProfileHeader.tsx` — Name/Username-Anzeige
- `frontend/components/profile/WinnerCards.tsx` — `Flag`-`grayscale`-Hover (Z. ~38)
- `frontend/lib/...` — `displayNameFromEmail` (FE-033)

## Acceptance Criteria
- [ ] Profil zeigt Username + abgeleiteten Namen (Vor-/Nachname); **keine** Email.
- [ ] Winner- und Secret-Winner-Flagge sind immer farbig (kein `grayscale`,
      kein Hover-Wechsel).
- [ ] Pick-Deadline-Hinweis am Winner-Bereich im editierbaren Zustand sichtbar.
- [ ] Tests: wo testbare Logik entsteht. Reine RSC-Anzeige ausgenommen.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Profil öffnen → Username + Name (aus Email) sichtbar, keine Email.
2. Winner-/Secret-Flaggen sofort farbig, kein dunkler/Hover-Effekt.
