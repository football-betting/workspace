# FE-068 Rust-API-Antwortzeit in den Server-Log (Production)

## Repo
frontend
## Type
chore
## Risk
low
## Priority
low
> User (2026-06-02): Rust-Call-Dauer auch in Production im Log sehen (PM2/Server).
> Nice-to-have, bewusst minimal (kein Response-Header — Next.js-RSC-Limit, s. Diskussion).

## Status
in-progress
## Owner
implementer

## Background
`lib/api.ts` misst die Dauer jedes Rust-API-Calls bereits (`performance.now()`)
und loggt `[rust-api] GET /<path> <ms>ms`. Das Logging ist aber nur in **Dev**
aktiv (`NODE_ENV !== "production"`), in Production stumm. Der Nutzer möchte die
Dauer auch in Production im Server-Log (PM2/journalctl) sehen.

## Scope
- **In scope**: das Timing-Logging in `lib/api.ts` **auch in Production**
  ausgeben (Erfolg + Fehlerfall). Weiterhin **nur Pfad + ms** loggen — keine
  Bodies, Tokens, Cookies, Auth-Header.
- **Out of scope**: Response-Header (Next.js-RSC-Limit); Metrics-Backend;
  Rust-seitige Änderung.

## Acceptance Criteria
- [ ] In Production erscheint pro Rust-Call eine Zeile `[rust-api] GET /<path> <ms>ms`
      (bzw. `failed after <ms>ms`) auf stdout → im PM2-/Server-Log sichtbar.
- [ ] Keine Secrets im Log.
- [ ] Quality Gate: `bash scripts/check.sh`.

## Verification (manual)
1. Production-Build/Start → eine Rust-gestützte Seite laden → Server-Log zeigt
   `[rust-api] GET /rating <ms>ms`.
