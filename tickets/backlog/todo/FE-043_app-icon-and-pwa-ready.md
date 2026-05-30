# FE-043 App-Icon einbinden + PWA-ready vorbereiten

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
Es gibt ein generiertes Icon unter `frontend/public/icon/icon.png`. Das soll
als **Seiten-Icon** (Favicon/Tab-Icon) genutzt werden — und so vorbereitet
werden, dass eine **spätere PWA** (Android/Apple installierbar) direkt darauf
aufsetzen kann (Manifest + passende Icon-Größen, inkl. Apple-Touch-Icon).

## Scope
- **In scope**:
  - Quelle: `public/icon/icon.png`.
  - Next-App-Router-Konventionen nutzen: `app/icon.png` (Favicon) und
    `app/apple-icon.png` (Apple-Touch) — bzw. via Metadata-`icons`.
  - **Web-Manifest** (`app/manifest.ts`): `name`, `short_name`,
    `theme_color`/`background_color` (zum dunklen Theme passend), `display:
    standalone`, `start_url`, und **Icons** in 192×192 und 512×512 **inkl.
    `purpose: "maskable"`** (PWA-Installierbarkeit Android/Apple).
  - Benötigte Icon-Größen aus der Quelle erzeugen (z. B. mit `sharp`, schon
    installiert) und unter `public/icon/` ablegen.
  - Das Quell-Icon `public/icon/icon.png` ist bereits auf `main` (kam
    versehentlich mit FE-031 mit) — FE-043 erzeugt nur die abgeleiteten
    Größen/Manifest, fügt die Quelle nicht erneut hinzu.
- **Out of scope (explicit)**: Vollständige PWA (Service-Worker, Offline,
  Install-Prompt) — nur die Icon-/Manifest-Grundlage; Splash-Screens.

## References
- `frontend/public/icon/icon.png` — Quell-Icon (vorhanden)
- `frontend/app/layout.tsx` — `metadata` (Title/Description) als Anker für
  `icons`/Manifest-Verknüpfung
- Next.js App-Router: `app/icon`, `app/apple-icon`, `app/manifest`
- `sharp` (in `pnpm-workspace.yaml onlyBuiltDependencies`) — Resize

## Acceptance Criteria
- [ ] Im Browser-Tab erscheint das Icon (Favicon).
- [ ] `app/manifest` liefert ein gültiges Web-Manifest mit Icons 192 & 512
      (inkl. maskable), `display: standalone`, Theme-/Background-Color.
- [ ] Apple-Touch-Icon vorhanden (iOS „Zum Home-Bildschirm").
- [ ] Lighthouse/DevTools → Application → Manifest zeigt das Manifest + Icons
      ohne Fehler (manuelle Prüfung).
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. Tab-Icon sichtbar.
2. DevTools → Application → Manifest: Name, Icons (192/512/maskable), `standalone`.
3. iOS Safari „Zum Home-Bildschirm" zeigt das Icon (sofern testbar).
