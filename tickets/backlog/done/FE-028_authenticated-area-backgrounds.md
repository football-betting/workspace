# FE-028 Hintergrundbilder für eingeloggte Bereiche

## Repo
frontend

## Type
feature

## Risk
low

## Priority
low

## Status
todo

## Owner
implementer

## Background
Die Design-Vorlage sieht dekorative Hintergrundbilder vor. Die zwei Bilder
(`public/img/bg1.png`, `public/img/bg2.png`) sind bereits im Repo abgelegt.
Sie sollen als rein kosmetischer Hintergrund auf den **eingeloggten** Seiten
erscheinen — **nicht** auf Login/Registrierung und nicht für
unauthentifizierte Besucher. Pro Bereich soll ein unterschiedliches Bild
verwendet werden.

## Scope
- **In scope**:
  - Hintergrundbilder auf den Seiten unter `app/(app)/` einbinden, pro Bereich
    verschieden. Vorschlag (anpassbar): `bg1` → Dashboard (`/`), `bg2` →
    Profil, Ranking, Match-Detail.
  - Sicherstellen, dass Login/Registrierung (`app/(auth)/…`) **keinen**
    Hintergrund zeigen.
  - Lesbarkeit wahren (Overlay/Abdunklung, damit Inhalte über dem Bild
    kontrastreich bleiben).
- **Out of scope (explicit)**: Animationen/Parallax über ein einfaches
  Cross-Fade hinaus; neue Bild-Assets erstellen; Theming/Dark-Mode-Varianten;
  Änderungen an der Auth-Logik.

## References
- `frontend/public/img/bg1.png`, `frontend/public/img/bg2.png` — bereits
  vorhandene Assets
- `frontend/app/(app)/layout.tsx` — Layout der eingeloggten Seiten (natürliche
  Grenze gegenüber `(auth)`)
- `frontend/app/(auth)/login/`, `frontend/app/(auth)/signup/` — dürfen keinen
  Hintergrund bekommen
- `frontend/app/layout.tsx` — Root-Layout (`<html>`/`<body>`)

## Notes
Die Bilder sind **AI-generiert**. Rechtlich unkritisch, aber zur
Nachvollziehbarkeit hier vermerkt — keine Fremd-Assets, keine
Attributionspflicht eingegangen.

## Acceptance Criteria
- [ ] Eingeloggt auf Dashboard, Ranking, Profil, Match-Detail → bereichs-
      abhängiges Hintergrundbild sichtbar.
- [ ] Login- und Registrierungs-Seite → **kein** Hintergrundbild.
- [ ] Unterschiedliche Bilder je Bereich gemäß Mapping.
- [ ] Inhalte bleiben über dem Bild gut lesbar (Overlay/Kontrast).
- [ ] Bilder werden korrekt aus `public/img/` ausgeliefert (im Commit
      enthalten).
- [ ] Quality Gate passes in `frontend`:
  - `pnpm exec tsc --noEmit && pnpm exec vitest run`

## Verification (manual)
1. Ausgeloggt `/login` und `/signup` → kein Hintergrundbild.
2. Einloggen, Dashboard → Hintergrund (bg1).
3. Auf Profil/Ranking/Match-Detail wechseln → anderer Hintergrund (bg2).
4. Texte/Karten bleiben überall gut lesbar.
