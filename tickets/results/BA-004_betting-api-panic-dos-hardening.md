# BA-004 Result — betting-api Panic-/DoS-Härtung

**Geschlossen**: 2026-06-01
**Commit**: `betting-api` (main) `cb63000 BA-004: harden betting-api against panics from bad data and DB errors (#4)` (PR #4)
**Risk**: high → reviewer-Pass (frischer Kontext): kein erreichbarer Panic mehr, Frontend-`RatingTeamSchema` kompatibel.

## Was wurde gemacht
- `Team` derive `Default` + `#[serde(default, deserialize_with="string_or_default")]`
  (null/missing/falscher Typ → ""), Parse via `unwrap_or_default()` → malformed
  Team-JSON liefert `{"name":"","tla":""}` statt 500-Panic. Felder bleiben `String`
  (Response-Schema unverändert, Frontend-zod ok).
- Handler (`/rating`, `/user/{id}`, `/game/{id}`): `.unwrap()`-Ketten via
  `load_user_ratings() -> Result<_, HttpResponse>` → sauberer 500 bei DB-Fehler
  (z. B. `SQLITE_BUSY`), kein Panic.
- `main.rs`: 16-KiB Body-Limits. (Connection-Pool/Caching als Follow-up notiert.)
- 2 neue Tests (null/missing/invalid Team-JSON → kein Panic).

## Lockstep
- macht-api `Team` ist bereits `Option<String>` → keine Bruchstelle; MA-004 schließt die Quelle.

## Quality-Gate
- `cargo clippy -- -D warnings` clean; `cargo test` → 39 passed.
