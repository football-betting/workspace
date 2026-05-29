# FE-021 Result — Auth-Guard: throw durch Redirect ersetzen

**Geschlossen**: 2026-05-29
**Commits**:
- `frontend` (main) `99d13dc FE-021: redirect unauthenticated visitors instead of throwing in protected pages (#24)` (squash-merge von PR #24)

## Was wurde gemacht

In den geschützten Seiten unter `app/(app)/` wurde der harte
`throw new Error("… auth guard failed")` durch `redirect("/login")` ersetzt.
Unauthentifizierte Besuche leiten jetzt sauber auf `/login` um, ohne einen
generischen Server-Error (mit `digest`) zu loggen — im Einklang mit der in
`lib/session.ts` dokumentierten Guard-Konvention.

Scope-Erweiterung: Das Ticket nannte Dashboard + Profil, der identische
Anti-Pattern steckte aber auch in Ranking und Match-Detail. Da AC #4 ein
leeres `grep "auth guard failed"` über den gesamten `app/(app)/`-Baum
verlangt, wurden alle **vier** Seiten gefixt.

## Geänderte Dateien

Alle in `frontend/`:

- `app/(app)/page.tsx` — `redirect`-Import + throw → redirect
- `app/(app)/user/[id]/page.tsx` — `redirect` zum `notFound`-Import, throw → redirect
- `app/(app)/ranking/page.tsx` — `redirect`-Import + throw → redirect
- `app/(app)/match/[id]/page.tsx` — `redirect` zum `notFound`-Import, throw → redirect

## Quality-Gate

- `pnpm exec tsc --noEmit` → exit 0
- `pnpm exec vitest run` → **77/77 passed**
- `grep -rn "auth guard failed" app/` → leer
- Prettier-Hook lief auf allen Edits

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**. Auth-Boundary verifiziert (`redirect()` narrowt
`user` typsicher non-null; kein `try/catch` schluckt das `NEXT_REDIRECT`),
Konvention aus `lib/session.ts` eingehalten, Commit berührt nur die vier
`.tsx`-Dateien.

## Notiz

Im `frontend`-Working-Tree liegen zwei vorab gestagte Bilder
(`public/img/bg1.png`, `bg2.png`), die **nicht** Teil dieses Tickets sind und
bewusst aus dem Commit ausgeschlossen wurden — werden über ein separates
Background-Ticket behandelt.
