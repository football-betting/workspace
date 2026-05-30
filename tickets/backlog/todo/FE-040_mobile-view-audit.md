# FE-040 Mobile-Ansicht-Review: jede Seite auf Mobile prüfen

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
todo

## Owner
reviewer

## Background
Bevor wir gezielt am Mobile-Layout arbeiten, soll erst der **Ist-Zustand**
geprüft werden: jede Seite in mobiler Breite durchgehen und festhalten, was
passt und was nicht. Ergebnis ist eine **Befund-Liste** pro Seite — daraus
werden danach konkrete Fix-Tickets gezogen. Dieses Ticket **ändert keinen
Code**, es dokumentiert nur.

## Vorgehen
- Mobile-Viewport (z. B. 375×812, iPhone-ähnlich) — über den laufenden
  Dev-Server (`pnpm dev`) und DevTools-Device-Mode oder Screenshots.
- Jede Seite einzeln prüfen (eingeloggt mit Demo-User):
  1. **Login** (`/login`) und **Registrierung** (`/signup`)
  2. **Dashboard** (`/`) — Live-Block, Rangliste-Platzierung, Upcoming/Tip-Zeilen
  3. **Rangliste** (`/ranking`) — Tabelle/Tabs, ScoringInfobox
  4. **Match-Detail** (`/match/{id}`) — Header, Predictions
  5. **Profil** (`/user/{id}` bzw. `/profile`) — Header, Stats, Winner-Karten,
     History
  6. **BottomNav** — Erreichbarkeit/Aktiv-Zustand
- Pro Seite prüfen: Überlauf/horizontales Scrollen, abgeschnittene Inhalte,
  Tap-Target-Größe, Textumbruch/Lesbarkeit, Abstände, Buttons, Flaggen/Icons.

## Scope
- **In scope**: Befunde dokumentieren (pro Seite: OK / Problem + kurze
  Beschreibung) im Result-Doc; Schweregrad grob (blockierend / kosmetisch).
- **Out of scope (explicit)**: Code-Fixes (kommen als Folge-Tickets); Redesign.

## Acceptance Criteria
- [ ] Für **jede** der o. g. Seiten ein Mobile-Befund (OK oder konkrete
      Probleme mit kurzer Beschreibung).
- [ ] Liste der empfohlenen Folge-Fix-Tickets (Titel + Seite) am Ende.
- [ ] Ergebnis als `tickets/results/FE-040_mobile-view-audit.md`.

## Verification (manual)
1. Result-Doc deckt alle Seiten ab.
2. Jeder Befund ist nachvollziehbar (Seite + was passt nicht).
