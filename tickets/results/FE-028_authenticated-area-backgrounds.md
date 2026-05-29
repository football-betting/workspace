# FE-028 Result — Hintergrundbilder für eingeloggte Bereiche

**Geschlossen**: 2026-05-30
**Commits**:
- `frontend` (main) `b36d00b FE-028: per-area dark background images for authenticated pages (#31)` (squash-merge von PR #31)

## Was wurde gemacht

Dekorative, stark abgedunkelte Hintergrundbilder auf den eingeloggten Seiten,
pro Bereich verschieden:
- Dashboard → `bg1.png`
- Profil, Ranking, Match-Detail → `bg2.png`
- Login/Registrierung → **kein** Bild (bleiben auf dunklem Basis-Hintergrund)

Umsetzung: neue presentational Komponente `PageBackground`
(`fixed inset-0 -z-10`, `<img object-cover>` + dunkles Overlay), pro Page
eingebunden. `app/globals.css` so angepasst, dass `body` transparent ist und
`html` die dunkle Basisfarbe behält — damit das `-z-10`-Bild sichtbar wird,
ohne Inhalte zu verdecken. Overlay zunächst `bg-background/80`, auf Wunsch
(„zu hell") auf **`bg-background/95`** verstärkt.

## Geänderte Dateien (alle in `frontend/`)

- `components/PageBackground.tsx` (neu)
- `app/globals.css` — `body` transparent, `html` behält Basisfarbe
- `app/(app)/page.tsx`, `app/(app)/ranking/page.tsx`,
  `app/(app)/user/[id]/page.tsx`, `app/(app)/match/[id]/page.tsx` — Einbindung
- `public/img/bg1.png`, `public/img/bg2.png` (neu) — die Assets

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **82/82 passed**
- `pnpm build` → erfolgreich

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**. Stacking verifiziert (html-Basis → `-z-10`
Bild+Overlay → Inhalte darüber; `pointer-events-none`), `body`-Transparenz
ohne Nebenwirkung auf Login/Signup, kein `any`, nur die zwei Feature-Assets
neu. Overlay danach auf Nutzerwunsch auf 95 % verstärkt.

## Notiz

Die zuvor in anderen Tickets bewusst ausgeschlossenen `public/img/bg*.png`
sind jetzt mit FE-028 committet — das „Exclude"-Thema ist damit erledigt.
