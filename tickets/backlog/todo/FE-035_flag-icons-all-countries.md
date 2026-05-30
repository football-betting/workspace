# FE-035 Flaggen für alle Länder via Library, URL-geladen + gecacht

## Repo
frontend

## Type
feature

## Priority
medium

## Risk
low

## Status
todo

## Owner
implementer

## Background
Aktuell liegen nur 24 europäische Flaggen (EM-2024) unter `public/svg/`,
geladen über `components/dashboard/Flag.tsx` als `<img src="/svg/{TLA}.svg">`.
Für **WM 2026** (48 Teams, alle Kontinente) fehlen die meisten. Statt Flaggen
einzeln zu sammeln, soll eine **gepflegte Flaggen-Library** als Quelle dienen,
die **alle** Länder abdeckt.

## Harte Vorgabe: URL-geladen, gecacht, NICHT inline
Flaggen müssen als **separate URL-Assets** geladen werden (`<img src=…>` bzw.
CSS-`background-image`), damit der **Browser sie cacht**. **Kein** Inline-SVG
direkt im HTML/DOM — das bläht jede Seite auf und verhindert Caching. (Die
heutige `<img src>`-Lösung erfüllt das bereits — beibehalten, nur Abdeckung +
Quelle ändern.)

## Scope
- **In scope**:
  - Flaggen-Set aus einer Library mit Lizenz (z. B. **`flag-icons`** von lipis,
    **MIT**, SVGs nach **ISO-3166-1 alpha-2**) — **Setup via Context7 prüfen**.
  - Die SVGs als **statische Dateien** unter `public/` bereitstellen (z. B.
    `public/flags/{iso2}.svg`), per Skript/postinstall aus dem Package kopieren
    oder committen — **kein Bundling als Inline-SVG**.
  - `Flag.tsx`: `<img src="/flags/{iso2}.svg">`; **TLA→ISO-2-Mapping** (App nutzt
    3-stellige Codes, Library 2-stellige) für alle Demo- + WM-2026-Länder.
    Unbekannter Code → neutraler Platzhalter statt Broken-Image.
  - Demo-Länder (GER/ESP/FRA/ITA/POR/ENG/NED/POL/CRO) + WM-2026-Teilnehmerfeld
    auflisten/recherchieren und mappen.
  - Quelle + Lizenz im Result-Doc dokumentieren.
- **Out of scope (explicit)**: Länder-Namen (FE-034); Redesign der `Flag`-API
  über das Mapping hinaus.

## References
- `frontend/components/dashboard/Flag.tsx` — heutiges `<img src>`, `TLA_MAP`
- `frontend/public/svg/` (alt) → `public/flags/` (neu, vollständig)
- `frontend/scripts/demo_data.ts` — Demo-Codes
- `flag-icons` (lipis, MIT) — Doku via Context7

## Acceptance Criteria
- [ ] Flaggen werden als **URL-Assets** geladen (`<img src>`/Background),
      browser-cachebar; **kein** Inline-SVG im HTML.
- [ ] Alle Demo-Länder + WM-2026-Teilnehmer haben eine Flagge (kein
      Broken-Image); unbekannter Code → Platzhalter.
- [ ] TLA→ISO-2-Mapping vollständig für die benötigten Länder.
- [ ] Quelle/Lizenz dokumentiert.
- [ ] Quality Gate: `bash scripts/check.sh --build`.

## Verification (manual)
1. Dashboard/Match/Ranking → alle Flaggen laden, im Network-Tab als einzelne
   `.svg`-Requests (cachebar), nicht inline im HTML.
2. Stichprobe Nicht-Europa (z. B. BRA, ARG, USA, JPN) → Flagge lädt.
