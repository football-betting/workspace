# [001] Bootstrap Next.js frontend in `frontend/`

## Repo
frontend

## Type
chore

## Risk
medium

> The DB schema is shared with the live Rust services. Schema drift would
> break `betting-api` and `macht-api`. Treat with care.

## Priority
high

## Status
todo

## Owner
implementer

## Background
The Next.js frontend replaces the archived Astro `em2024-frontend`. Before
any pages can be built, the project needs a clean scaffold with the
correct stack, design tokens, database connection, and auth layer wired up.

Specs are authoritative:
- Behaviour: `docs/FRONTEND_FUNKTIONS_SPEC.md`
- Architecture: `docs/TECH_ARCHITEKTUR.md`
- Implementation notes: `frontend/design/CHANGES.md`
- Design tokens: `frontend/design/DESIGN.md`

## Scope

**In scope:**
- Initialise Next.js 15+ project in `frontend/` with TypeScript (strict)
  and App Router
- Tailwind CSS v4 with the design tokens from `DESIGN.md` ported into the
  `@theme` block in `app/globals.css`
- Fonts via `next/font/google`: Hanken Grotesk (`--font-sans`), JetBrains
  Mono (`--font-mono`); Material Symbols Outlined via `<link>` in `<head>`
- Drizzle ORM with schema copied from `em2024-frontend/db/schemas/schema.ts`
- Lucia v3 auth with `@lucia-auth/adapter-drizzle` + Argon2id (`oslo/password`)
- Middleware with CSRF check (port the `verifyRequestOrigin` pattern from
  `em2024-frontend/src/middleware.ts`)
- `lib/api.ts` helper for calls to the Rust `betting-api` (`process.env.RUST_API_URL`,
  default `http://localhost:8080`)
- `lib/data/departments.ts` constants: DB values `['Langenfeld', 'Mannheim', 'Maintz']`
  + `displayDepartment(dbValue)` helper that maps `'Maintz'` → `'Mainz'` (per spec §8.6 / §1)
- Copy all 24 flag SVGs from `em2024-frontend/public/svg/` →
  `frontend/public/svg/`
- `.env.example` documenting `DATABASE_URL` and `RUST_API_URL`
- `.gitignore` for `node_modules`, `.next`, `.env`, etc.
- `package.json` scripts: `dev`, `build`, `start`, `lint`, `typecheck`

**Out of scope (explicit):**
- Any UI pages (login, signup, dashboard etc. — separate tickets)
- Seed data scripts (will be added in a separate ticket)
- E2E test setup
- CI workflow
- nginx / PM2 configuration
- Repo-level `README.md` content beyond a placeholder

## References

- `frontend/design/DESIGN.md` — design tokens to port into `@theme`
- `frontend/design/CHANGES.md` §Stack versions — exact stack to install
- `em2024-frontend/db/schemas/schema.ts` — DB schema to copy verbatim
- `em2024-frontend/src/lib/auth.ts` — Lucia setup to mirror
- `em2024-frontend/src/middleware.ts` — middleware to mirror (drop the
  `RUST_APPLICATION` magic string, use a proper API key env var instead —
  see `docs/OPEN_QUESTIONS.md`)
- `em2024-frontend/src/core/api.ts` — `fetchApi` helper to copy + harden

## Acceptance Criteria

- [ ] `pnpm install && pnpm dev` runs without errors; Next.js dev server
      listens on `http://localhost:3000`
- [ ] `pnpm build` completes successfully (no type errors, no lint errors)
- [ ] `pnpm exec tsc --noEmit` is clean
- [ ] `app/globals.css` contains `@theme` block with **all** colors from
      `DESIGN.md` and font/spacing/radius tokens
- [ ] `app/layout.tsx` loads Hanken Grotesk and JetBrains Mono via
      `next/font/google` and adds the Material Symbols `<link>` in `<head>`
- [ ] `db/schema.ts` matches `em2024-frontend/db/schemas/schema.ts` 1:1
      (four tables: `user`, `match`, `session`, `tip`)
- [ ] `lib/data/departments.ts` exports `DEPARTMENTS = ['Langenfeld',
      'Mannheim', 'Maintz']` and `displayDepartment(db: string): string`
      that returns `'Mainz'` for `'Maintz'`, otherwise the input unchanged
- [ ] Drizzle migration generated and committed in `db/migrations/`
- [ ] Lucia is initialised in `lib/auth.ts` with the Drizzle adapter,
      `secure` cookie in production, Argon2id ready to use
- [ ] Middleware file at `middleware.ts` (project root for App Router)
      attaches `locals.user` / `locals.session` (or the Next.js equivalent
      via cookies in Server Components)
- [ ] `public/svg/` contains all 24 flag files
- [ ] `lib/api.ts` exports `fetchApi<T>(endpoint, wrappedByKey?)` using
      `process.env.RUST_API_URL`
- [ ] `.env.example` lists every required env var with a placeholder
- [ ] No inlined SVG icons anywhere (Material Symbols only)
- [ ] No `lucide-react`, `@heroicons/react`, `react-icons`,
      `@radix-ui/react-icons`, `next/svg-as-component` patterns

## Verification (manual)

1. `cd frontend && pnpm install && pnpm dev` → server starts, no errors
2. Open `http://localhost:3000` → default Next.js page renders with Hanken
   Grotesk applied to body text
3. Inspect generated HTML — no inline `<svg>` from any icon library
4. `pnpm exec tsc --noEmit` → no output (= clean)
5. `pnpm build` → succeeds
6. `ls frontend/public/svg/ | wc -l` → 24

## Notes

After this ticket is done, the next tickets (002–006) implement the actual
pages. Each page ticket depends on this one.
