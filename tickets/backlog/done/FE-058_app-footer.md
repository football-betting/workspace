# FE-058 App-Footer mit Feature-Übersicht

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

> User-reported (2026-06-01) — Footer aus `design/match_detail.html` integrieren.

## Status
done

## Owner
implementer

## Background
Der Footer war als Mockup designt (`design/match_detail.html`), aber nicht in
der App. Legal-/Support-Links (Privacy/ToS/Support/Changelog) passen nicht zu
einer internen Office-App. Stattdessen — vom User gewählt — eine **Feature-/
Funktionsübersicht** (developer-sichtbar: was kann die App).

## Scope (umgesetzt)
- Gemeinsame, lokalisierte `Footer`-Komponente (Server-Component) im
  `(app)`-Layout → erscheint auf allen eingeloggten Seiten.
- Links: © + App-Name (`Nav.title`) + Version (aus `package.json`).
- Mitte: „Funktionen"-Liste (Live-Scoring, Tippen & Wertung 5/3/2, Ranglisten,
  PWA/Offline, DE/EN, Passwort-Reset, Avatare).
- Rechts: GitHub-Link. Mobile-Spacing gegen die fixe BottomNav.

## Geänderte/neue Dateien
- `frontend/components/Footer.tsx` (neu)
- `frontend/app/(app)/layout.tsx` — Footer eingehängt
- `frontend/messages/de.json`, `messages/en.json` — `Footer`-Namespace

## Quality-Gate
- `bash scripts/check.sh --build` → grün (tsc + vitest inkl. i18n-Parität + Full-Build).
