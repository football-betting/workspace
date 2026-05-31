# FE-046 Auto-Refresh bei Live-Spielen

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
`macht-api` aktualisiert die Spielstände **jede Minute** in der DB; `betting-api`
liest sie. Solange ein Spiel **live** ist, ändern sich Score und (dadurch)
Ranglisten-Punkte laufend. Der Nutzer soll **nicht selbst refreshen** müssen —
die Ansicht soll sich **automatisch** aktualisieren, im Browser **und** in der
PWA, auch wenn die App auf dem Handy wieder in den Vordergrund geholt wird.
**Nur während Live-Spielen** (kein Live-Spiel → kein Polling, schont
Ressourcen/Akku).

## Mechanismus: Polling statt WebSocket/SSE
**Bewusst Polling**, kein WebSocket/SSE. Grund: Die Quelldaten ändern sich nur
**einmal pro Minute** (macht-api-Cron) → sub-minütliches Push bringt keinen
Mehrwert. Es gibt keinen WS/SSE-Server; die Rust-APIs sind REST und pushen
nicht. `router.refresh()` (~60 s) liefert genauso aktuelle Daten, ist simpel,
robust und PWA-tauglich. WS/SSE wäre unverhältnismäßige Infra ohne Nutzen.

## Scope
- **In scope**:
  - Client-Komponente `LiveRefresher`, die die Server-Daten per
    `router.refresh()` (re-rendert RSC → frische `getLiveMatches` +
    Rating/Punkte) neu holt, Intervall ~**60 s** (passend zum Minuten-Update).
  - **Polling-Aktivierung** (Server liefert Live-Status **und** den nächsten
    Anpfiff-Zeitpunkt):
    - Mindestens ein Spiel **live** (`IN_PLAY`/`PAUSED`) → alle ~60 s pollen.
    - Sonst, wenn ein **Anpfiff in der Zukunft** liegt → einen Timer auf
      `kickoff − jetzt` setzen, der das Polling **zum Anpfiff automatisch
      startet** (deckt: Tab/App um 15:55 offen, Spiel startet 16:00 → ohne
      manuelles Neuladen aktualisiert es sich ab 16:00).
    - Kein Live- und kein anstehendes Spiel → **kein** Polling.
    - Sobald kein Spiel mehr live ist → Polling **stoppt**.
  - **Wieder-Öffnen/Fokus**: bei `visibilitychange`→sichtbar und `focus` einmal
    refreshen und Live/Anpfiff neu bewerten (deckt: App um 16:05 wieder
    aufmachen → sofort aktuell).
  - Auf Dashboard (`/`) und Match-Detail (`/match/[id]`) einsetzen.
- **Out of scope (explicit)**: WebSockets/Server-Sent-Events (s. o.);
  Push-Notifications; Dauer-Polling bei nicht-live/nicht-anstehenden Spielen;
  Änderung der API/Cron.

## Wechselwirkung mit FE-045 (PWA)
Der Auto-Refresh muss **frische** Daten bekommen — passt zu FE-045
(Navigationen/Daten network-first, keine personalisierten Antworten gecacht).
Der SW darf die RSC-/Daten-Requests des Refreshs **nicht** aus dem Cache
bedienen.

## References
- `frontend/components/dashboard/LiveBlock.tsx` — Live-Anzeige
- `frontend/lib/match.ts` — `getLiveMatches` (Status `IN_PLAY`/`PAUSED`)
- `frontend/app/(app)/page.tsx`, `frontend/app/(app)/match/[id]/page.tsx`
- `next/navigation` `useRouter().refresh()`

## Acceptance Criteria
- [ ] Bei mindestens einem Live-Spiel aktualisiert sich Dashboard/Match-Detail
      **automatisch** (~60 s) — Score und Ranglisten-Punkte ohne manuellen Reload.
- [ ] Kein Live- **und** kein anstehendes Spiel → **kein** Polling.
- [ ] **Kickoff-Übergang**: Tab um 15:55 offen, Spiel startet 16:00 → ab ~16:00
      aktualisiert es sich **ohne** manuelles Neuladen (Timer auf den Anpfiff).
- [ ] App wieder in den Vordergrund/Fokus → sofort refreshed + Live/Anpfiff neu
      bewertet (Szenario: um 16:05 wieder geöffnet → aktuell).
- [ ] Funktioniert im Browser und in der installierten PWA.
- [ ] Kein Memory-Leak (Interval/Listener werden sauber aufgeräumt).
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Demo mit Live-Spiel → Dashboard offen lassen → nach ~1 min aktualisiert sich
   Score/Punkte ohne Zutun.
2. Kein Live-Spiel → kein wiederholtes Neuladen (Network-Tab ruhig).
3. Tab/App in Hintergrund, dann zurück → bei Live sofort frisch.
