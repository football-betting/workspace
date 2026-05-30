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

## Scope
- **In scope**:
  - Client-Komponente `LiveRefresher`, die — **nur wenn mindestens ein Spiel
    Live-Status hat** (`IN_PLAY`/`PAUSED`) — die Server-Daten regelmäßig neu
    holt: `router.refresh()` (re-rendert die RSC, holt frische `getLiveMatches`
    + Rating/Punkte). Intervall ~**60 s** (passend zum Minuten-Update der API).
  - „Hat-Live"-Status kommt **vom Server** (Prop/RSC) — der Client pollt nur,
    wenn live; sobald kein Spiel mehr live ist, **stoppt** das Polling.
  - **Wieder-Öffnen/Fokus**: bei `visibilitychange`→sichtbar und `focus`, wenn
    live, sofort einmal refreshen (deckt „App wieder aufmachen → aktuell" ab).
  - Auf Dashboard (`/`) und Match-Detail (`/match/[id]`) einsetzen (dort, wo
    Live-Score/Punkte angezeigt werden).
- **Out of scope (explicit)**: WebSockets/Server-Sent-Events (Polling reicht);
  Push-Notifications; Polling bei nicht-live Spielen; Änderung der API/Cron.

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
- [ ] Kein Live-Spiel → **kein** Polling (Intervall gestoppt).
- [ ] App wieder in den Vordergrund/Fokus → bei Live sofort aktualisiert.
- [ ] Funktioniert im Browser und in der installierten PWA.
- [ ] Kein Memory-Leak (Interval/Listener werden sauber aufgeräumt).
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Demo mit Live-Spiel → Dashboard offen lassen → nach ~1 min aktualisiert sich
   Score/Punkte ohne Zutun.
2. Kein Live-Spiel → kein wiederholtes Neuladen (Network-Tab ruhig).
3. Tab/App in Hintergrund, dann zurück → bei Live sofort frisch.
