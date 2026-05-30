# FE-040 Result — Mobile-Ansicht-Review (390×812, eingeloggt als test.user)

**Erledigt**: 2026-05-31
Methode: Playwright-Screenshots je Seite gegen den laufenden Dev-Server
(`scripts/mobile-audit.mjs`, Viewport 390×844). Kein Code-Change (Audit).

## ⚠️ Vorab gefunden (nicht-Layout, aber kritisch)
Die laufende **Shared-DB hatte keine `avatar`-Spalte** (geseedet nach FE-033,
vor FE-036) → alle User-Queries (Drizzle selektiert `avatar`) errorten →
**Login/App war kaputt**. Nicht-destruktiv gefixt via
`ALTER TABLE user ADD COLUMN avatar text` (keine Daten verloren). **Empfehlung:
`pnpm db:reset`**, um DB vollständig mit dem Schema zu syncen.

## Befunde pro Seite
| Seite | Mobile-Status | Befund |
|---|---|---|
| Login | ✅ gut | sauber; DE/EN-Switcher oben rechts nah am Titel (kosmetisch) |
| Signup | ✅ gut | FE-033/038/039-Hinweise da, keine Name-Felder; einspaltig |
| Dashboard | ✅ gut | Live + Rangliste-zwischen (FE-037) + Upcoming Text-Buttons (FE-027) |
| Ranking | ✅ gut | Stat-Grid je Zeile sauber |
| Profil | ✅ sehr gut | Name ohne Email (FE-031), Initialen-Avatar „TU" (FE-036), farbige Winner-Flaggen |
| Settings | ✅ gut | Mobile-Logout (FE-032), Avatar-Upload (FE-036), Passwort-Form |
| Match-Detail | ⚠️ Problem | **Team-Namen im Header abgeschnitten zu „F…"/„D…"** |

## Konkrete Probleme → Fix-Tickets
1. **Match-Header Team-Namen abgeschnitten** (Match-Detail, mobil unlesbar:
   „F…"/„D…") → **FE-052**.
2. **BottomNav „EINSTELLUNGEN" abgeschnitten** (4. Eintrag, 4 Items + langes
   DE-Label, auf jeder eingeloggten Seite) → **FE-051**.
3. **Ranking-Tabs „MAINZ" am rechten Rand abgeschnitten** („MAIN") → **FE-053**.

## Bekannt / out of scope
- ScoringInfobox zeigt alte Werte (4/2/1/+15/+7) → **XR-003**.
- Alle Anpfiff-Zeiten identisch (15:01) → Seed-Artefakt (FE-024-Umfeld).
- Next.js-Dev-Indicator überlappt Labels → nur Dev, irrelevant für Prod.

## Tooling
`frontend/scripts/mobile-audit.mjs` (Playwright-Screenshots) als wiederverwend-
bares Audit-Skript erstellt (lokal, nicht committet).
