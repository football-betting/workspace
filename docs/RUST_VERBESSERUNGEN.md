# Rust-Verbesserungs-Backlog (`betting-api` + `macht-api`)

**Stand**: 2026-05-28, nach Abschluss von BA-001 und MA-001.

Ergänzt `docs/TECH_ARCHITEKTUR.md` um eine priorisierte Liste struktureller
Verbesserungen, die im Quick-Win-Scope (siehe
`docs/specs/2026-05-28-rust-quick-wins-and-updates.md`) bewusst draußen
geblieben sind, weil sie Verhalten ändern oder größeren Refactor brauchen.

**Form**: Befund mit `Datei:Zeile`, Risiko, Empfehlung, Aufwand-Klasse
(S = wenige Stunden, M = ein Tag, L = mehrere Tage). Reihenfolge spiegelt
die Priorität — Owner-Entscheidung steuert, welche Items zuerst zu Tickets
werden.

Die zwei offenen Owner-Fragen (P0) stehen am Ende noch einmal in der
„Offene Fragen"-Sektion zusammen, damit sie nicht im Detail versinken.

---

## P0 — Korrektheit

Verhalten ist heute falsch oder kann jederzeit per Eingabedaten in einen
Panic-Pfad fallen. Müssen entschieden / gefixt werden, bevor weitere
P1+-Tickets bearbeitet werden.

### P0.1 `secret_winner == "ESP"` überschreibt `winner == "ESP"`-Bonus

- **Befund**: `betting-api/src/service/mod.rs:55-66` — erst wird
  `extra_point = 15` gesetzt, wenn `user.winner == "ESP"`; danach wird
  `extra_point = 7` gesetzt, wenn `user.secret_winner == "ESP"`. Der
  zweite Zweig überschreibt den ersten. Effektiv bekommt jeder mit
  `secret_winner == "ESP"` nur 7 Punkte — auch dann, wenn auch
  `winner == "ESP"` zutrifft.
- **Risiko**: Punkteberechnung falsch für jeden User, der beide Tipps
  auf den tatsächlichen Sieger gelegt hat. Der Test in
  `betting-api/src/routes.rs::test_get_user_rating` verifiziert diese
  Überschreibung sogar als „korrekt" — siehe `JohnDoe`
  (`winner=DEU, secret_winner=ESP, extra_point=7`).
- **Empfehlung**: **Owner-Entscheidung nötig.** Drei Varianten:
  1. Bug: `+=` statt `=` (15 + 7 = 22, wenn beide ESP).
  2. Gewollte Überschreibung — dann Logik in Funktion mit Test-Kommentar
     dokumentieren.
  3. `secret_winner` darf nur dann 7 Punkte geben, wenn `winner != "ESP"`
     (else-Zweig).
- **Aufwand**: S — wenige Zeilen Code plus Test-Aktualisierung. Größter
  Aufwand ist die Klärung.

### P0.2 Schema-Drift-Panic im Team-Decode

- **Befund**: `betting-api/src/service/mod.rs:88-89` —
  `serde_json::from_str::<Team>(&game.home_team).unwrap()` setzt
  `Team { name: String, tla: String }` voraus (beide required). `macht-api`
  schreibt aber via `to_string(&single_match.homeTeam)`
  (`macht-api/src/api/match_client.rs:102, 118`), wobei dortige `Team` alle
  Felder als `Option<…>` deklariert
  (`macht-api/src/api/match_client.rs:34-41`). Sobald die externe API
  einen Match ohne `tla` liefert, schreibt `macht-api` `tla: null` in den
  JSON-Blob, und `betting-api` panict beim nächsten `/rating`-Request.
- **Risiko**: Ein einzelnes Match aus dem externen Feed killt alle drei
  Endpoints (`/rating`, `/user/{id}`, `/game/{id}`), bis der Cron-Job
  neu importiert oder der Match manuell gelöscht wird.
