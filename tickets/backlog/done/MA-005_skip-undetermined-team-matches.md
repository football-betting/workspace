# MA-005 Spiele mit unbestimmten Teams nicht importieren

## Repo
macht-api
## Type
feature
## Risk
low
## Priority
high
> User (2026-06-02): Platzhalter-Paarungen (leere Teams) sollen nicht importiert werden.

## Background
Die externe API liefert K.-o.-Platzhalter mit unbestimmten Teams
(`{"id":null,"name":null,"tla":null,...}` → MA-004 normalisiert zu `""`). Diese
sollen **gar nicht** in die geteilte DB importiert werden (Spielplan zeigt nur
feststehende Paarungen). Aktuell sind bereits 32 solcher Platzhalter drin.

## Scope
- **In scope** (`save_matches_to_sqlite`):
  - Ein Match **überspringen**, wenn ein Team unbestimmt ist (kein nicht-leerer
    `name` UND kein nicht-leeres `tla` für home oder away) — kein Insert/Update.
  - Bereits vorhandene Platzhalter **aufräumen**: beim Überspringen die Zeile per
    `id` löschen (falls vorhanden), damit die 32 Altbestände beim nächsten Lauf
    verschwinden. Fehler dabei loggen + weiter (MA-004-Stil, kein unwrap).
  - Summary-Log zählt übersprungene mit.
- **Out of scope**: Frontend-Filter (User wählte „gar nicht importieren");
  Schema-Änderung.

## Acceptance Criteria
- [ ] Matches mit unbestimmten Teams werden weder eingefügt noch aktualisiert.
- [ ] Vorhandene Platzhalter werden beim Import per id entfernt (Cleanup).
- [ ] Feststehende Paarungen importieren wie bisher.
- [ ] `cargo clippy -- -D warnings` clean; `cargo test` grün (Test für die Skip/Cleanup-Logik).
- [ ] Kein neues `.unwrap()` auf Prod-Pfad.
