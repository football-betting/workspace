# Tech-Architektur — Football Betting (EM2024)

Übersicht der drei Komponenten unter `football-betting/`:

```
football-betting/
├── em2024-frontend/   # Astro/TypeScript Frontend (Owner der SQLite-DB)
├── betting-api/       # Actix-web REST API (Reader: liefert Rankings/Tipps)
└── macht-api/         # CLI-Importer (Writer: holt Match-Daten von externer API)
```

Die drei Services kommunizieren **nicht via HTTP**, sondern teilen sich eine **gemeinsame SQLite-Datei** (`em2024-frontend/db/database.db`).

```
┌────────────────────┐         ┌────────────────────┐
│  external Football │──HTTP──▶│     macht-api      │
│  API (X-Auth-Token)│         │  (cron / one-shot) │
└────────────────────┘         └─────────┬──────────┘
                                         │ writes match rows
                                         ▼
                              ┌──────────────────────┐
                ┌────reads────│  SQLite database.db  │────reads/writes────┐
                │             │  (tables: user,      │                    │
                │             │   match, tip)        │                    │
                │             └──────────────────────┘                    │
                │                                                         │
                ▼                                                         ▼
       ┌────────────────┐                                       ┌────────────────┐
       │  betting-api   │ ── GET /rating, /user/{id}, /game/{id}│ em2024-frontend│
       │ (Actix-web,    │◀──────────────── HTTP ────────────────│ (Astro, owns   │
       │  port 8080)    │                                       │  DB & writes   │
       └────────────────┘                                       │  user/tip data)│
                                                                └────────────────┘
```

---

## 1) `betting-api/` — Read-API für Rankings

**Crate**: `em2021_api` (Rust, edition 2021)
**Stack**: `actix-web 4.7`, `rusqlite 0.31`, `serde`, `dotenv`, `chrono`
**Tests**: `mockall`, `rstest`, `actix-rt`
**Deployment**: PM2 (`ecosystem.config.json`), Release-Binary `target/release/em2021_api`
**Port**: `127.0.0.1:8080` (hardcoded in `main.rs`)

### Verzeichnisstruktur

```
betting-api/src/
├── main.rs           # HttpServer setup, registriert 4 Routen
├── lib.rs            # pub mod db | service | routes
├── routes.rs         # alle 4 Handler + Integrationstests (#[cfg(test)])
├── db/
│   ├── mod.rs        # Connection, Models (User, Tip, Game), SELECT-Queries
│   └── fixtures.rs   # In-Memory-DB Setup für MODE=test
└── service/
    ├── mod.rs        # Scoring-Logik, get_user_rating(), calculate_positions()
    └── ranking.rs    # *NICHT in lib.rs eingebunden* (Legacy/Dead code; nutzt
                     #   nicht existierendes `service::firebase_connector`)
```

### Endpoints

| Methode | Pfad              | Handler                       | Antwort                                                        |
|---------|-------------------|-------------------------------|----------------------------------------------------------------|
| GET     | `/`               | `status`                      | `{"status":"works"}`                                           |
| GET     | `/rating`         | `rating`                      | `Response { table: { global, departments }, daily_winner }`    |
| GET     | `/user/{user_id}` | `user_by_id`                  | `UserResponse { data: UserRating mit Tipps (sort. nach date) }`|
| GET     | `/game/{game_id}` | `get_past_result_by_game_id`  | `Vec<MatchInfo>` (alle User-Tipps für dieses Spiel)            |

`daily_winner` ist immer `None` — Feld existiert nur im Schema.

### Datenmodell (SQLite — Schema kommt vom Frontend / Fixtures)

- **`user`** — `id, email, first_name, last_name, username, department, winner, secretWinner`
- **`match`** — `id, homeTeam (JSON-String), awayTeam (JSON-String), status, utcDate (unix-ts), homeScore, awayScore`
  - `homeTeam`/`awayTeam` werden als JSON `{name, tla}` gespeichert.
- **`tip`** — `id, user_id, match_id, date, score_home, score_away`

`get_past_games()` filtert per `WHERE homeScore >= 0 AND awayScore >= 0` → nur Spiele mit Ergebnis.

