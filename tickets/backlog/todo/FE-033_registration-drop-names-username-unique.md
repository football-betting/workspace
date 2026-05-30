# FE-033 Registrierung: Namen raus, Username unique, Email-abgeleiteter Name

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Bei der Registrierung sollen `firstName`/`lastName` entfallen — der Anzeigename
lässt sich aus der Email ableiten. Der `username` ist nicht die Email (Nutzer
haben früher fälschlich ihre Email eingetragen) und soll eindeutig sein. Die
DB ist nicht produktiv und wird gelöscht + neu geseedet — **keine Migration**
nötig, das Drizzle-Schema direkt ändern reicht.

## Abgeleiteter Anzeigename
Aus dem Email-Local-Part (vor `@`), an `.` trennen, jeweils ersten Buchstaben
groß. Beispiel: `rafal.wesolowski@cec.valantic.com` → „Rafal Wesolowski".
Kein Punkt im Local-Part → ein Wort. Reine Funktion → unit-testbar.

## Scope
- **In scope**:
  - `db/schema.ts`: `firstName`/`lastName` aus der `user`-Tabelle entfernen;
    `username` auf `.unique()` setzen. DB neu erzeugen (`pnpm db:reset`), keine
    Migrationsdatei.
  - Registrierung (`app/api/user/route.ts`, `signup-form.tsx`,
    `lib/validation/auth.ts`): firstName/lastName-Felder entfernen; Duplicate-
    Username → Fehler (Unique greift); kleiner Hinweis am Username-Feld
    „Das ist nicht deine Email-Adresse".
  - `lib/auth.ts` (`getUserAttributes`): firstName/lastName entfernen.
  - `scripts/demo_data.ts`: Seed ohne firstName/lastName, Usernames eindeutig,
    **Emails im Format `vorname.nachname@local.dev`** (z. B.
    `rosa.parks@local.dev`), damit `displayNameFromEmail` echte Namen liefert
    (gebraucht von FE-031 und FE-036).
  - Helper `displayNameFromEmail(email)` (s. o.) und überall dort verwenden, wo
    bisher firstName/lastName **angezeigt** wurden (falls vorhanden).
- **Out of scope (explicit)**: Migration (DB wird neu erzeugt); Email- oder
  Username-Änderung nach Registrierung; Profil-Anzeige (FE-031).

## References
- `frontend/db/schema.ts` (Z. 19-29) — `user`-Tabelle
- `frontend/app/api/user/route.ts` — Registrierung
- `frontend/app/(auth)/signup/signup-form.tsx` — Formular
- `frontend/lib/validation/auth.ts` — Zod-Schema
- `frontend/lib/auth.ts` — `getUserAttributes`
- `frontend/scripts/demo_data.ts` — Seed
- Rust `betting-api/src/db/mod.rs` `User`-Struct nutzt firstName/lastName
  **nicht** → keine Rust-Änderung nötig (lockstep-Review bestätigt).

## Acceptance Criteria
- [ ] `user`-Tabelle hat kein `firstName`/`lastName` mehr; `username` ist unique.
- [ ] Signup-Formular ohne Name/Nachname; Hinweis „nicht die Email" am Username.
- [ ] Doppelter Username bei Signup → Fehler, kein Insert.
- [ ] `displayNameFromEmail` liefert „Rafal Wesolowski" für
      `rafal.wesolowski@…`; Unit-Tests decken Punkt/kein-Punkt/Mehrfach-Punkt ab.
- [ ] `pnpm db:reset` läuft sauber durch, Seed ohne Namen.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. `pnpm db:reset` → ok, keine Namensspalten.
2. Signup ohne Name/Nachname, mit Hinweis am Username; doppelter Username → Fehler.
3. Wo ein Anzeigename steht, erscheint der aus der Email abgeleitete Name.
