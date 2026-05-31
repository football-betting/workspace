# FE-054 Result — Avatar in Dashboard-Mini-Rangliste

**Geschlossen**: 2026-05-31
**Commit**: `frontend` (main) `bef0fbd FE-054: show user avatars in dashboard mini-ranking (#51)` (squash-merge PR #51)

## Was wurde gemacht
`RankingSidebar.RankingRow` rendert die User mit einem fest verdrahteten
`person`-Icon — die `/rating`-Daten (Rust) tragen kein Avatar/Email. Lösung
frontend-only: die Dashboard-RSC reichert die gelisteten User mit Avatar-Pfaden
aus der DB an (`getUserAvatarsByIds`, eine Batch-Query via `inArray`) und reicht
eine `user_id → {avatar,email}`-Map bis `RankingRow` durch, das jetzt die
bestehende `<Avatar>`-Komponente nutzt (Foto → Initialen → Icon-Fallback).

## Geänderte Dateien
- `frontend/lib/user.ts` — `getUserAvatarsByIds` + `UserAvatarInfo`
- `frontend/app/(app)/page.tsx` — Avatar-Map bauen + an beide Sidebar-Instanzen
- `frontend/components/dashboard/RankingSidebar.tsx` — `<Avatar>` statt person-Icon, Map durchgereicht

## Quality-Gate
- `bash scripts/check.sh` → grün (tsc + vitest 127). Self-Review (low-risk: eine
  Batch-Query, kein N+1; leeres Rating → Offline-Branch; Fallback eingebaut).
