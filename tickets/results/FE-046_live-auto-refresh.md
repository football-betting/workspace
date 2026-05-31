# FE-046 Result — Auto-Refresh bei Live-Spielen

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `0e3c022 FE-046: auto-refresh dashboard and match detail during live matches (#55)` (squash-merge PR #55)

## Was wurde gemacht
Client-Component `LiveRefresher` refreshed die Server-Daten via
`router.refresh()` (re-rendert RSC → frische Scores + Ranglisten-Punkte):
- ≥ 1 Spiel live (IN_PLAY/PAUSED) → Polling alle ~60 s.
- Sonst nächster Anpfiff in der Zukunft → Timer auf `kickoff − jetzt`, der das
  Polling **zum Anpfiff** automatisch startet.
- Kein Live + kein Anpfiff → **kein** Polling (Network ruhig).
- `visibilitychange`→sichtbar und `focus` → sofort refreshen + neu bewerten
  (App wieder in den Vordergrund holen).
- Sauberes Cleanup von Interval/Timer/Listener (kein Leak).

Serverseitig `getLiveState()` (lib/match.ts): `isLive` (IN_PLAY/PAUSED),
`nextKickoff` (nächster SCHEDULED-Anpfiff in der Zukunft). Eingesetzt auf
Dashboard (`/`, Ranglisten-Tabelle + Live) und Match-Detail (`/match/[id]`,
Live-Match), letzteres mit dem Status des konkreten Matches.

## Geänderte/neue Dateien
- `frontend/components/dashboard/LiveRefresher.tsx` (neu)
- `frontend/lib/match.ts` — `getLiveState` + `LiveState`
- `frontend/app/(app)/page.tsx` — Dashboard
- `frontend/app/(app)/match/[id]/page.tsx` — Match-Detail

## Quality-Gate
- `bash scripts/check.sh --build` → grün (tsc + vitest + Full Next-Build;
  `LiveRefresher` client-sauber, kein db-Import). Self-Review (low-risk,
  Cleanup verifiziert).
