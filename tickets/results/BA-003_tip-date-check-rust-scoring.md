# BA-003 Result — Post-Kickoff-Tips im Rust-Scoring ausschließen

**Geschlossen**: 2026-05-31
**Risk**: medium → reviewer-Pass (Schema-Lockstep über 3 Quellen verifiziert, Boundary geprüft, Regressionstest als aussagekräftig bestätigt).

## Was wurde gemacht
Defense-in-depth: Das Read-API zählte bisher jeden gespeicherten Tip, egal wann
er gesetzt wurde — der einzige Schutz lag im Frontend. `get_tips_by_user`
joint jetzt `match` und filtert `WHERE t.date < m.utcDate`, sodass Tips, die
zum/nach Anpfiff geschrieben werden, nie gescort werden (z. B. bei direktem
DB-Schreibzugriff durch einen anderen Akteur).

Spalten-Lockstep bestätigt: `tip` ist snake_case (`user_id, match_id, date,
score_home, score_away`), `match` nutzt `utcDate` — identisch in Drizzle-Schema,
realer `database.db` und Test-Fixtures.

## Geänderte Dateien

### betting-api (PR #3, squash `bbc4c51`)
- `src/db/mod.rs` — `get_tips_by_user`: JOIN auf `match` + `t.date < m.utcDate` + `ORDER BY t.id` (deterministisch); neuer Regressionstest `test_get_tips_by_user_excludes_post_kickoff_tips`
- `src/db/fixtures.rs` — alle legitimen Tip-Dates auf `now - 172800` (strikt vor Anpfiff, da Match 1 `utcDate = now-86400`); ein Post-Kickoff-Tip (user 6, Match 2, `date: now`, exakt 1:1) ergänzt, der ausgeschlossen werden muss

### workspace
- Ticket-Doc-Fehler korrigiert: manuelle Verifikations-`INSERT`s nutzten camelCase-Spalten (`userId, matchId, ...`), die in dieser DB nicht existieren → auf snake_case korrigiert

## Boundary
Regel ist strikt `tip.date < match.utcDate` — ein Tip exakt zum Anpfiff wird
ausgeschlossen (bewusst strenger als das Frontend, das `utcDate < now` prüft).

## Quality-Gate
- `cargo fmt --check` clean; `cargo clippy -- -D warnings` clean
- `cargo test` → **37 passed** (war 36, +1 Regressionstest); Seed-Rangliste unverändert (ToniKroos 20, JohnDoe 11 …)

## Out of scope (wie im Ticket)
- Unique-Index `(user_id, match_id)` — existiert in Prod bereits (`tip_user_match_unique`)
- Keine Schema-/Frontend-/macht-api-Änderungen
