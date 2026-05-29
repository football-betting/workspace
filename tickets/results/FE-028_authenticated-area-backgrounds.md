# FE-028 Result — Hintergrundbilder für eingeloggte Bereiche

**Geschlossen**: 2026-05-30
**Commits** (`frontend` main):
- `b36d00b FE-028: per-area dark background images for authenticated pages (#31)`
- `359f388 FE-028: single responsive background in app layout (desktop bg2 / mobile bg1, overlay 85/95) (#32)`

## Was wurde gemacht

Dekorative, abgedunkelte Hintergrundbilder auf **allen** eingeloggten Seiten,
einmal zentral im `app/(app)/layout.tsx` eingebunden (nicht pro Seite):
- **Desktop** → `bg2.png`, **Mobile** → `bg1.png` (responsive via
  `hidden md:block` / `md:hidden`)
- Overlay responsive: **mobil 85 % / Desktop 95 %**
  (`bg-background/85 md:bg-background/95`)
- Login/Registrierung → **kein** Bild (liegen unter `(auth)`, nicht betroffen)

Umsetzung: presentational Komponente `PageBackground` (`fixed inset-0 -z-10`,
zwei responsive `<img object-cover>` + dunkles Overlay). `app/globals.css` so
angepasst, dass `body` transparent ist und `html` die dunkle Basisfarbe
behält — damit das `-z-10`-Bild sichtbar wird, ohne Inhalte zu verdecken.

Hinweis: Zuerst per Bereich (bg1 Dashboard / bg2 sonst, Overlay 80→95)
umgesetzt (#31), dann auf Nutzerwunsch auf eine einzige responsive Variante
im Layout umgestellt (#32).

## Geänderte Dateien (alle in `frontend/`)

- `components/PageBackground.tsx` (neu) — zwei responsive Bilder + Overlay
- `app/(app)/layout.tsx` — bindet `PageBackground` einmal zentral ein
- `app/globals.css` — `body` transparent, `html` behält Basisfarbe
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
