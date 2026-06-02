# MA-005 Result — Spiele mit unbestimmten Teams nicht importieren
**Geschlossen**: 2026-06-02 · **Commit**: `macht-api` master `2233809 (#6)`

## Was wurde gemacht
`save_matches_to_sqlite` überspringt ein Match, wenn ein Team **unbestimmt** ist
(kein nicht-leerer `name` UND kein nicht-leeres `tla` bei home oder away) —
neuer Helper `team_determined`. Kein Insert/Update; `skipped`-Zähler.
Feststehende Paarungen importieren wie bisher (inkl. MA-004-Normalisierung für
Teilangaben, z. B. name vorhanden, tla leer → tla "").

**Vereinfacht** (auf User-Wunsch, nicht live): **kein** DB-Cleanup der bereits
importierten 32 Platzhalter — die werden einfach per `pnpm db:reset` (frische DB)
entfernt.

## Tests
- `undetermined_team_match_is_skipped` (unbestimmt → nicht importiert, Nachbar schon).
- `partial_team_fields_normalize_to_non_null_strings` (name vorhanden, tla None → "").
- `sample_match` + Insert/Update-Tests auf feststehende Teams umgestellt.

## Gate
- `cargo clippy -- -D warnings` clean; `cargo test` → 6 passed.

## Hinweis
Bestehende 32 Platzhalter in der laufenden DB: einmal `pnpm db:reset && pnpm db:seed`.
