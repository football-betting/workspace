# FE-035 Result — Flaggen via Library, URL-geladen + gecacht

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `1f74603 FE-035: flags via flag-icons (URL-loaded from public/flags, gitignored), TLA->ISO-2 map, placeholder (#43)` (squash-merge von PR #43)

## Was wurde gemacht

- **Quelle**: `flag-icons@7.5.0` (lipis) — **MIT-Lizenz** (Copyright 2013
  Panayiotis Lipiridis). 271 Länder-SVGs (4×3), inkl. UK-Subdivisions
  (gb-eng/gb-sct/gb-wls/gb-nir).
- **Bereitstellung URL-geladen + gecacht, NICHT inline**: `scripts/copy-flags.mjs`
  kopiert die Package-SVGs nach `public/flags/`, verdrahtet als `predev`/
  `prebuild` (+ `copy-flags`). `public/flags/` ist **gitignored** (generiert,
  nicht committet). `Flag.tsx` lädt weiter per `<img src="/flags/{iso2}.svg">`.
- **Mapping** `lib/flag.ts` `tlaToIso2`: 3-stellige Codes → ISO-2; alle 9
  Demo-Länder, Nicht-Europa (BRA/ARG/USA/JPN …), ISO-3-Aliase (DEU→de),
  case-insensitive; **178 Mapping-Ziele, alle mit echter Datei** (0 broken).
  Unbekannt → neutraler Globus-Platzhalter (kein Broken-Image).
- `Flag`-API `{ tla, name, className }` unverändert (alle Call-Sites laufen).

## Geänderte Dateien (frontend)
- `components/dashboard/Flag.tsx`, `lib/flag.ts` (neu),
  `scripts/copy-flags.mjs` (neu), `tests/unit/flag.test.ts` (neu),
  `package.json` (Dep + predev/prebuild), `.gitignore` (`/public/flags`),
  `pnpm-lock.yaml`

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **114/114**; `--build` → ok
  (prebuild füllt `public/flags/`).

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** — kein Inline-Flag (URL `<img>`), 178/178
Mapping-Ziele vorhanden, API stabil, MIT, kein `any`, `pnpm-workspace.yaml`
intakt.