- **Empfehlung**: `betting-api`-`Team`-Decode auf `Option<String>` für
  `tla` umstellen und im Response-Mapping mit Fallback (`tla.unwrap_or_default()`
  oder explizites `"?"`). Alternative: in `macht-api` vor dem Schreiben
  validieren und Matches ohne `tla` ablehnen (klarer, aber bricht
  Verträge ggf. silent).
- **Aufwand**: S–M, je nach gewählter Variante.

---

## P1 — Härtung (`.unwrap()` raus aus Produktionspfaden)

Jeder Eintrag verletzt die `CLAUDE.md`-Regel "No `.unwrap()` in Rust
production paths unless preceded by a check that proves it cannot panic".

### P1.1 `macht-api/src/api/match_client.rs` — HTTP-/DB-/Parse-`.unwrap()`-Kette

- **Befund**: `macht-api/src/api/match_client.rs:81-84` (HTTP-Send +
  JSON-Decode), `:91-92` (SQLite Prepare + Exists), `:94`
  (RFC3339-Parse), `:102-126` (DB-Execute + JSON-Encode), `:137`
  (`Connection::open`). 13 `.unwrap()`-Aufrufe insgesamt im Produktivpfad.
- **Risiko**: Ein einzelner externer API-Hiccup (5xx, JSON-Schema-Drift,
  Timeout) killt den Cron-Job ohne Logmeldung. Kein Retry, kein
  Partial-Success — die ersten N Matches landen nicht in der DB, wenn
  Match N+1 schief geht.
- **Empfehlung**: Crate-Error-Type via `thiserror` einführen
  (`enum MachtApiError`). `MatchClient::get_matches` und
  `save_matches_to_sqlite` mit `Result<…, MachtApiError>` umschreiben.
  Pro Match-Schleifen-Iteration: `?` statt `.unwrap()`, Fehler in
  `tracing::warn!` loggen und mit nächstem Match fortfahren.
- **Aufwand**: M.

### P1.2 env-Variablen-Fehler als String

- **Befund**: `macht-api/src/api/match_client.rs:60-62, 70-72, 133-135` —
  `env::var(…)` ergibt im Fehlerfall die String-Konstante
  `"Error loading env variable API_URI"` (bzw. `X_AUTH_TOKEN`,
  `DB_PATH`). Der Code feuert dann diesen String als URL ab oder
  versucht ihn als DB-Pfad zu öffnen.
- **Risiko**: Statt klarer Fehler-Meldung verläuft eine fehlende Env-Var
  in einen 404 von einer Garbage-URL oder einer obskuren SQLite-Meldung.
- **Empfehlung**: Beim Programmstart einmalig `Config::from_env()`
  laden, der `Result<Config, MachtApiError>` liefert. Fehlt eine Var,
  exit non-zero mit Hinweis.
- **Aufwand**: S — kann mit P1.1 in einem Schritt erledigt werden.

### P1.3 `panic!()` für CLI-Fehler

- **Befund**: `macht-api/src/main.rs:18-21` — `Err(f) => { panic!("{}", f.to_string()) }`
  wenn `getopts::parse` ein unbekanntes Flag bekommt.
- **Risiko**: Stack-Trace im Cron-Log statt Usage-Hinweis.
- **Empfehlung**: Wird ohnehin durch MA-002 (`getopts → clap`)
  automatisch behoben — clap macht das selber. Item kann mit
  Schluss von MA-002 als erledigt markiert werden.
- **Aufwand**: S, deckt sich mit MA-002.

### P1.4 `betting-api/src/routes.rs` — `.unwrap()` in jedem Handler

- **Befund**: `betting-api/src/routes.rs:32, 70, 93` —
  `service::get_user_rating(db::get_past_games().unwrap(), db::get_users().unwrap()).unwrap()`
  in allen drei Handlern. Ein DB-Fehler killt den Actix-Worker.
- **Risiko**: 500 ohne Fehler-Body; im Worst Case Worker-Restart-Loop,
  wenn die DB-Datei wegrutscht (z. B. während eines `macht-api`-Schreibens
  auf einem schlechten FS-Snapshot).
