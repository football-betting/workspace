# FE-023 Result — Zweisprachigkeit Deutsch / Englisch

**Geschlossen**: 2026-05-30
**Commits**:
- `frontend` (main) `c5e156a FE-023: bilingual DE/EN via next-intl with locale switcher (#28)` (squash-merge von PR #28)

## Was wurde gemacht

next-intl 4 (cookie-basiert, ohne URL-Routing) eingeführt. Standardsprache
Deutsch, Umschalter (DE/EN) in der TopAppBar, Wahl per `locale`-Cookie
persistiert, `<html lang>` folgt der aktiven Sprache. Alle nutzersichtbaren
Strings der App (Dashboard, Ranking, Profil, Match, Login/Signup) laufen über
Übersetzungs-Kataloge `messages/de.json` + `messages/en.json` mit identischer
Schlüsselstruktur. Eigennamen (Standort-/Stadtnamen, `TOURNAMENT_NAME`) bleiben
unübersetzt.

## Geänderte Dateien (alle in `frontend/`)

- Infra: `next.config.ts` (next-intl-Plugin), `i18n/config.ts`,
  `i18n/request.ts`, `i18n/locale-action.ts`, `app/layout.tsx`
  (`NextIntlClientProvider` + `getLocale`), `components/LocaleSwitcher.tsx`
- Kataloge: `messages/de.json`, `messages/en.json` (Namespaces Nav, Common,
  Dashboard, TipForm, Ranking, Scoring, Profile, Match, Auth)
- Migriert: Dashboard- (LiveBlock, UpcomingList, TipForm, TabBar,
  RankingSidebar, TopAppBar, BottomNav), Ranking- (RankingTable,
  ScoringInfobox), Profil- (ProfileHeader, StatTiles, WinnerCards,
  WinnerEditForm, PredictionHistory), Match- (MatchHeader, PredictionsTable)
  und Auth-Komponenten/Seiten
- Test: `tests/unit/i18n-messages.test.ts` (de/en Key-Parität + keine leeren Werte)
- Build-Approval: `pnpm-workspace.yaml` (`@parcel/watcher`, `@swc/core`
  ergänzt; `unrs-resolver` u.a. erhalten) — nötig nach `pnpm add next-intl`
  unter pnpm 11.3

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **79/79 passed** (12 Dateien, inkl. Parität-Test)
- `pnpm build` → erfolgreich, alle Routen

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**. Cookie-Locale-Flow korrekt, `getTranslations` nur
in async Pages / `useTranslations` sonst, Key-Parität erzwungen,
ScoringInfobox-Zahlenwerte unverändert (gehören XR-003), kein `any`.

## Notizen / Folge

- **ScoringInfobox-Werte** (4/2/1, +12/+6) werden durch **XR-003** aktualisiert
  (dort auch der Draw-Hinweis) — die Katalog-Werte sind dann anzupassen.
- **Länder-/Team-Namen** werden noch nicht übersetzt → Folge-Ticket
  (Country-Name-Localization).
- Gestagte `public/img/bg*.png` (FE-028) bewusst ausgeschlossen.
