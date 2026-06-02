# FE-068 Result — Rust-API-Antwortzeit im Production-Log

**Geschlossen**: 2026-06-02
**Commits**: `frontend` (main) `ca937f6 (#70)` + Test-Fix `2148c2b (#71)`

## Was wurde gemacht
`lib/api.ts` loggt die Dauer jedes Rust-API-Calls jetzt **auch in Production**
(vorher nur Dev) — sichtbar im Server-/PM2-Log. Format lesbarer gemacht:
- Erfolg: `[rust-api] GET /rating → 200 in 12ms`
- Fehler: `[rust-api] GET /user/5 → failed in 12ms (network error)`
Nur Pfad + Status + ms — keine Bodies/Tokens/Cookies.

**Kein Response-Header**: in Next.js können RSC-Seiten keine eigenen Response-
Header setzen (Framework-Limit, Context7-bestätigt); der Server-Log ist der
gewählte, minimale Weg (nice-to-have).

## Geänderte Dateien
- `frontend/lib/api.ts`, `frontend/tests/unit/api-timing.test.ts`

## Quality-Gate
- `bash scripts/check.sh` → grün (189 Tests).

## Notiz
Der erste Commit (#70) landete kurz rot auf main, weil `api-timing.test.ts` das
alte Format/„Prod-stumm" erwartete und der Commit nicht an `check.sh` gekoppelt
war; sofort per #71 (Test-Anpassung) gefixt → main grün.