- **Empfehlung**: Pro Handler `?`-Operator mit einem zentralen
  Actix-Error-Mapper (`impl ResponseError for BettingApiError`). Liefert
  strukturierte JSON-Fehler mit Status-Code.
- **Aufwand**: M.

---

## P2 — Konfigurierbarkeit

### P2.1 Turnier-Sieger `ESP` hardgecodet

- **Befund**: `betting-api/src/service/mod.rs:57-66` — `"ESP"` zweimal
  hartcodiert als Bedingung für Bonus-Punkte.
- **Risiko**: Vor jedem neuen Turnier muss Source-Code-Änderung +
  Re-Deploy erfolgen. Vergisst man die Änderung, rechnet die App noch
  monatelang mit dem alten Turnier-Sieger weiter.
- **Empfehlung** (Owner-Entscheidung 2026-05-28): genau **ein
  `.env`-Variablen-Eintrag** `TOURNAMENT_WINNER=ESP`, keine Config-Datei,
  keine DB-Tabelle. Fehlt die Var, `extra_point = 0` (kein Bonus, kein
  Crash).
- **Aufwand**: S.

### P2.2 Bind-Adresse `127.0.0.1:8080` hardgecodet

- **Befund**: `betting-api/src/main.rs:16` — `.bind("127.0.0.1:8080")?`
  ohne `PORT`/`BIND_ADDR`-Env-Variable.
- **Risiko**: Kein Reverse-Proxy-Bypass möglich; Container-Deploys
  brauchen Source-Patch.
- **Empfehlung**: `let bind = env::var("BIND_ADDR").unwrap_or("127.0.0.1:8080".into());`
  oder analoge `PORT`-Var wie in `macht-api/.env.dist`.
- **Aufwand**: S.

### P2.3 Scoring-Konstanten hardcodiert

- **Befund**: `betting-api/src/service/mod.rs:43-46` — `WIN_EXACT=4`,
  `WIN_SCORE_DIFF=2`, `WIN_TEAM=1`, plus die `+15` / `+7`
  Extra-Punkte in `:58, 62`.
- **Risiko**: Niedrig — wird selten verstellt. Aber: kein dokumentierter
  Ort, an dem die Regeln nachschlagbar sind außer im Source.
- **Empfehlung**: Erst angehen, wenn ein konkretes Turnier andere Regeln
  fordert. Wenn ja: gleicher `.env`-Ansatz wie P2.1, mit konservativen
  Defaults.
- **Aufwand**: S.

---

## P3 — Performance / DB-Zugriff

### P3.1 N+1 SQLite-Connections pro `/rating`-Request

- **Befund**: `betting-api/src/db/mod.rs:36-51` —
  `establish_connection()` öffnet jedes Mal eine frische
  `Connection::open(database_url)`. Aufrufer:
  - `get_users()` (`:54`), 1×
  - `get_past_games()` (`:103`), 1×
  - `get_tips_by_user(user_id)` (`:78`), **1× pro User** in
    `service::get_user_rating` (siehe `:78-82` in service/mod.rs).
  - → Pro `/rating`-Aufruf: `2 + N_users` `Connection::open`-Calls.
- **Risiko**: Mittel. Bei 7 Usern (Fixtures) 9 File-Opens pro Request,
  bei realistischen Größenordnungen entsprechend linear mit Userzahl.
  SQLite öffnet schnell, aber unter Last + paralleler `macht-api`-Schreibe
  riskiert man `SQLITE_BUSY` ohne Retry.
- **Empfehlung**: `r2d2 = "0.8"` + `r2d2_sqlite = "0.24"`, `Pool` per
  `app_data` an Actix übergeben, Handler bekommen einen Connection-Guard.
  Zusätzlich: `get_user_rating` so umschreiben, dass eine JOIN-Query
  alle Tipps + User auf einmal lädt (statt N×`get_tips_by_user`).
- **Aufwand**: M.

