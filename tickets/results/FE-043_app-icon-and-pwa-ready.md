# FE-043 Result — App-Icon + PWA-ready

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `852a07b FE-043: app icon (favicon + apple-icon) and PWA web manifest (#38)` (squash-merge von PR #38)

## Was wurde gemacht

Aus dem 1024×1024-Quell-Icon (`public/icon/icon.png`, schon auf main) die
benötigten Größen erzeugt und über Next-App-Router-Konventionen verdrahtet:
- `app/icon.png` (256) → Favicon/Tab-Icon (Next verlinkt automatisch).
- `app/apple-icon.png` (180) → Apple-Touch-Icon (iOS „Zum Home-Bildschirm").
- `public/icon/icon-192.png`, `icon-512.png` → Manifest-Icons.
- `app/manifest.ts` → Web-Manifest: `name`/`short_name`, `display: standalone`,
  `theme_color`/`background_color` = `#121317`, Icons 192/512 inkl.
  `purpose: "maskable"` (PWA-Grundlage Android/Apple).

## Geänderte Dateien (frontend)
- `app/manifest.ts` (neu), `app/icon.png` (neu), `app/apple-icon.png` (neu),
  `public/icon/icon-192.png` (neu), `public/icon/icon-512.png` (neu)

## Quality-Gate
- `bash scripts/check.sh --build` → tsc 0, vitest 91/91, build ok (Manifest +
  Icon-Routen via Next-Konventionen generiert).

## Notizen
- Größen mit macOS `sips` erzeugt (sharp ist transitive, nicht im Top-Level
  `node_modules` per-require auflösbar) — Ergebnis sind committete PNGs,
  Generierungs-Tool ist für die Laufzeit irrelevant.
- Review: Asset-Generierung + Standard-Next-Manifest, build-verifiziert →
  Self-Review statt Reviewer-Agent.
- Out of scope (offen): vollständige PWA (Service-Worker/Offline/Install-Prompt).
