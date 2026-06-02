# FE-069 Result — Funktionen-Seite + Footer-Link
**Geschlossen**: 2026-06-02 · **Commit**: `frontend` main `83445e4 (#78)`

## Was wurde gemacht
- Neue Seite `app/(app)/features/page.tsx` (`/features`): lokalisierte
  Beschreibungen aller Funktionen (Live-Scoring/Auto-Refresh, Tippen & Wertung,
  Ranglisten, Profil & Historie, Erinnerungen, PWA/Offline, Passwort-Reset,
  Avatare, Mehrsprachig) als Karten-Grid, mit TopAppBar/BottomNav + Footer.
- `Footer.tsx`: Inline-Feature-Liste durch einen **Link „Funktionen" → /features**
  ersetzt (© + Version links, GitHub rechts bleiben).
- i18n: neuer `Features`-Namespace (de/en, `items.<key>.{title,desc}`);
  totes `Footer.features.*` entfernt, `Footer.featuresHeading` bleibt als Link-Label.

## Quality-Gate
- `bash scripts/check.sh --build` → grün (i18n-Parität, `/features` gebaut).
