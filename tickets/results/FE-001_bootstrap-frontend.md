# FE-001 — Bootstrap Next.js frontend

**Status:** done
**Merged:** 2026-05-28
**PR:** [football-betting/frontend#1](https://github.com/football-betting/frontend/pull/1) (squash → `b6afe03`)
**Branch:** `feat/fe-001-bootstrap` (deleted post-merge)

## What was done

Initial scaffold for the rebuilt Next.js frontend. No UI pages, no
seed data, no tests — pure project skeleton ready for FE-002…FE-010
to build on.

Stack delivered:
- Next.js 15.0.4 (App Router) + TypeScript strict + React 19
- Tailwind v4.3.0 — `@theme` block in `app/globals.css` with all
  DESIGN.md tokens (49 colors + typography + spacing + radii + container)
- Drizzle ORM 0.36.4 + better-sqlite3 12.10.0; schema 1:1 with
  `em2024-frontend` (4 tables: `user`, `match`, `session`, `tip`)
- Lucia v3.2.2 + `@lucia-auth/adapter-drizzle` + `oslo/password`
  (Argon2id available for FE-002 to use)
- Hanken Grotesk + JetBrains Mono via `next/font/google`
- Material Symbols Outlined icon font via single `<link>` in `<head>` —
  no inline SVG, no per-icon React-component libraries

## Files changed

### `frontend/` (new)
- `app/layout.tsx`, `app/page.tsx`, `app/globals.css`
- `db/schema.ts`, `db/migrations/0000_friendly_blue_marvel.sql`,
  `db/migrations/meta/*`
- `lib/auth.ts`, `lib/db.ts`, `lib/api.ts`, `lib/data/departments.ts`
- `middleware.ts` — `verifyRequestOrigin` CSRF check (no
  `RUST_APPLICATION` bypass; FE-008 adds the API-key replacement)
- `scripts/migrate.ts`
- `public/svg/*` — 24 country flag SVGs
- `next.config.ts`, `tsconfig.json`, `drizzle.config.ts`,
  `postcss.config.mjs`, `package.json`, `pnpm-lock.yaml`,
  `pnpm-workspace.yaml`, `.env.example`

### `frontend/design/`
- `CHANGES.md` — companion doc tightening (icon constraint), paired
  with workspace commit `c674c3c`

### `workspace/` (separate commits, pushed earlier)
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §13.3 — explicit icon-constraint
  rules + verification greps
- `tickets/backlog/in-progress/FE-001_bootstrap-frontend.md` →
  later moved through `review/` → `done/`

## Quality gates

| Gate | Result |
|---|---|
| `pnpm exec tsc --noEmit` | ✅ clean, zero output |
| `pnpm build` | ✅ Compiled successfully (4 static pages, 99.9 kB shared JS, middleware 32.4 kB) |
| `pnpm dev` smoke (`curl http://localhost:3000`) | ✅ HTTP 200, fonts + Material Symbols loaded |
| `ls public/svg/ \| wc -l` | ✅ 24 |
| `grep -rn "<svg" app/ lib/` | ✅ 0 matches |
| `grep -rn "dangerouslySetInnerHTML" app/ lib/` | ✅ 0 matches |
| `grep -rn "lucide-react\|@heroicons\|react-icons\|@radix-ui/react-icons\|@tabler/icons-react" --include='*.ts' --include='*.tsx' --include='*.json' .` | ✅ 0 matches |
| `any` / `as any` / `@ts-ignore` audit | ✅ none in source |
| `NEXT_PUBLIC_` on server secrets | ✅ none |

## Decisions worth noting

1. **Lucia adapter type bridge** — `em2024-frontend` schema has
   nullable `session.userId` and `tip.userId`; the `@lucia-auth/adapter-drizzle`
   types expect `notNull`. Schema is authoritative per `CLAUDE.md`
   (Rust services depend on column-name + nullability). Bridged with
   `as unknown as SQLiteSessionTable / SQLiteUserTable` casts in
   `lib/auth.ts` — no `any`, no behaviour change.
2. **Session attachment deferred to FE-002** — App Router idiomatic
   style is `await auth()` in Server Components, not mutating request
   locals from middleware. FE-001 AC explicitly permits this.
3. **pnpm v11 build approval** — `onlyBuiltDependencies` lives in
   `pnpm-workspace.yaml` (v11 ignores it in `package.json`). Fresh
   clones may need `pnpm approve-builds` once. README placeholder OK
   for now; follow-up doc improvement possible.
4. **`getUserAttributes` exposes all user columns** beyond `email`
   (firstName, lastName, username, department, winner, secretWinner)
   so downstream tickets (FE-003 dashboard, FE-006 profile) don't need
   separate DB reads for the logged-in user's basics.
5. **Typography tokens** — Tailwind v4 text utilities take a single
   value, so each typography token from `DESIGN.md` is encoded as
   `--text-<name>` + companion `--line-height-*` / `--letter-spacing-*` /
   `--font-weight-*`. Generates `text-display`, `text-headline-lg`,
   `text-headline-md`, `text-body-lg`, `text-body-sm`, `text-data-mono`,
   `text-label-caps`, `text-headline-lg-mobile` utilities.
6. **`serverExternalPackages`** — `better-sqlite3` declared so Next.js
   doesn't try to webpack the native binding.

## Reviewer verdict

**APPROVE WITH MINOR NOTES** — `Risk: medium` makes external review
recommended (not required) per `CLAUDE.md`. Skipped because the
bootstrap doesn't yet run a live auth flow and the schema is a
verbatim copy (no drift risk yet). FE-009 (Security-Audit) will
cover the full auth boundary once FE-002 ships the live flow.

## Unblocks

- **FE-002** Login/Signup — Lucia + Argon2id + `lib/data/departments.ts`
  ready; teams constants still to add in FE-002.
- **FE-007** Demo-data seed — schema + Drizzle CLI + `DATABASE_URL`
  wiring ready.
- **FE-008** Match-import API — `middleware.ts` + `.env.example` slot
  for `MATCH_IMPORT_API_KEY` already in place.
