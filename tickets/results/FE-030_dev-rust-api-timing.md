# FE-030 Result — Dauer der Rust-API-Aufrufe sichtbar machen

**Geschlossen**: 2026-05-30
**Commits** (`frontend` main):
- `98aeb95 FE-030: log Rust API call duration in fetchApi (#29)` — Messung + Logging
- `096d968 FE-030: gate Rust API timing log to dev only, production stays silent (#30)` — Dev-Gating

## Was wurde gemacht

In `lib/api.ts` (`fetchApi`) wird die Dauer jedes Rust-API-Aufrufs mit
`performance.now()` gemessen und als `[rust-api] GET /<path> <ms>ms`
ausgegeben — bei Netzwerkfehlern als `... failed after <ms>ms`. Die Ausgabe
erfolgt **nur im Dev-Modus** (`NODE_ENV !== "production"`), damit man Dauer und
doppelte Queries sieht; in **Production bleibt es still** (kein Log-Rauschen).
Nur der Pfad wird geloggt — keine Bodies, Tokens, Cookies oder Auth-Header.
Rückgabewerte und Fehlerverhalten von `fetchApi` sind unverändert.

## Entscheidung zum Server-Timing-Header

Das Ticket sah ursprünglich Ausgabe über einen `Server-Timing`-Response-Header
vor. Recherche (Context7, Next.js 16): **Server Components können keine
Response-Header setzen** — `Server-Timing` ginge nur in Route Handlers /
Middleware. Die Rust-Reads laufen aber alle im RSC-Page-Render, daher ist ein
browser-sichtbarer Header für genau diese Aufrufe ohne Architektur-Umbau
(SSR→Client-Fetch über Proxy-Route) nicht umsetzbar. Owner-Entscheidung:
**Dev-Konsole, Prod still** — der Header entfällt, das Kernziel (Sichtbarkeit
in Dev, kein Prod-Rauschen) ist erfüllt.

## Geänderte Dateien (alle in `frontend/`)

- `lib/api.ts` — Messung + Dev-gated Logging
- `tests/unit/api-timing.test.ts` (neu) — Erfolg, Netzwerkfehler-Rethrow,
  und Prod-Schweigen

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **82/82 passed**

## Reviewer-Feedback

Reviewer-Agent (PR #29): **APPROVE** — Security (nur Pfad), Verhalten
unverändert, Tests decken Erfolg + Fehler. Das Dev-Gating (#30) ergänzt den
Prod-Schweigen-Test.
