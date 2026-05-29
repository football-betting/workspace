# FE-030 Dev-only: Dauer der Rust-API-Aufrufe sichtbar machen

## Repo
frontend

## Type
feature

## Risk
low

## Priority
low

## Status
todo

## Owner
implementer

## Background
Beim Entwickeln soll nachvollziehbar sein, wie lange die Aufrufe an die
Rust-API (betting-api, gelesen über `lib/api.ts`) dauern. Diese Messung/
Anzeige darf **ausschließlich in der Entwicklung** aktiv sein, niemals in
Produktion.

## Scope
- **In scope**:
  - In `lib/api.ts` (`fetchApi`) die Dauer jedes Rust-Aufrufs messen
    (`fetch`-Start bis Antwort).
  - Ausgabe nur wenn `process.env.NODE_ENV !== "production"`.
  - Sichtbarmachung gemäß gewählter Variante (siehe Notes).
- **Out of scope (explicit)**: Produktions-Telemetrie/Monitoring; Messung
  innerhalb der Rust-Services selbst; persistente Speicherung der Messwerte.

## References
- `frontend/lib/api.ts` — `fetchApi`, einziger Pfad zur Rust-API
- `frontend/app/(app)/page.tsx`, `ranking/page.tsx`, `match/[id]/page.tsx`,
  `user/[id]/page.tsx` — Aufrufer von `fetchApi`

## Notes
Surfacing-Variante ist noch zu entscheiden (Owner):
1. **Server-Konsole** — `console.log("[rust-api] GET /rating 123ms")` im
   Dev-Terminal. Einfachste Variante.
2. **Server-Timing-Header** — sichtbar im Browser-DevTools-Network-Tab.
3. **On-Screen Dev-Overlay** — kleines Badge/Panel auf der Seite, das die
   letzte(n) Rust-Aufruf-Dauer(n) anzeigt. Am direktesten "sichtbar",
   erfordert aber Plumbing Server→Client.

## Acceptance Criteria
- [ ] In Dev wird für jeden Rust-API-Aufruf die Dauer erfasst und gemäß
      gewählter Variante sichtbar.
- [ ] In Produktion (`NODE_ENV=production`) keinerlei Ausgabe/Overhead.
- [ ] Keine Änderung am Verhalten von `fetchApi` (Rückgabe/Fehler unverändert).
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. `pnpm dev`, Dashboard laden → Rust-Aufruf-Dauer sichtbar (gewählte
   Variante).
2. Mit `NODE_ENV=production` gebaut/gestartet → keine Timing-Ausgabe.
