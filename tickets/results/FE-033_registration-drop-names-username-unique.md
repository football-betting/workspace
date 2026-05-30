# FE-033 Result — Registrierung: Namen raus, Username unique, Name aus Email

**Geschlossen**: 2026-05-30
**Commit**: `frontend` (main) `d1c42da FE-033: drop firstName/lastName, unique username, displayNameFromEmail, local.dev demo emails (#35)` (squash-merge von PR #35)

## Was wurde gemacht

- `db/schema.ts`: `firstName`/`lastName` aus `user` entfernt, `username` auf
  `.unique()`. Keine neue Migration — die Baseline-Migration `0000_*.sql` +
  `meta/*_snapshot.json` wurden in lockstep angepasst (DB nicht produktiv,
  wird per `db:reset` neu erzeugt).
- Helper `lib/user-name.ts` `displayNameFromEmail(email)` — Local-Part vor `@`,
  an `.` trennen, kapitalisieren, mit Space verbinden (`rosa.parks@local.dev`
  → „Rosa Parks").
- Registrierung: Name-Felder raus (`signup-form.tsx`, `lib/validation/auth.ts`,
  `app/api/user/route.ts`), Duplicate-Username → sauberer **409** (kein
  SQL-Leak, `unknown` narrowing, kein `any`), Hinweis „nicht die Email" am
  Username-Feld (i18n de/en).
- `lib/auth.ts`: firstName/lastName aus `getUserAttributes` +
  `DatabaseUserAttributes`.
- `scripts/demo_data.ts`: Seed ohne Namen, eindeutige Usernames, Emails
  `vorname.nachname@local.dev`.

## Schema-Lockstep
Rust `User`-Struct (`betting-api/src/db/mod.rs`) nutzt firstName/lastName
nicht → keine Rust-Änderung. (Non-blocking: `betting-api/src/db/fixtures.rs`
hat noch first/last_name in einem eigenständigen Test-Schema — kein Drift,
optionaler Cleanup.)

## Quality-Gate
- `pnpm exec tsc --noEmit` → 0; `pnpm exec vitest run` → **91/91** (inkl. neuer
  `user-name.test.ts`); `pnpm build` → ok. Reset-Pipeline gegen Temp-DB
  verifiziert (Shared-DB unberührt).

## Reviewer-Feedback
Reviewer-Agent: **APPROVE**. Migration-Edit konsistent (SQL ↔ Snapshots ↔
schema.ts), Duplicate-Handling sauber, kein `any`, i18n-Parität, Lockstep
bestätigt.
