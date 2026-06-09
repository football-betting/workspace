# FE-094 Result — FAQ page

## What was done

Added a bilingual (DE/EN) FAQ page for the Tipspiel, reachable from the footer.
The page mirrors the existing `/features` layout and renders 14 questions in 3
sections as a native `<details>/<summary>` accordion (no client JS). Content was
derived from the confirmed game rules and verified against the Rust scoring
source of truth. The frontend spec was synced to reality (password reset is
implemented, new `/faq` route).

### Content (3 sections, 14 questions)

- **Tippen & Regeln / Predicting & Rules** (6): how to predict, deadline (until
  kick-off, editable before), **regular 90 min only — no extra time/penalties in
  the knockout stage**, scoring (5/3/2/0), winner bonus (+12), secret winner
  (+6).
- **Rangliste & Abteilungen / Ranking & Departments** (3): how the ranking
  works, global vs. department (Langenfeld/Mannheim/Mainz), live updates.
- **Konto & Technik / Account & Tech** (5): who can register (valantic email),
  password reset (login → "forgot password" → email link), **reminders require
  enabling a channel (push and/or email) in settings first**, PWA install,
  **language switch (desktop header vs. mobile/PWA settings)**.

Point values verified against `betting-api/src/service/mod.rs`
(`WINNER_BONUS=12`, `SECRET_WINNER_BONUS=6`, scoring 5/3/2/0).

## Files changed

### frontend (branch `fe-094-faq-page`)

- `app/(app)/faq/page.tsx` — new server component, `<details>` accordion
- `lib/faq.ts` — new `FAQ_SECTIONS` config (3 sections, 14 keys), shared by page + test
- `components/Footer.tsx` — `/faq` link added next to `/features` in a `<nav>` group
- `messages/de.json`, `messages/en.json` — new `FAQ` block + `Footer.faqHeading`
- `tests/unit/faq-content.test.ts` — new content test (key coverage, de/en q+a, bonus-value guard)

### workspace (branch `fe-094-faq-page`)

- `docs/FRONTEND_FUNKTIONS_SPEC.md` — spec sync: `/faq` route added (§3);
  password-reset rows updated from "stub" to "implemented" (§3 + legacy §6 marked superseded)
- `docs/specs/2026-06-09-faq-page-design.md` — design document
- `tickets/backlog/done/FE-094_faq-page.md` — ticket (todo → done)
- `tickets/results/FE-094_faq-page.md` — this document

## Test results

- `pnpm exec tsc --noEmit` → clean (exit 0)
- `pnpm exec vitest run tests/unit` → 397 passed (49 files), incl. new
  `faq-content.test.ts` (8) and existing `i18n-messages.test.ts` parity (2)
- Reviewer agent verdict: **PASS**, no blocking issues

## Deployment

Frontend-only runtime change. After the frontend PR is squash-merged to `main`,
on the production server (`/opt/football-betting/frontend`):

```
git pull && pnpm build && pm2 restart wm-frontend
```

No new dependencies, no schema/DB change, no Rust change — `pnpm install` not
required. The workspace PR (docs/ticket) needs no deploy. Verify afterwards:
`https://wm.vcec.cloud/faq` renders, footer "FAQ" link works, language toggle
switches the content.
