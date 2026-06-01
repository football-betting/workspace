# FE-063 Result — Security-Header (HSTS ergänzt)

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `b9de281 FE-063: add HSTS to the existing security-header middleware (#65)` (PR #65)

## Befund (Review-Korrektur)
Der ursprüngliche Audit-Befund „keine Security-Header" war ein **False Positive**:
`frontend/proxy.ts` (Middleware, FE-012) setzt bereits CSP (inkl.
`frame-ancestors 'none'`, `object-src 'none'`, `base-uri/form-action 'self'`),
`X-Frame-Options: DENY`, `Referrer-Policy`, `Permissions-Policy` **und**
`X-Content-Type-Options: nosniff` auf allen Responses. Clickjacking-Schutz war
also bereits vorhanden.

## Was wurde gemacht
Einzig fehlend war **HSTS** → `Strict-Transport-Security: max-age=63072000;
includeSubDomains` in die bestehende `SECURITY_HEADERS`-Suite ergänzt (proxy.ts).
Die fälschlich in `next.config.ts` hinzugefügte (von der Middleware ohnehin
überschriebene) Header-Block wurde verworfen → eine Quelle der Wahrheit.

## Geänderte Dateien
- `frontend/proxy.ts` (1 Zeile)

## Quality-Gate
- `bash scripts/check.sh` → grün.
