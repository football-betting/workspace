# FE-036 Result — Avatar-Upload

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `a516f1d FE-036: avatar upload (sharp re-encode, IDOR/path-safe, fallback photo->initials->icon) (#44)` (squash-merge von PR #44)

## Was wurde gemacht

- **Schema**: nullable `avatar`-Spalte in `user` (schema.ts + Baseline-Migration
  `0000_*.sql` + `meta/*_snapshot.json` lockstep, keine neue Migration). Rust
  `User`-Struct nutzt `avatar` nicht → keine Rust-Änderung.
- **Upload-Endpoint** `app/api/user/avatar/route.ts` (POST, session-geschützt):
  userId **nur** aus Session (IDOR-safe, Dateiname `{userId}.webp` → kein
  Path-Traversal), Typ-Allowlist png/jpeg/webp (**SVG abgelehnt**),
  Size-Limit 5 MB, **sharp** re-encode (decode `failOn:error`, EXIF-rotate +
  strip, cover-crop 256², → webp) → entfernt eingebettete Payloads, Rate-Limit
  (`"avatar"`-Bucket), saubere JSON-Fehler. Speicherung
  `public/uploads/avatars/` (gitignored).
- **Dependency** `sharp` als direkte Dependency.
- **`components/Avatar.tsx`**: Foto → **Initialen** (aus `displayNameFromEmail`)
  → `person`-Icon; barrierefrei. Auf Profil + Settings eingebunden;
  Settings-Upload-UI ersetzt den FE-032-Platzhalter.

## Quality-Gate
- `bash scripts/check.sh` → tsc 0, vitest **127/127** (inkl. 13 Avatar-Tests);
  `--build` → ok. `pnpm db:reset` gegen Temp-DB → ok (Shared-DB unberührt).

## Reviewer-Feedback
Reviewer-Agent: **APPROVE** (Security-rigoros) — kein Upload-Bypass/Traversal/
IDOR/SVG-XSS, gespeichert wird das re-encodete webp (nie der Rohupload),
path-safe, rate-limited, Schema-Lockstep, kein `any`/`NEXT_PUBLIC_`,
i18n-Parität.

## Out of scope (Folge)
Avatar-Fotos in der Rust-gelieferten Rangliste → bräuchten `avatar` in
`UserRating` (Rust-Änderung) → separates XR-Ticket; Initialen/Icon dort reichen.
