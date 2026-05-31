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
done

## Owner
implementer

## Background
FE-043 hat Icon + Web-Manifest geliefert (PWA-ready Grundlage). Jetzt soll die
App eine **echte PWA** werden: per Service-Worker installierbar (Android/iOS),
mit Caching und Offline-Fallback. Stale-Content-Risiko beachten (SW-Caching
darf keine veralteten Daten/Builds festhalten).

## Integritätsregel (hart)
**Tipps dürfen ausschließlich online abgegeben werden.** Niemals offline
queuen oder per Background-Sync später senden — sonst könnte ein offline
abgegebener Tipp **nach Spielbeginn/-ende** beim Server ankommen
(Cheating/Integritätsproblem). Offline → Tipp-Abgabe klar blockieren, nicht
puffern.

## Scope
- **In scope**:
  - Service-Worker-Setup für den **Next.js App Router** über eine gepflegte
    Library (z. B. **Serwist `@serwist/next`** als moderner Nachfolger von
    next-pwa) — **aktuelle Setup-Schritte via Context7 prüfen**, nicht raten.
  - **Precache** der statischen Assets/App-Shell (`self.__SW_MANIFEST`,
    `cleanupOutdatedCaches: true`).
  - **Runtime-Caching korrekt einordnen** — der SW sieht nur **Browser**-
    Requests (Navigationen, RSC-Payloads, statische Assets, browser-seitige
    `/api/*`-Routes), **nicht** die serverseitigen Rust-API-Calls (die laufen
    Server→Server im RSC-Render, für den SW unsichtbar):
    - Navigationen → **`NetworkFirst`** (kein cache-first für HTML — sonst
      veraltete/fremde Inhalte). Statische Assets (`_next/static`, Fonts,
      Icons) → `CacheFirst`/SWR.
    - **Nur GET** cachen. **Alle Nicht-GET** (POST/PUT/DELETE — Login, Tipp,
      Winner, Avatar …) → **NetworkOnly**, nie abgefangen/gequeued.
    - **Authentifizierte/personalisierte** Antworten **nicht** persistent
      cachen (kein Cross-User-/Stale-Leak); browser-seitige `/api/*`-Routes per
      denylist von Navigation/Cache ausnehmen.
  - **Offline-Fallback** über `precacheOptions.navigateFallback` (precachte
    Offline-Seite) — nur für fehlgeschlagene **Navigationen**, nicht für Assets.
  - **SW-Update-Flow**: `skipWaiting` + `clientsClaim` + `cleanupOutdatedCaches`,
    damit ein neuer Build aktiv wird (keine festhängende veraltete App);
    bei Bedarf „neue Version – neu laden"-Hinweis.
  - **Installierbarkeit**: PWA-Kriterien erfüllt (Manifest FE-043 + SW +
    Secure-Context). Optionaler Install-Button via `beforeinstallprompt`.
  - **iOS/Theme**: `appleWebApp`-Metadata (standalone, Status-Bar, Title) und
    `themeColor` über Next-`metadata` setzen.
  - **Maskable-Icon prüfen**: FE-043 nutzt fürs `maskable`-Icon dasselbe
    full-bleed 512er → wird vom OS-Maskenrand evtl. **beschnitten**. Entweder
    maskable-Variante mit Safe-Zone-Padding erzeugen oder `purpose: "maskable"`
    entfernen, wenn full-bleed.
  - SW **in Dev deaktiviert** (`disableDevLogs`, SW aus bei `pnpm dev`).
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
- [ ] Navigationen sind **network-first**; offline → precachte Offline-Seite
      (nicht für Assets).
- [ ] **Kein Nicht-GET** wird gecacht/gequeued (Login/Tipp/Winner/Avatar bleiben
      network-only); keine authentifizierten/personalisierten Antworten
      persistent gecacht.
- [ ] Neuer Deploy → nach Reload neue App (kein festhängender veralteter Shell).
- [ ] iOS-Standalone-Meta (`appleWebApp`) + `themeColor` gesetzt.
- [ ] Maskable-Icon ohne Beschneidung (Safe-Zone) — oder `maskable` entfernt.
- [ ] Lighthouse → „Installable"/PWA-Checks grün.
- [ ] **Tipp-Abgabe offline blockiert** (klare Meldung „nur online möglich"),
      **nicht** gequeued; kein Background-Sync für Tipps. Tipp-POST
      (`/api/tip/...`) wird **nie** vom SW gecacht/abgefangen.
- [ ] SW in Dev inaktiv; `pnpm dev` ohne Caching-Probleme.
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. `pnpm build && pnpm start` → DevTools: SW aktiv, Manifest ok.
2. „Installieren" → App startet standalone mit Icon.
3. Offline → Offline-Fallback; wieder online → aktuelle Daten.
