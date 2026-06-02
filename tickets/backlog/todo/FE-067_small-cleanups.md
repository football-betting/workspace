# FE-067 Kleine Aufräumarbeiten (toter Code, Redundanz, Avatar-Cache)

## Repo
frontend
## Type
chore
## Risk
low
## Priority
low
> Projekt-Scan 2026-06-02 (Low-Funde).

## Status
todo
## Owner
implementer

## Scope
- **Toter Export** `hasReminderBeenSent` in `lib/reminder-store.ts` entfernen
  (nirgends genutzt; Cron nutzt `getSentKeysForMatches`).
- **Redundantes `clampPerMatchPoints`** in `components/profile/PredictionHistory.tsx`
  (Identität für {0,2,3,5}) — entfernen/vereinfachen, damit es nicht von
  `scoreColor`/`tipCategory` driftet.
- **Avatar-Cache-Busting konsistent**: `?t=` wird nur in der lokalen Vorschau
  (`AvatarUpload.tsx`) angehängt; nach Re-Upload zeigen andere Ansichten
  (RankingSidebar/Profil) ggf. das alte Bild bis Cache-Ablauf. Einheitliche
  Cache-Busting-Strategie (z. B. `?v=<updatedAt>` an allen Avatar-`src`) prüfen.

## Acceptance Criteria
- [ ] Toter Code entfernt; Build/Tests grün.
- [ ] Avatar nach Re-Upload überall aktuell (oder bewusst dokumentierter Kompromiss).
- [ ] Quality Gate: `bash scripts/check.sh`.