### P3.2 `establish_connection()` lädt `.env` neu pro Aufruf

- **Befund**: `betting-api/src/db/mod.rs:36-37` — `dotenv().ok()` läuft
  in jedem Call. Macht nichts kaputt, aber ist sinnlos.
- **Risiko**: Mikro-Performance, hauptsächlich Code-Geruch.
- **Empfehlung**: Mit P3.1 in einem Schritt — Pool wird beim Start
  einmalig konfiguriert.
- **Aufwand**: S, mit P3.1.

---

## P4 — Code-Struktur

### P4.1 `MatchClient` / `ScoreHelper` als leere Structs mit `impl`

- **Befund**: `macht-api/src/api/match_client.rs:53` —
  `pub struct MatchClient {}` mit nur assoziierten `async fn`s.
  `macht-api/src/service/score_helper.rs:3` — gleiches Muster für
  `pub struct ScoreHelper {}`. Pseudo-OOP-Namespace.
- **Risiko**: Niedrig (Code-Geruch). Lässt aber Mock-Testing schwerer
  als nötig.
- **Empfehlung**: In `match_client` ein echtes `MatchClient { client:
  reqwest::Client, db_path: PathBuf }` mit Konstruktor; spart pro Call
  das Anlegen einer neuen `reqwest::Client`. `ScoreHelper` → freistehende
  `fn set_home_and_away_score(matches: &mut [Match])`.
- **Aufwand**: S.

### P4.2 `macht-api` ohne `lib.rs`

- **Befund**: `macht-api/src/main.rs` ist die einzige Top-Level-Datei;
  Tests müssen via `bin`-Target laufen, kein externes Reuse möglich.
- **Risiko**: Niedrig direkt, aber Tests können nichts aus dem Crate
  importieren, ohne den ganzen `bin`-Build zu ziehen.
- **Empfehlung**: `src/lib.rs` mit `pub mod api; pub mod service;` und
  `src/main.rs` als dünner Bin-Wrapper. Erleichtert P7-Test-Refactor.
- **Aufwand**: S.

### P4.3 Kein zentraler Error-Type

- **Befund**: Beide Crates mischen `SqliteResult<…>`, `Box<dyn Error>`
  und `.unwrap()`-Brücken. `betting-api/src/service/mod.rs:50` —
  `fn get_user_rating(...) -> Result<…, Box<dyn std::error::Error>>`.
- **Risiko**: Schwer zu erweitern, schwer in Actix-`ResponseError` zu
  mappen.
- **Empfehlung**: Pro Crate ein `enum Error` via `thiserror`, ein
  `pub type Result<T> = std::result::Result<T, Error>`. Deckt P1.1 +
  P1.4 ab.
- **Aufwand**: M, deckt sich mit den P1-Items.

---

## P5 — Observability

### P5.1 Kein Logging / Tracing in beiden Crates

- **Befund**: `betting-api` und `macht-api` schreiben `println!` nirgends
  und nutzen kein `tracing`/`log`-Crate. `macht-api` läuft als Cron und
  schweigt sowohl bei Erfolg als auch bei Fehler.
- **Risiko**: Mittel — ein stiller Importer ist gefährlich, weil ein
  Daten-Stillstand erst Tage später auffällt.
- **Empfehlung**: `tracing = "0.1"` + `tracing-subscriber = "0.3"` mit
  JSON-Layer auf stdout (PM2-Logs frisst das problemlos). In
  `betting-api`: `actix-web-tracing`-Layer für Request-Logs. In
  `macht-api`: ein `tracing::info!` pro Match (`id`, `status`) plus
  `error!` für jeden gefangenen Fehler.
- **Aufwand**: S–M.

---

## P6 — Schema / Migrationen

### P6.1 Leeres `betting-api/migrations/`

- **Befund**: Verzeichnis enthält nur eine `.keep`-Datei. Schema lebt
  doppelt: in `frontend/db/schema.ts` (Drizzle, Master) und in
  `betting-api/src/db/fixtures.rs::create_tables` (für `MODE=test`).