### Scoring-Logik (`service/mod.rs`)

```rust
WIN_EXACT      = 4   // exakte Vorhersage
WIN_SCORE_DIFF = 2   // korrekte Tordifferenz, falsches Ergebnis
WIN_TEAM       = 1   // korrekter Sieger / korrektes Unentschieden
NO_WIN_TEAM    = 0
```

**Extra-Punkte** (hardcoded auf EM2024, `"ESP"` als Sieger):
- `user.winner == "ESP"`      → `+15`
- `user.secret_winner == "ESP"` → `+7` (überschreibt 15!)

**Positionsberechnung** (`calculate_positions`): Stable Tie-Ranking — gleiche `score_sum` ⇒ gleiche Position, danach Sprung (1,1,3,3,5,…).
`clear_tips=true` für Listen-Endpoints (Tipps werden vor Serialisierung geleert).

### Tests / DB-Modi

- `MODE=test` → in-memory SQLite, geladen via `db::fixtures::load_fixtures()` (7 User: 4 Langenfeld, 3 London; 5 Games; 11 Tipps).
- Sonst → `DATABASE_URL` aus `.env`.
- `cargo tarpaulin` für Coverage (codecov integriert).

### Bekannte Stolperfallen

- `src/service/ranking.rs` ist nicht in `service/mod.rs` re-exportiert, importiert `crate::service::firebase_connector` (existiert nicht). → Compile-Error wenn man es einbindet; vermutlich Reste vom Vorgänger-Projekt.
- `daily_winner` in `Response` ist tote API-Surface.
- Bind-Adresse `127.0.0.1:8080` ist hardgecodet (kein `PORT`-Env wie in `macht-api`).
- Fixture-Schema hat `homeTeam he NOT NULL` (Tippfehler — `he` statt Typ; in SQLite egal wg. dynamic typing).

---

## 2) `macht-api/` — CLI-Importer für Match-Daten

**Crate**: `rust-api` (Rust, edition 2021)
**Stack**: `tokio` (full), `reqwest 0.12` (json), `rusqlite 0.31`, `serde`, `dotenv`, `chrono`, `getopts`
**Form**: **Kein Server** — Einmal-Ausführung, gedacht für Cron.

### Verzeichnisstruktur

```
macht-api/src/
├── main.rs                   # tokio main + getopts (--full Flag)
├── api/
│   ├── mod.rs                # re-export
│   └── match_client.rs       # HTTP-Call + SQLite UPSERT
└── service/
    ├── mod.rs                # re-export
    └── score_helper.rs       # ScoreHelper::set_home_and_away_score()
```

### Ablauf

1. CLI-Flags parsen (`-f` / `--full`).
2. `MatchClient::get_matches(date)`
   - Lädt `API_URI` und `X_AUTH_TOKEN` aus `.env`.
   - Daily: `?dateFrom=<heute>&dateTo=<heute>`.
   - Full (`--full`): kein Datums-Filter.
   - Externer Endpoint = football-data.org-kompatible API (Schema mit `matches`, `homeTeam.crest`, `score.fullTime/halfTime/regularTime`, `utcDate` RFC3339).
3. `ScoreHelper::set_home_and_away_score()`
   - Wenn `score.regularTime` vorhanden → das nehmen (Spiele die in regulärer Spielzeit zu Ende waren).
   - Sonst `score.fullTime` (inkl. Verlängerung/Elfmeter).
4. `MatchClient::save_matches_to_sqlite()`
   - Öffnet DB aus `DB_PATH` (default in `.env.dist`: `../em2024-frontend/db/database.db`).
   - Pro Match: `SELECT WHERE id = ?` → UPDATE oder INSERT (manuelles UPSERT).
   - `utcDate` (RFC3339-String) → Unix-Timestamp via `chrono`.
   - `homeTeam`/`awayTeam`/`score` werden via `serde_json::to_string` als JSON-Strings gespeichert.

### Tabellen, die geschrieben werden

Nur **`match`** — selbe Tabelle die `betting-api` liest.
- Felder: `id, homeTeam, awayTeam, status, utcDate, score, homeScore, awayScore`.
- `score` zusätzlich (kompletter `Score` JSON-Blob) — wird von `betting-api` aktuell nicht gelesen.

