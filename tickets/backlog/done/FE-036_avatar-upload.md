# FE-036 Avatar-Upload: Foto skalieren, speichern, Fallback Initialen/Icon

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
Nutzer sollen auf der Settings-Seite (FE-032) ein **Avatar-Foto** hochladen
können. Anzeige-Fallback: kein Foto → **Initialen** aus Vor-/Nachname
(`displayNameFromEmail`), und wenn kein Name ableitbar → das bestehende
`person`-Icon. Speicherung als Datei + serverseitige Skalierung mit **sharp**
(bereits installiert).

## Scope
- **In scope**:
  - Schema: `avatar`-Spalte (Text, nullable, Dateiname/Pfad) in der
    `user`-Tabelle (`db/schema.ts`). DB wird neu erzeugt — **keine Migration**.
    Schema-Lockstep: `betting-api`/`macht-api` `User`-Struct nutzen `avatar`
    nicht → kein Rust-Change (Review bestätigen).
  - Upload-Endpoint (`app/api/user/avatar/route.ts`, session-geschützt,
    userId **nur** aus Session): Bild annehmen → mit **sharp** zu Quadrat
    (z. B. 256×256, cover) skalieren/croppen → unter
    `public/uploads/avatars/<userId>.<ext>` speichern → Pfad in DB.
    Validierung: nur erlaubte Bildtypen (png/jp/webp), Größenlimit (z. B. 5 MB),
    keine Pfad-Traversal (Dateiname aus userId, nicht aus Upload).
  - `.gitignore` für `public/uploads/` (hochgeladene Dateien nicht committen).
  - Anzeige-Komponente `Avatar`: Foto (falls vorhanden) → sonst **Initialen**
    (erste Buchstaben Vor-/Nachname) → sonst `person`-Icon. Auf Profil + Settings
    einsetzen.
  - Demo-Daten: Emails als `vorname.nachname@local.dev` (kommt aus FE-033),
    damit Initialen/Name funktionieren.
- **Out of scope (explicit)**: Crop-UI mit Zoom/Drag (einfacher Center-Crop via
  sharp reicht); Avatar löschen/zurücksetzen (optional, später); externes
  Object-Storage/CDN; **Avatar-Fotos in der Rust-gelieferten Rangliste**
  (bräuchte `avatar` in `UserRating` → separates XR-Ticket; Initialen/Icon in
  der Rangliste sind hier ok).

## References
- `frontend/design/account.html` — Avatar-Bereich (Upload-Button)
- `frontend/db/schema.ts` — `user`-Tabelle
- `sharp` (in `pnpm-workspace.yaml onlyBuiltDependencies`) — Resize
- `frontend/components/dashboard/RankingSidebar.tsx` / `RankingTable.tsx`
  — bisheriges `person`-Icon (Fallback-Vorbild)
- `displayNameFromEmail` (FE-033) — für Initialen

## Acceptance Criteria
- [ ] Upload eines Bildes → quadratisch skaliert unter
      `public/uploads/avatars/<userId>.<ext>`, Pfad in DB, im Profil/Settings
      sichtbar.
- [ ] Nicht-Bild oder zu groß → abgelehnt, kein Schreibvorgang.
- [ ] userId stammt nur aus der Session (kein IDOR); Dateiname aus userId.
- [ ] Kein Foto → Initialen aus Vor-/Nachname; kein Name → `person`-Icon.
- [ ] `public/uploads/` ist gitignored.
- [ ] Tests: `Avatar`-Fallback-Logik (Foto/Initialen/Icon) + Initialen-Helper (Unit).
- [ ] Quality Gate: `pnpm exec tsc --noEmit && pnpm exec vitest run`.

## Dependencies
- **FE-033** (`displayNameFromEmail`, `avatar`-fähiges Schema-Umfeld, Demo-Emails)
- **FE-032** (Settings-Seite hostet den Upload-Button)

## Verification (manual)
1. Settings → Foto hochladen → Avatar erscheint (skaliert) in Profil + Settings.
2. Nutzer ohne Foto → Initialen (z. B. „RP" für rosa.parks); ohne ableitbaren
   Namen → Person-Icon.
3. Datei > Limit / kein Bild → Fehler, nichts gespeichert.
