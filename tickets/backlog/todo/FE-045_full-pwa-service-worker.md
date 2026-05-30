# FE-045 Vollständige PWA: Service-Worker, Offline, installierbar

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
FE-043 hat Icon + Web-Manifest geliefert (PWA-ready Grundlage). Jetzt soll die
App eine **echte PWA** werden: per Service-Worker installierbar (Android/iOS),
mit Caching und Offline-Fallback. Stale-Content-Risiko beachten (SW-Caching
darf keine veralteten Daten/Builds festhalten).

## Scope
- **In scope**:
  - Service-Worker-Setup für den **Next.js App Router** über eine gepflegte
    Library (z. B. **Serwist `@serwist/next`** als moderner Nachfolger von
    next-pwa) — **aktuelle Setup-Schritte via Context7 prüfen**, nicht raten.
  - **Precache** der statischen Assets / App-Shell; **Runtime-Caching**:
    statisch → cache-first, dynamische/Daten-Requests (Rust-API, Tipps) →
    network-first oder stale-while-revalidate, sodass keine veralteten
    Spiel-/Tippdaten hängen bleiben.
  - **Offline-Fallback** (einfache Offline-Seite, wenn keine Verbindung).
  - **Installierbarkeit**: erfüllt PWA-Install-Kriterien (Manifest aus FE-043 +
    SW + Secure-Context). Optionaler In-App-Install-Button via
    `beforeinstallprompt`.
  - SW **in Dev deaktiviert** (kein Caching beim Entwickeln).
- **Out of scope (explicit)**: Push-Notifications; Background-Sync; vollständige
  Offline-Funktionalität (Tippen ohne Netz); App-Store-Veröffentlichung.

## References
- `frontend/app/manifest.ts`, `app/icon.png`, `app/apple-icon.png` (FE-043)
- `frontend/next.config.ts` — SW-Plugin-Einbindung
- Serwist / `@serwist/next` (Doku via Context7 MCP)

## Acceptance Criteria
- [ ] Production-Build registriert einen Service-Worker; DevTools → Application
      → Service Workers zeigt ihn aktiv.
- [ ] App ist **installierbar** (Chrome „Installieren" / iOS „Zum
      Home-Bildschirm" startet standalone).
- [ ] Offline (Netz aus, Seite reload) → sinnvoller Offline-Fallback statt
      Browser-Fehlerseite.
- [ ] Daten-Requests werden **nicht** dauerhaft veraltet gecacht (frische
      Spiel-/Tippdaten bei Verbindung).
- [ ] SW in Dev inaktiv; `pnpm dev` ohne Caching-Probleme.
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. `pnpm build && pnpm start` → DevTools: SW aktiv, Manifest ok.
2. „Installieren" → App startet standalone mit Icon.
3. Offline → Offline-Fallback; wieder online → aktuelle Daten.
