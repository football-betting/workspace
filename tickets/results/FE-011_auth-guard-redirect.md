# FE-011 — Redirect unauthenticated visitors to /login

**Status:** done
**Merged:** 2026-05-28
**PR:** [football-betting/frontend#4](https://github.com/football-betting/frontend/pull/4) (squash → `4b3ad39`)
**Branch:** `feat/fe-011-auth-guard` (deleted post-merge)

## What was done

Installed the **layout-based auth guard** pattern. Every protected page
now lives under the `app/(app)/` route group; the parent layout reads
`getCurrentSession()` once and redirects to `/login` when no user.
Future protected pages (FE-003/004/005/006) just drop a file under
`app/(app)/<route>/page.tsx` and inherit the guard.

## Files changed (19 LOC / 3 files)

### `frontend/` (new)
- `app/(app)/layout.tsx` (15 LOC) — Server Component, three-line guard

### `frontend/` (renamed)
- `app/page.tsx` → `app/(app)/page.tsx` (content byte-identical to
  the FE-001 placeholder; URL stays `/`)

### `frontend/` (modified)
- `lib/session.ts` (+4 LOC) — prose comment documenting the `(app)`
  pattern so FE-003+ implementers reuse it instead of building
  per-page guards

### Untouched (regression-verified by reviewer)
- `app/(auth)/login/page.tsx` and `app/(auth)/signup/page.tsx` —
  existing logged-in→`/` redirect still works

## Quality gates

| Gate | Result |
|---|---|
| `pnpm exec tsc --noEmit` | ✅ clean |
| `pnpm build` | ✅ successful (9/9 static, `/` correctly marked `ƒ` dynamic) |
| `<svg` / `dangerouslySetInnerHTML` / icon-lib greps | ✅ 0 matches each |
| `any` / `as any` / `@ts-ignore` audit | ✅ none |
| `curl -si http://localhost:3000/` | ✅ `307 Temporary Redirect, location: /login` |
| `curl -si http://localhost:3000/login` | ✅ `200 OK` |
| `curl -si http://localhost:3000/signup` | ✅ `200 OK` |

## Reviewer verdict — APPROVE

**Auth-boundary deep check (medium-risk gate):**
- **Leak path 1** (DB call before guard): ✅ — no DB calls in the
  layout; React Server Components guarantee parent-layout `await`
  resolves before child render
- **Leak path 2** (client-side flash): ✅ — zero `"use client"` files
  under `(app)/`; redirect fires server-side before any HTML streams
- **Leak path 3** (session double-read): ✅ — `getCurrentSession` is
  React `cache()`-wrapped, so multiple calls in the same request are
  free and consistent
- **Redirect cookie state**: ✅ — 307 carries no `Set-Cookie`; the
  request stays unauthenticated

## Decisions worth noting

1. **Layout-based, not middleware-based.** Middleware would have
   forced us to maintain a "protected route" allow-list. The `(app)`
   route group encodes the same intent structurally — a file's
   location tells you whether it's guarded.
2. **No prop-drilling of user from layout to pages.** The pages can
   re-call `getCurrentSession()`; React `cache()` makes the second
   call free, and it keeps the prop surface clean for FE-003.
3. **Prose comment, not a separate doc file.** The pattern is one
   layout + three lines — over-documenting is anti-CLAUDE.md.

## Queue impact

Sequence is now:
```
FE-001 ✅ → FE-002 ✅ → FE-011 ✅ → FE-007 → FE-003/004/005/006 → FE-008 → FE-009 → FE-010
```

## Unblocks

- **FE-003** Dashboard — drop `app/(app)/page.tsx` (or
  `app/(app)/dashboard/...`) and the guard runs automatically
- **FE-004** Ranking — `app/(app)/ranking/page.tsx`
- **FE-005** Match detail — `app/(app)/match/[id]/page.tsx`
- **FE-006** Profile — `app/(app)/user/[id]/page.tsx`
