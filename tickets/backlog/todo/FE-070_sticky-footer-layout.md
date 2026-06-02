# FE-070 Sticky-Footer (Footer springt auf Profil)

## Repo
frontend
## Type
bug
## Risk
low
## Priority
medium
> User (2026-06-02): auf Profil erscheint der Footer zuerst (oben) und rutscht dann runter.

## Status
todo
## Owner
implementer

## Background
`app/(app)/layout.tsx` rendert `<Footer />` direkt nach `{children}` ohne
Sticky-Footer-Container. Bei kurzem oder noch ladendem Inhalt (z. B. Profil,
während die Rust-Daten streamen) sitzt der Footer weit oben und rutscht dann
nach unten, wenn der Inhalt wächst → Layout-Sprung, unschön.

## Scope
- **In scope**: Sticky-Footer im `(app)`-Layout — Container `min-h-dvh flex
  flex-col`, `{children}` in `flex-1`, `<Footer />` darunter → Footer sitzt
  immer am unteren Rand, kein Hochrutschen/Sprung. Fixe TopAppBar/BottomNav +
  PageBackground dürfen nicht brechen.
- **Out of scope**: Redesign; Skeleton/Loading-States.

## Acceptance Criteria
- [ ] Footer sitzt bei kurzem Inhalt am unteren Viewport-Rand, nicht mitten drin.
- [ ] Beim Laden des Profils kein sichtbarer Footer-Sprung nach oben/unten.
- [ ] Dashboard/Ranking/Match/Settings-Layout unverändert korrekt.
- [ ] Quality Gate: `bash scripts/check.sh --build`.
