# FE-058 Result — App-Footer mit Feature-Übersicht

**Geschlossen**: 2026-06-01
**Commit**: `frontend` (main) `3234671 FE-058: add app footer with feature overview (#60)` (squash-merge PR #60)

## Was wurde gemacht
Gemeinsamer, lokalisierter Footer im `(app)`-Layout (alle eingeloggten Seiten):
© + App-Name + Version (package.json), „Funktionen"-Übersicht (Live-Scoring,
Tippen & Wertung 5/3/2, Ranglisten, PWA/Offline, DE/EN, Passwort-Reset, Avatare)
und GitHub-Link. Ersetzt die Legal-/Support-Links aus dem Mockup durch eine
developer-sichtbare Feature-Liste (vom User gewählte Richtung).

## Geänderte/neue Dateien
- `frontend/components/Footer.tsx` (neu)
- `frontend/app/(app)/layout.tsx`
- `frontend/messages/de.json`, `messages/en.json` (`Footer`-Namespace)

## Quality-Gate
- `bash scripts/check.sh --build` → grün (tsc + vitest + i18n-Parität + Full Next-Build).

## Hinweis
- `design/account.html` + `design/match_detail.html` (Footer-Mockup) wurden als
  Design-Assets committet (`4e7e342`, `3762d20`).
