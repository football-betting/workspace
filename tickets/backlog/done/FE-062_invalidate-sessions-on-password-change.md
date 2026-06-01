# FE-062 Sessions bei Passwort-Reset/-Änderung invalidieren

## Repo
frontend

## Type
bug

## Risk
high

## Priority
high

> Security-Audit 2026-06-01 (HIGH). Account-Recovery erfüllt sonst seinen Zweck nicht.

## Status
todo

## Owner
implementer

## Background
Weder der Passwort-**Reset** noch die Passwort-**Änderung** invalidieren
bestehende Sessions. Eine gestohlene/gekaperte Session überlebt damit das
Zurücksetzen des Passworts — der eigentliche Sinn der Wiederherstellung
(Angreifer rauswerfen) wird nicht erreicht.

## Findings (Audit)
- `app/api/auth/reset-password/route.ts:86-89` — nach `updateUserPassword` kein
  `lucia.invalidateUserSessions(userId)` (HIGH).
- `app/api/user/password/route.ts:99-105` — Selbst-Änderung invalidiert andere
  Sessions nicht (MEDIUM).

## Scope
- **In scope**: Nach erfolgreichem Reset **und** Passwort-Änderung
  `lucia.invalidateUserSessions(userId)` aufrufen. Beim Self-Change die aktuelle
  Session frisch neu ausstellen (User bleibt eingeloggt). Beim Reset alle
  Sessions invalidieren (User loggt sich neu ein).
- **Out of scope**: 2FA, Session-Listing-UI.

## Acceptance Criteria
- [ ] Reset: alle Sessions des Users werden invalidiert; alter Cookie ungültig.
- [ ] Change: andere Sessions invalidiert, aktive Session bleibt gültig (neuer Cookie).
- [ ] Bestehender Flow (Login danach) funktioniert.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. In 2 Browsern einloggen → in einem Passwort ändern → der andere ist ausgeloggt.
2. Reset durchführen → alle Sessions ungültig, Login mit neuem PW nötig.
