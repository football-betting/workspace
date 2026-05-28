# [FE-014] /api/match/import skip should still apply security headers

## Repo
frontend

## Type
chore

## Risk
low

## Priority
low

## Background
Audit finding M-2 (2026-05-28). `frontend/middleware.ts:43-45`:
```ts
if (request.nextUrl.pathname === "/api/match/import") {
  return NextResponse.next();
}
```
The bare `return` skips both the origin check (correct — server-to-
server endpoint) AND `withSecurityHeaders()` (incorrect). Responses
from this route are JSON and not browser-rendered today, so this is
cosmetic, but consistency is cheap.

## Scope
- Change the skip to:
  ```ts
  if (request.nextUrl.pathname === "/api/match/import") {
    return withSecurityHeaders(NextResponse.next());
  }
  ```

## Acceptance Criteria
- [ ] `curl -si http://localhost:3000/api/match/import` (no key →
      401) shows the five baseline security headers
- [ ] `pnpm test:e2e` still 12/12 green