- **Risiko**: Schema-Drift zwischen Test-DB und Produktions-DB nicht
  geprüft. Wenn das Frontend eine Spalte umbenennt, fällt das im
  Rust-Test nicht auf.
- **Empfehlung**: Drizzle-Snapshot per CI in `shared/db/schema.sql`
  exportieren; `fixtures.rs` lädt diese Datei statt eigener
  `CREATE TABLE`-Strings. Cross-Repo-Item — eigenes XR-Ticket.
- **Aufwand**: M.

### P6.2 `match.score`-Spalte wird nicht gelesen

- **Befund**: `macht-api/src/api/match_client.rs:106, 122` schreibt
  `score` als kompletten JSON-Blob in die Spalte. `betting-api/src/db/mod.rs::get_past_games`
  (`:102-112`) selektiert die Spalte nicht.
- **Risiko**: Toter Speicher; potenzieller Schema-Drift-Vektor (Spalte
  könnte verschwinden ohne Konsequenz für `betting-api`, aber `macht-api`
  bricht).
- **Empfehlung**: Spalte entweder konsequent nutzen (z. B. für Anzeige
  von Halbzeitstand) oder aus dem Insert-/Update-Statement raus.
  Owner-Entscheidung sinnvoll vor Migration.
- **Aufwand**: S.

---

## P7 — Testing

### P7.1 `macht-api`-Tests gegen echte DB

- **Befund**: `macht-api/src/api/match_client.rs::save_matches_to_sqlite_inserts_new_match`
  (`:148-`) und `…_updates_existing_match` (`:202-`) öffnen die echte
  DB via `env::var("DB_PATH")` und räumen `id = 11111` danach selber auf.
- **Risiko**: Parallel-Test-unsicher, fragil bei DB-Pfad-Drift, kann
  Production-Daten beeinflussen, wenn `DB_PATH` falsch zeigt.
- **Empfehlung**: Fixture-Modul analog `betting-api/src/db/fixtures.rs`
  bauen — In-Memory-SQLite-Connection an die Methoden injecten
  (deckt sich mit P4.1 — `MatchClient` mit konfigurierbarem
  Connection-Provider).
- **Aufwand**: M.

### P7.2 Kein HTTP-Mock für externe API

- **Befund**: `MatchClient::get_matches` (`macht-api/src/api/match_client.rs:55-87`)
  feuert direkt gegen `API_URI`. Es gibt keinen Unit-Test, der den
  HTTP-Pfad gegen einen Mock prüft.
- **Risiko**: Schema-Änderung im externen Feed (z. B. neues
  Pflichtfeld) bemerkt man erst, wenn der Cron live failt.
- **Empfehlung**: `wiremock = "0.6"` als dev-Dependency,
  `MatchClient` mit konfigurierbarer Base-URL bauen (passt mit P4.1).
  Ein Happy-Path-Test plus ein Schema-Drift-Negativ-Test reichen.
- **Aufwand**: M.

---

## Offene Fragen an Owner

Vor weiteren Folge-Tickets sind diese zwei zu entscheiden:

1. **Ist die `secret_winner == "ESP"`-Überschreibung von 15 auf 7
   (`betting-api/src/service/mod.rs:55-66`) ein Bug oder gewollt?**
   Falls Bug: gilt die Erwartung „15 + 7 = 22 bei Doppel-Treffer" oder
   „erster Treffer gewinnt"? Antwort steuert P0.1.
2. **Welche Felder im `Team`-Struct dürfen `null`/`Option` sein, wenn
   `macht-api` einen Match in die DB schreibt?** Speziell `tla`. Hart
   bleiben (Match ablehnen) oder optional decodieren (Frontend-Fallback)?
   Antwort steuert P0.2.

Sobald entschieden, ziehe daraus konkrete Tickets (Prefix `BA-`/`MA-`,
oder `XR-` bei beidseitiger Wirkung).
