# FE-038 Registrierung: in Production nur valantic.com-Emails

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
medium

## Status
todo

## Owner
implementer

## Background
In **Production** soll die Registrierung nur mit einer `valantic.com`-Email
möglich sein — inkl. Subdomains (z. B. `cec.valantic.com`, `pim.valantic.com`).
In Dev/Test bleibt jede Email erlaubt (die Demo-Seed nutzt `…@local.dev`,
darf nicht brechen). Am Registrierungsformular soll ein Hinweis stehen, dass
nur valantic.com-Emails zulässig sind.

## Domain-Regel
Die Email-Domain muss exakt `valantic.com` sein **oder** auf `.valantic.com`
enden (Subdomain). Beispiele gültig: `x@valantic.com`, `x@cec.valantic.com`,
`x@pim.valantic.com`. Ungültig: `x@valantic.com.evil.com`, `x@notvalantic.com`,
`x@gmail.com`.

## Scope
- **In scope**:
  - `lib/validation/auth.ts` (signupSchema): Email-Domain-Check, **nur aktiv
    wenn `process.env.NODE_ENV === "production"`** (Dev/Test: jede Email ok).
    Sichere Prüfung gegen Tricks wie `@valantic.com.evil.com` (Domain endet
    auf `valantic.com` als ganzes Label, nicht nur String-Suffix).
  - Server-Endpoint `app/api/user/route.ts` validiert serverseitig (nicht nur
    Client) — bei Verstoß sauberer Fehler (kein Insert).
  - `app/(auth)/signup/signup-form.tsx`: Hinweis am Email-Feld „Nur
    valantic.com-Email-Adressen" (i18n, de/en, Key-Parität wahren).
- **Out of scope (explicit)**: Whitelist konkreter Subdomains
  (jede `*.valantic.com` ist ok); Email-Verifikation per Link; SSO.

## References
- `frontend/lib/validation/auth.ts` — `signupSchema`
- `frontend/app/api/user/route.ts` — Registrierungs-Endpoint
- `frontend/app/(auth)/signup/signup-form.tsx` — Formular + Hinweis
- `frontend/scripts/demo_data.ts` — Demo-Emails `…@local.dev` (nur Dev,
  darf nicht brechen)

## Acceptance Criteria
- [ ] Production: Signup mit `x@cec.valantic.com` / `x@valantic.com` → ok;
      mit `x@gmail.com` oder `x@valantic.com.evil.com` → abgelehnt, kein Insert.
- [ ] Dev/Test: jede Email erlaubt (Demo-Seed `@local.dev` läuft).
- [ ] Hinweis „nur valantic.com" am Email-Feld (de/en).
- [ ] Server validiert die Domain (nicht nur Client).
- [ ] Tests: Domain-Validierung (gültig/ungültig/Trick-Domain), Unit.
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Verification (manual)
1. Mit `NODE_ENV=production`: Signup `a@gmail.com` → Fehler; `a@cec.valantic.com`
   → ok.
2. Dev: `a@local.dev` → ok.
