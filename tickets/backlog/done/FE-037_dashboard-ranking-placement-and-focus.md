# FE-037 Dashboard: Rangliste-Platzierung + globaler Fokus-Stil

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
done

## Background
Während der Live-Politur des Dashboards (zusammen mit FE-025/FE-027) kamen zwei
übergreifende Wünsche auf: die Mini-Rangliste sollte auf schmalen Screens
zwischen Live-Spielen und Upcoming sitzen (nicht ganz unten), und die
Sidebar-Aufteilung erst ab einer breiteren Schwelle greifen. Außerdem sollte
der app-weite Fokus-Stil die Markenfarbe statt des nativen Weiß/Blau nutzen.

## Scope (umgesetzt)
- `app/(app)/page.tsx`: Mini-Rangliste **zwischen** Live-Block und
  Upcoming-Liste bei `< 980px`; ab `min-[980px]` als rechte Sidebar
  (Custom-Breakpoint statt `md`). Zwei responsive Instanzen.
- `app/globals.css`: globale `:focus-visible`-Outline in `var(--color-primary)`
  statt der nativen Weiß/Blau-Outline.

## Acceptance Criteria
- [x] `< 980px`: Rangliste zwischen Live und Upcoming.
- [x] `≥ 980px`: Rangliste als rechte Sidebar.
- [x] Tastatur-Fokus app-weit in primary (kein weiß/blau).
- [x] Quality Gate: `tsc --noEmit`, `vitest run`, `build` grün.