### Konfiguration

`.env`:
```
PORT=8080                # ungenutzt — kein Server
X_AUTH_TOKEN=...         # football-data.org Auth
API_URI=https://...      # externer Match-Endpoint
DB_PATH=../em2024-frontend/db/database.db
```

Readme-Hinweis: `insert your key.json into the tmp directory` deutet auf alten Firebase-Pfad hin (siehe Dead-Code-Spur unten).

### Bekannte Stolperfallen

- `service::ranking::UserRanking` (in `betting-api/src/service/ranking.rs`) referenziert `crate::service::firebase_connector::Tip` — Hinweis darauf, dass die Vorgänger-Version Tipps via **Firebase Realtime DB** geladen hat (vgl. Readme `key.json`). Jetzt: SQLite direkt.
- Alle Fehlerpfade nutzen `.unwrap()` → ein API-Fehler killt den Job.
- `tla` ist optional im API-Schema, aber `betting-api` erwartet beim Deserialisieren von `homeTeam` ein `Team { name, tla }` ohne `Option`. Konsistent nur, solange Quell-Daten `tla` immer liefern.

---

## 3) Zusammenspiel & Daten-Vertrag

**Wer schreibt was:**

| Tabelle  | Geschrieben von    | Gelesen von   |
|----------|--------------------|---------------|
| `user`   | `em2024-frontend`  | `betting-api` |
| `tip`    | `em2024-frontend`  | `betting-api` |
| `match`  | `macht-api`        | `betting-api` (`em2024-frontend` evtl. auch) |

**Implizite Verträge (wichtig bei Änderungen!)**:

1. `match.homeTeam` / `match.awayTeam` sind **JSON-Strings** mit mind. `{name, tla}`. `betting-api` `serde_json::from_str(...).unwrap()` — schlägt sofort fehl bei Schema-Drift.
2. `match.utcDate` ist ein **Unix-Timestamp (INTEGER)**, nicht der RFC3339-String der externen API. Konvertierung passiert in `macht-api`.
3. Scoring-Konstanten unterscheiden sich zwischen `betting-api/service/mod.rs` (4/2/1) und `betting-api/service/ranking.rs` (3/2/1) — Letzteres ist Dead Code, aber Vorsicht beim Refactor.
4. `ESP` als Turnier-Sieger ist hardgecodet → muss vor nächstem Turnier raus / config-getrieben werden.
5. `betting-api` bindet hart auf `127.0.0.1` — kein Reverse-Proxy-bypass möglich, OK hinter nginx auf gleicher Box (PM2-Setup).

---

## 4) Quick-Start (Dev)

```bash
# 1) Frontend liefert die DB → erst dort `pnpm dev` oder Migration laufen lassen.

# 2) Match-Daten einmal importieren (full)
cd macht-api
cp .env.dist .env  # X_AUTH_TOKEN + API_URI eintragen
cargo run -- --full

# 3) API starten
cd ../betting-api
cp .env.dist .env  # DATABASE_URL=../em2024-frontend/db/database.db
cargo run
# → http://localhost:8080/rating
```

Test-Modus (keine externe DB nötig):
```bash
cd betting-api
MODE=test cargo test   # nutzt in-memory SQLite + Fixtures
```

---

## 5) Hot-Spots für zukünftige Arbeit

- **Turnier-Sieger konfigurierbar machen** (`betting-api/src/service/mod.rs:58-66`).
- **Server-Bind aus `.env`** (`betting-api/src/main.rs:16`).
- **Dead Code aufräumen**: `betting-api/src/service/ranking.rs` löschen oder reaktivieren.
- **Error Handling im Importer**: `.unwrap()` Kette in `macht-api/src/api/match_client.rs` → kein retry, kein partial-success.
- **Schema-Doku**: Es gibt keine Migrations-Dateien (`betting-api/migrations/` enthält nur `.keep`). Schema lebt im Frontend bzw. in `fixtures.rs` — riskant.
- **Daily-Winner-Feature**: `Response.daily_winner` ist vorgesehen, nie befüllt.
