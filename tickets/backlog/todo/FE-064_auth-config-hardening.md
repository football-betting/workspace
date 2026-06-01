# FE-064 Hardening: Enumeration-Timing, APP_BASE_URL, Rate-Limit-IP, Push-Ownership, Cron

## Repo
frontend

## Type
chore

## Risk
medium

## Priority
medium

> Security-Audit 2026-06-01 (Sammelticket Low/Medium-Hardening).

## Status
todo

## Owner
implementer

## Background
Mehrere Defense-in-depth-Härtungen aus dem Audit, einzeln klein:

## Findings + Fixes (Audit)
1. **Forgot-Password-Timing-Enumeration** (`forgot-password/route.ts:66-86`,
   MEDIUM): der awaited SMTP-Send läuft nur für existierende User → messbarer
   Latenz-Unterschied. **Fix**: Mail-Versand entkoppeln (nicht awaiten / queuen),
   sodass die Antwortzeit konstant ist.
2. **APP_BASE_URL nicht erzwungen** (`forgot-password/route.ts:17-22`,
   `cron/notifications/route.ts:25-31`, LOW): Fallback auf
   `request.nextUrl.origin` (Host-Header) bei Reset-Links → Host-Poisoning. **Fix**:
   in Produktion `APP_BASE_URL` erzwingen (fail closed), nie Host-Fallback für
   sicherheitsrelevante Links.
3. **Rate-Limit-IP** (`lib/rate-limit.ts:96-107`, LOW): ohne `TRUST_PROXY`
   ein globaler `"unknown"`-Bucket (ein Angreifer sperrt alle aus); mit
   `TRUST_PROXY` ungeprüftes erstes XFF (Spoofing-Bypass). **Fix**: keine globale
   Sammel-Identität; bei Proxy konfigurierten Trusted-Hop-Count nutzen.
4. **Push-Subscription-Ownership** (`lib/push-store.ts:15-34`, LOW): `endpoint`
   ist global unique, `onConflictDoUpdate` setzt `userId` auf den Aufrufer um →
   fremde Subscription „übernehmbar". **Fix**: Upsert auf `(userId, endpoint)`
   scopen; fremden Endpoint nicht ohne Ownership-Nachweis umhängen.
5. **Cron-Secret-Vergleich nicht konstant-zeitig** (`cron/notifications/route.ts:39-41`,
   LOW): `===`. **Fix**: `crypto.timingSafeEqual` (beidseitig hashen). Zusätzlich
   grobe Rate-Limit/Lock auf den Cron-Endpoint; POST-only.
6. **DISABLE_RATE_LIMIT** (`lib/rate-limit.ts:30-52`, INFO): in prod nur Warnung.
   **Fix**: in `NODE_ENV==="production"` hart ignorieren.

## Scope
- **In scope**: die 6 Punkte oben. Jeweils minimal, kein Verhalten-Bruch.
- **Out of scope**: größere Auth-Architektur-Änderungen.

## Acceptance Criteria
- [ ] Forgot-Password-Antwortzeit für existierende/nicht-existierende Email vergleichbar.
- [ ] Reset-/Cron-Links nutzen `APP_BASE_URL` (prod erzwungen).
- [ ] Rate-Limit kein globaler `unknown`-Bucket; Proxy-Hop konfigurierbar.
- [ ] Push-Upsert respektiert Ownership.
- [ ] Cron: konstant-zeitiger Secret-Vergleich + Rate-Limit/POST-only.
- [ ] `DISABLE_RATE_LIMIT` in prod wirkungslos.
- [ ] Quality Gate: `bash scripts/check.sh`.
