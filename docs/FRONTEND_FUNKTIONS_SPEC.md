# Frontend-Funktions-Spezifikation (em2024-frontend → Next.js Migration)

Ziel: Funktionale Vorlage für Neuaufbau in **Next.js** mit neuem Design.
Alles unten ist **WAS** das Frontend tut — UI-Klassen / Tailwind-Snippets sind nur als Referenz aufgeführt, **nicht zu übernehmen**.

---

## 0) Aktueller Stack (zur Kenntnis, nicht zum Mitnehmen)

| Schicht       | Heute                                        | Empfehlung für Neubau                   |
| ------------- | -------------------------------------------- | --------------------------------------- |
| Framework     | Astro 4.10 + SSR (`@astrojs/node`)           | Next.js 15 App Router                   |
| Interactivity | Alpine.js + vanilla DOM-scripts              | React Server/Client Components          |
| Styling       | TailwindCSS 3.4 + custom CSS-grid            | TailwindCSS 4 (neues Design-System!)    |
| ORM           | Drizzle ORM + better-sqlite3                 | Drizzle ORM (Postgres oder SQLite egal) |
| Auth          | Lucia v3 + Argon2id (oslo/password)          | Auth.js (NextAuth) **oder** Lucia v3    |
| Externe API   | `fetchApi` zu Rust `betting-api` (port 8080) | gleiche API behalten                    |
| Build/Pkg     | pnpm (Bun nur Dev, Bug mit SQLite3 in prod)  | pnpm                                    |

---

## 1) Datenmodell (Drizzle Schema)

Quelle: `db/schemas/schema.ts`. Vier Tabellen — **identisch übernehmen**, das Rust-Backend hängt davon ab.

```ts
// match — geschrieben von macht-api (Rust), gelesen + ggf. geschrieben vom Frontend
match {
  id         number PK (kein autoincrement — kommt von externer API)
  homeTeam   json   { name, tla, crest? }
  awayTeam   json   { name, tla, crest? }
  status     string ('SCHEDULED' | 'IN_PLAY' | 'FINISHED' | ...)
  utcDate    timestamp (int unix)
  score      json?  // ganzer Score-Blob von football-data.org
  homeScore  int?
  awayScore  int?
}

// user
user {
  id            number PK autoIncrement
  email         string UNIQUE
  password      string (Argon2id-Hash)
  firstName     string
  lastName      string
  username      string  // wird im Ranking gezeigt
  department    string  // 'Mainz' | 'Mannheim' | 'Langenfeld'   (FE-057: 'Maintz'-Tippfehler korrigiert → 'Mainz')
  winner        string  // ISO3-Code z.B. 'DEU', 'ESP'
  secretWinner  string  // ISO3-Code, ≠ winner (im Signup gecheckt)
}

// session — Lucia-Standard
session {
  id        string PK
  userId    int → user.id
  expiresAt int
}

// tip — ein User pro Match exakt 1 Tipp (Upsert via "find existing, else insert")
tip {
  id        number PK autoIncrement
  userId    int → user.id
  matchId   int → match.id
  date      timestamp  // Erstellungs-/Update-Zeit
  scoreHome int
  scoreAway int
}
```

### Wichtige Daten-Verträge

- **`match.homeTeam` / `awayTeam` sind JSON-Objekte** mit mindestens `{name, tla}`. Das Rust-Backend (`betting-api`) deserialisiert das.
- **`tla` ist ISO3 — aber gemischt**: in der DB / im API-JSON erscheinen sowohl FIFA-Codes (`GER`, `NED`, `CRO`, `SUI`) wie auch ISO3 (`DEU`, `NLD`, `HRV`, `CHE`). Im Frontend gibt es eine `countryMapping`-Tabelle in `Flag.astro` zum Übersetzen → muss übernommen werden, sonst gibt's keine Flaggen.
- **`utcDate` ist `int (unix-timestamp)`** in der DB, das Frontend wandelt via `new Date(int * ...)`. Drizzle `mode: 'timestamp'` macht das automatisch.
- **`department`-Tippfehler `'Maintz'`** wurde korrigiert (FE-057): Wert ist jetzt `'Mainz'` (Seed + `DEPARTMENTS`), das Anzeige-Mapping (`displayDepartment`) ist Pass-through. Laufende DB dafür neu seeden.

---

## 2) Externe Abhängigkeiten (Routes IN ⇄ OUT)

```
            ┌────────────────┐
            │  Browser       │
            └───────┬────────┘
                    │ HTML / form-POSTs / fetch
                    ▼
        ┌───────────────────────────┐
        │     Next.js Frontend      │
        │  (Auth, Forms, Pages)     │
        └───┬─────────────────┬─────┘
            │ direct DB       │ HTTP GET /rating, /user/{id}, /game/{id}
            ▼                 ▼
       ┌────────┐      ┌──────────────────┐
       │ SQLite │      │ betting-api      │  (Rust, port 8080)
       │ db.db  │      │ liest dieselbe DB│
       └────────┘      └──────────────────┘
```

`ENV API_URL` = `http://localhost:8080` (Dev). In Prod hinter Reverse-Proxy.

**Wichtige Erkenntnis**: Das Frontend schreibt direkt in `match`, `user`, `tip`, `session` — aber **liest Rankings (positionen, Punkte) ausschließlich aus dem Rust-Service**. Grund: die Ranking-/Scoring-Logik lebt in Rust. Diese Trennung **beibehalten** beim Neubau.

---

## 3) Seiten / Routen — komplette Liste

| Pfad                        | Auth | Layout       | Aufgabe                                                                                                                                                                                                                                                            |
| --------------------------- | ---- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/`                         | ✅   | LogginLayout | **Dashboard**: Mini-Ranking (`ShortTable`) + Spielplan zukünftig (sortiert `utcDate ASC`, gruppiert nach Datum) + Live-Matches mit aktuellen Punkten + Tipp-Formulare pro Spiel.                                                                                   |
| `/login`                    | ❌   | Layout       | E-Mail/Passwort-Form → POST `/api/auth/login`. Bei `?registered=true` Success-Banner. Eingeloggte → redirect `/`.                                                                                                                                                  |
| `/signup`                   | ❌   | Layout       | Registrierung: email, password, rePassword (Client-Side-Check), firstName, lastName, username, department (Select), winner + secretWinner (Selects mit 24 EM-Teams). POST `/api/user`. Eingeloggte → redirect `/`.                                                 |
| `/password-forget`          | ❌   | Layout       | ~~Stub~~ → **implementiert** (Next.js): ersetzt durch `/forgot-password` (E-Mail-Eingabe) + `/reset-password?token=…` (neues Passwort). E-Mail-basierter Token-Flow, siehe `app/api/auth/forgot-password` / `reset-password`.                                      |
| `/faq`                      | ✅   | LogginLayout | FE-094: statische FAQ-Seite zum Tipspiel (Tippen/Wertung, Rangliste, Konto/Technik), zweisprachig DE/EN, Inhalte als `<details>`-Accordion. Layout wie `/features`.                                                                                                |
| `/table`                    | ✅   | LogginLayout | Volle Ranking-Tabelle mit 4 Tabs: **Global / Langenfeld / Mannheim / Mainz** (`Maintz` in DB). Daten von Rust `GET /rating`. Spalten: Position, Username, RE, T, S, EP, P. Aktuelle Zeile = gelb hervorgehoben.                                                    |
| `/user/[id]`                | ✅   | LogginLayout | User-Profil: Name, Standort, Platz, Punkte, RE, T, S, EP, Flag-Tipps (winner + secretWinner). + Liste der Tipps des Users mit Spielergebnis und erzieltem Punkt. **Tipps kommen vom Rust-API bereits sortiert nach `date DESC`** (Rust `routes.rs:76`).            |
| `/match/[id]`               | ✅   | LogginLayout | Match-Detail: Spielinfo (Teams, Score oder LIVE-Badge, Datum/Zeit). Tabelle mit allen Tipps **aller User** für dieses Match. **Client-side sortiert nach `score DESC`** (`pages/match/[id].astro:23`: `data.sort((a,b)=>b.score-a.score)`). Aktueller User = gelb. |
| `/api/auth/login`           | -    | POST         | Login-Handler (siehe §5.1)                                                                                                                                                                                                                                         |
| `/api/auth/logout`          | -    | GET          | Logout-Handler                                                                                                                                                                                                                                                     |
| `/api/auth/password-forget` | -    | POST         | ~~stub~~ → **implementiert** (Next.js): `app/api/auth/forgot-password` (Reset-Token + E-Mail, rate-limited) und `app/api/auth/reset-password` (Token einlösen). Legacy-302-auf-`/admin/login` entfällt.                                                            |
| `/api/user`                 | -    | POST         | Signup-Handler (siehe §5.2)                                                                                                                                                                                                                                        |
| `/api/tip/[matchId]`        | ✅   | POST         | Tipp speichern/aktualisieren (siehe §5.3)                                                                                                                                                                                                                          |
| ~~`/api/match/import`~~     | —    | —            | Entfernt in FE-019. `macht-api` schreibt direkt in SQLite.                                                                                                                                                                                                         |

---

## 4) Auth & Sessions

### 4.1 Library

**Lucia v3** mit `@lucia-auth/adapter-drizzle`. Session-Cookie heißt wie von Lucia generiert. `Astro.locals.user` enthält **`id` + `email`** — via `getUserAttributes` (`src/lib/auth.ts:16-20`) wird `email` aus der DB-Row in das User-Objekt exposed. Im Code wird aktuell nur `.id` verwendet, aber `email` ist für Neubau im Type verfügbar.

### 4.2 Password-Hashing

**Argon2id** über `oslo/password`. Nicht bcrypt — Argon2 (RFC 9106) ist Standard.

```ts
password = await new Argon2id().hash(plainPassword);
const ok = await new Argon2id().verify(hash, plainPassword);
```

### 4.3 Middleware (`src/middleware.ts`)

Läuft bei **jedem Request**:

1. CSRF-Schutz: Für alle Non-GET-Requests wird `Origin` gegen `Host` geprüft via `verifyRequestOrigin(originHeader, [hostHeader])`. (Die historische `Origin: RUST_APPLICATION`-Ausnahme für `/api/match/import` ist mit FE-019 weggefallen — der Endpoint existiert nicht mehr.)
2. Session-Cookie lesen → `lucia.validateSession()` → wenn `session.fresh` neue Cookie setzen, sonst leere Cookie.
3. `context.locals.user` und `context.locals.session` setzen (oder beide `null`).

**Sicherheit-Findings für Neubau**:

- `Origin: RUST_APPLICATION` ist ein magic-string-Bypass, kein echter Schutz. Im Neuaufbau: dedizierten **API-Key/Bearer-Token** im Header oder mTLS/internes Netzwerk.
- Routes nutzen `context.locals.user` direkt im Astro-Frontmatter; Next.js Equivalent: `auth()` in Server Components / Route Handlers.

### 4.4 Page-Guard-Pattern

Jede geschützte Seite hat oben:

```ts
const user = Astro.locals.user;
if (!user) return Astro.redirect("/login");
```

In Next.js: zentraler Middleware-Guard oder `auth()`-Check in Server Components.

---

## 5) API-Handler im Detail

### 5.1 `POST /api/auth/login` (`pages/api/auth/login.ts`)

Input: form-data `email`, `password`.
Validierung:

- `email` typeof string && length ≥ 3 (sehr lax)
- `password` typeof string && length 4..255

Flow:

1. `getUserByEmail(email)` — wenn nicht da: 400 `"E-Mail ist bei uns nicht registriert."`
2. `Argon2id().verify(user.password, password)` — bei false: 400 `"Falsche E-Mail oder falsches Passwort."`
3. `lucia.createSession(user.id.toString(), {})` + `createSessionCookie()` → Cookie setzen
4. **Redirect 302 → `/`** (Browser folgt; im Client-Script wird `response.redirected` geprüft)

⚠️ **Information disclosure**: Unterschiedliche Fehlermeldungen verraten ob E-Mail existiert. Im Neuaufbau einheitliche Message `"E-Mail oder Passwort falsch."`

### 5.2 `POST /api/user` (`pages/api/user/index.ts`) — Signup

Input: `email, password, firstName, lastName, username, department, winner, secretWinner`.

Validierung:

- Alle Felder Required → bei missing: 400 mit Liste
- `getUserByEmail(email)` — wenn vorhanden: 400 `"User <email> already exists"`
- `winner === secretWinner` → 400 `"Winner and secret winner cannot be the same team."`

Flow:

1. `password = await Argon2id().hash(password)`
2. `createUser({...})`
3. Redirect 302 → `/login?registered=true`

**Fehlt für Production-Neubau:**

- E-Mail-Format-Validierung (echte Regex/Zod)
- Passwort-Komplexitäts-Regel
- Rate-Limit
- `username` Unique-Check (im aktuellen Schema NICHT unique — Duplikate möglich!)

### 5.3 `POST /api/tip/[matchId]`

Input: form-data `tip1`, `tip2`. Cookie-Session.

Validierung-Reihenfolge:

1. `session && session.userId` → sonst 401 `"user is not logged in"`
2. `userId` numerisch — sonst 401 `"UserId not found"`
3. `matchId` numerisch — sonst 401 `"MatchId not found"`
4. `match` existiert in DB — sonst 401 `"Match not found"`
5. **Tippen nur erlaubt wenn ALLE drei Bedingungen erfüllt**: `matchDate >= now` UND `homeScore === null` UND `awayScore === null`. Sobald eine davon kippt → 401 `"For games in the past you can not type"`. Code (`pages/api/tip/[matchId].ts:60`):
   `if (matchDate < now || match.homeScore !== null || match.awayScore !== null) → 401`
6. `tip1`, `tip2` → parseInt; jeweils im Bereich `0..20`. Beide Fehler werden gesammelt.

Flow:

- `saveTip(userId, matchId, tip1, tip2)`:
  - Wenn Tipp existiert → UPDATE (`scoreHome`, `scoreAway`, `date = now`)
  - Sonst → INSERT
- Antwort: `{ success: true, tip: <userTip> }`

⚠️ HTTP-Codes inkonsistent: validation-fail = 401 statt 400. Im Neubau richtig setzen.

### 5.4 `POST /api/match/import` — **entfernt in FE-019 (2026-05-28)**

Der Endpoint ist im Neubau nicht mehr enthalten. `macht-api` schreibt
weiterhin direkt in SQLite via `rusqlite`. Demo-Daten kommen aus
`scripts/demo_data.ts` über `pnpm db:seed` (FE-007).

### 5.5 `GET /api/auth/logout`

- 401 wenn keine Session
- `lucia.invalidateSession()` + leere Cookie setzen
- Redirect → `/login`

⚠️ Logout via GET ist CSRF-anfällig. Im Neubau: POST.

---

## 6) Bekannte Bugs / Halb-Implementierungen

| Fundstelle                          | Problem                                                                                                                                                                                                       |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- | ---------------- | --- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `pages/api/auth/password-forget.ts` | _(Legacy-Astro)_ Body komplett auskommentiert, Redirect-URL `/admin/login`. **Abgelöst:** in Next.js implementiert als `app/api/auth/forgot-password` + `reset-password` (siehe §3).                          |
| `pages/password-forget.astro`       | _(Legacy-Astro)_ Form sendet zu obigem Stub. **Abgelöst** durch `/forgot-password` + `/reset-password` (siehe §3).                                                                                            |
| `pages/login.astro:46`              | _(Legacy-Astro)_ "Passwort vergessen?" Link auskommentiert. **Abgelöst:** in Next.js aktiv verlinkt.                                                                                                          |
| `lib/api.ts:8`                      | `findIndex` gibt -1 wenn User nicht in `slice(3)` ist; Logik nimmt dann `topThree = slice(0,6)`. OK aber wenig elegant.                                                                                       |
| `pages/index.astro:23`              | `sort((a,b) => new Date(a.utcDate) - new Date(b.utcDate))` — TypeScript-mässig dürfte das nicht funktionieren (Date-Sub), läuft aber dank JS-Coercion.                                                        |
| `pages/api/tip/[matchId].ts:60`     | (kein Bug, nur dokumentiert): Tippen nach Match-Anpfiff ist **bewusst** blockiert — Bedingung `matchDate < now                                                                                                |     | homeScore!==null |     | awayScore!==null`. Datumsbasiert allein, ein verspätet importiertes Match kann nach Anpfiff nicht mehr getippt werden — was richtig ist. |
| `pages/api/user/index.ts:33`        | `Missing required fields: ${joined}s` — `s` als String-Konkatenation an joined-Liste (siehe §14.6). Bei einem fehlenden Feld liest sich's komisch (`emails`, `passwords`).                                    |
| `scripts/demo_data.ts:110`          | `new Date(now.setMonth(now.getMonth() + 1))` mutiert `now` für nachfolgende Berechnungen. Match 5 ist letzter Eintrag, daher aktuell harmlos — aber Anti-Pattern.                                             |
| `pages/api/user/index.ts:59`        | `new Argon2id()` ohne Konfiguration → nimmt oslo-Defaults. Für Production sollten `memorySize`, `iterations`, `tagLength`, `parallelism` explizit gesetzt werden (OWASP-Empfehlung 19MiB / t=2 für Argon2id). |
| `db/schemas/schema.ts` & UI         | `department='Maintz'` (Tippfehler). Frontend mapped bei Anzeige.                                                                                                                                              |
| `interfaces/match.ts`               | `Team.crest` ist required, in DB optional → potenzieller Crash, aber im UI nur `tla`/`name` genutzt.                                                                                                          |
| `layouts/LogginLayout.astro:43`     | Hardcoded Department-Tabs (`Global / Langenfeld / Mannheim / Mainz`) — nicht datengetrieben.                                                                                                                  |

---

## 7) UI-Elemente / Komponenten (was sie tun, NICHT wie sie aussehen)

| Komponente                    | Funktion                                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Layout`                      | Public-Layout (Logo header, kein Nav).                                                                                                                                                                                                                                                                                                                                                   |
| `LogginLayout`                | Eingeloggt-Layout: Logo + Nav (Dashboard / Tabelle / Mein Konto / Abmelden), aktiver Link unterstrichen.                                                                                                                                                                                                                                                                                 |
| `Logo`                        | Statisches Logo: "Euro '24" + "a valantic guessing game".                                                                                                                                                                                                                                                                                                                                |
| `ShortTable`                  | Mini-Ranking auf Dashboard mit Tabs Global/Langenfeld/Mannheim/Mainz. **Slicing-Regel** (`lib/api.ts`): wenn User ab Platz 5 (`global.slice(3)` findIndex > 0): zeige Top 3 + 3 Nachbarn (User-1, User, User+1). Sonst (User in Top 3, User auf Platz 4, oder User nicht gefunden): zeige Top 6 statt Top 3. Department-Tabs zeigen **immer komplette Department-Liste** (kein Slicing). |
| `Flag`                        | SVG-Flagge aus `/svg/<TLA>.svg`. Erfordert ISO3→FIFA-Mapping (DEU→GER, NLD→NED, HRV→CRO, …).                                                                                                                                                                                                                                                                                             |
| `Input`                       | Stylisches Input mit Label.                                                                                                                                                                                                                                                                                                                                                              |
| `Button` / `ButtonLink`       | Submit-Button / Link-as-Button.                                                                                                                                                                                                                                                                                                                                                          |
| `ErrorAlert` / `SuccessAlert` | Alert-Boxen (rot/grün). Im aktuellen Code kaum benutzt — Inline-Fehler dominieren.                                                                                                                                                                                                                                                                                                       |
| `Icon`                        | Lazy-load von SVG aus `src/icon/` via Vite raw-import.                                                                                                                                                                                                                                                                                                                                   |

---

## 8) Geschäftslogik im Detail

### 8.1 Tipp-Abgabe Lebenszyklus

```
User öffnet Dashboard
   └─ Frontend lädt: getFutureMatch() → alle Spiele mit utcDate > NOW
       └─ filtert: homeTeam.name && awayTeam.name vorhanden
       └─ holt User-Tipps zu diesen MatchIDs (eine Query)
   └─ Für jedes Spiel:
       ├─ Wenn User schon Tipp hat → Anzeige-Modus (Klick öffnet Edit)
       └─ Sonst → Form mit zwei <input type="number" min=0 max=20>
   └─ Submit (async fetch, kein Reload):
       └─ POST /api/tip/{matchId} mit tip1, tip2
       └─ Server validiert & upsert
       └─ Antwort enthält neuen Tip → DOM-Update inline
```

### 8.2 Match-Daten Lebenszyklus

```
macht-api (Rust, cron) ──► externe API ──► SQLite match-Tabelle
                                              │
                                              ▼
                          ┌─────────────────────────────────┐
                          │ Frontend liest match direkt     │
                          │ (getFutureMatch, getLiveMatch)  │
                          └─────────────────────────────────┘
                                              │
                                              ▼
                          ┌─────────────────────────────────┐
                          │ betting-api liest match + tip   │
                          │ + user → berechnet Rankings     │
                          └─────────────────────────────────┘
                                              │
                                              ▼
                          Frontend GET /rating, /user/{id}, /game/{id}
```

### 8.3 Live-Match-Punkte auf Dashboard

- `getLiveMatch()` (DB-direkt) → alle Matches mit `status='IN_PLAY'`
- Anschließend: `fetchApi('user/{id}')` (Rust-API) → User-Objekt mit `tips[]` (jeder Tip enthält bereits berechneten `score`)
- Filter Tips wo `match_id ∈ liveMatchIds` → zeigt User seine aktuellen Punkte (5 grün, 3 gelb, 0 rot, sonst neutral) **live**.

### 8.4 Punkte-Farben (überall konsistent)

- **5 Punkte (exakt)** → grün (`text-green-500`)
- **3 Punkte (Tordifferenz, kein Unentschieden)** → gelb (`text-yellow-300`)
- **2 Punkte (Siegrichtung / korrektes Unentschieden)** → kein speziell genannt — fällt in den "neutralen" Fall
- **0 Punkte** → rot (`text-red-500`)

Im Neubau in `lib/scoring.ts` zentralisieren:

```ts
export const scoreColor = (n: number) =>
  n === 5 ? "success" : n === 3 ? "warning" : n === 0 ? "danger" : "muted";
```

### 8.5 Username-Truncation

`abbreviateUsername(name)` — wenn `length > 17`, auf 14 Zeichen + `…`. Überall im Ranking verwendet.

### 8.6 Department-Liste

Aktuell hardgecodet:

- `Langenfeld` (im Signup-Select: `"Langenfeld / Siegen"`)
- `Mannheim`
- `Maintz` (UI-Anzeige `Mainz`)

→ Im Neubau **in eine Konstante/DB-Tabelle** ziehen, damit datengetrieben.

### 8.7 EM-Team-Liste (Signup-Selects)

24 Teams als ISO3-Codes — siehe `signup.astro` Zeile 56–80. **Nicht-EM-Turnier-spezifisch** behalten: Teams als Datenstruktur / Enum / DB-Tabelle definieren statt zweimal hartcodiert. Wichtig: `winner !== secretWinner` Server-Side erzwingen (passiert bereits).

---

## 9) Vorgeschlagene Next.js-Struktur

```
app/
  (auth)/
    login/page.tsx
    signup/page.tsx
    password-forget/page.tsx           # nur wenn neu implementiert
  (app)/                                # geschützt via Middleware
    layout.tsx                          # Nav (was LogginLayout heute macht)
    page.tsx                            # Dashboard (= heute /)
    table/page.tsx
    user/[id]/page.tsx
    match/[id]/page.tsx
  api/
    auth/
      login/route.ts
      logout/route.ts
    user/route.ts                       # POST = signup
    tip/[matchId]/route.ts              # POST
    match/import/route.ts               # POST (Rust-Hook)
  layout.tsx                            # Root-Layout
lib/
  auth.ts                               # Lucia (oder Auth.js) Setup
  db.ts                                 # drizzle client
  scoring.ts                            # scoreColor() etc
  rust-api.ts                           # fetchApi() neu
  teams.ts                              # EM-Teams Konstanten
  departments.ts                        # Department Konstanten
  match.ts / tip.ts / user.ts           # data-access-funktionen (unverändert)
db/
  schema.ts                             # 1:1 wie heute
middleware.ts                           # auth-guard + CSRF
components/
  ...                                   # neues Design — Inhalt der Komponenten aus diesem Doc
```

---

## 10) Migrations-Checkliste

- [ ] Drizzle-Schema 1:1 übernehmen (oder Postgres-Migration mit `homeTeam jsonb`)
- [ ] `match.utcDate` als `timestamp` mit Drizzle `mode: 'timestamp'`
- [ ] Lucia v3 oder Auth.js mit Argon2id (oslo/password)
- [ ] Middleware mit CSRF-Check, geschützte Routen redirecten auf `/login`
- [ ] Rust `betting-api` Endpoint bleibt unverändert ansprechbar (`/rating`, `/user/{id}`, `/game/{id}`)
- [ ] **API-Key statt magic-string** für `/api/match/import` (Rust-Hook)
- [ ] EM-Teams + Departments als Konstanten/JSON (nicht in JSX hardcoden)
- [ ] Flag-Mapping (DEU→GER etc.) in `lib/flags.ts`
- [ ] Scoring-Farben in `lib/scoring.ts`
- [ ] `username` UNIQUE-Constraint hinzufügen (heute nicht!)
- [ ] Login: einheitliche Fehlermeldung (kein Email-Existenz-Leak)
- [ ] Logout zu POST + CSRF-Token
- [ ] Password-Forget richtig implementieren oder UI entfernen
- [ ] `department='Maintz'`-Tippfehler in Migration korrigieren ODER Mapping behalten
- [ ] Playwright-Tests aus `tests/acceptance/` als Vorlage für neue E2E

---

## 11) Datenfluss-Diagramme zur Übernahme

### Login + Tipp-Abgabe

```
[Browser]  ──POST /api/auth/login──►  [Server]
                                         ├─ getUserByEmail
                                         ├─ Argon2.verify
                                         ├─ lucia.createSession → Cookie
                                         └─ 302 /
[Browser /]  ──GET──►  [Server]
                          ├─ middleware → locals.user
                          ├─ getFutureMatch (Drizzle)
                          ├─ getTipByUserAndMatchIds (Drizzle)
                          ├─ getLiveMatch (Drizzle)
                          └─ fetchApi /user/{id} (Rust)   ← Live-Punkte
                          → HTML mit Tipp-Forms
[Browser]  ──POST /api/tip/{matchId} {tip1, tip2}──►  [Server]
                                                          ├─ validate session+match+range
                                                          └─ tip upsert
                                                          → { success, tip }
```

### Rendering der Ranking-Tabelle

```
GET /table  ──►  fetchApi('rating')  ──►  Rust betting-api
                                              ├─ aggregiert user + tip + match
                                              └─ JSON { table: { global, departments } }
                                          → Tabs Global / Langenfeld / Mannheim / Mainz
```

---

## 12) Infrastruktur / Deployment

### 12.1 Process Manager (`ecosystem.config.json`)

- **PM2** mit `node ./dist/server/entry.mjs` (Astro Standalone-Build).
- Port **4322** (nicht 3000/8080).
- `autorestart: true`, `restart_delay: 5000ms`, `max_memory_restart: 500M`.
- Logs in `/var/log/em2024-frontend-pm2.log` + `-error-pm2.log`.

Für Next.js-Neubau: `next start -p 4322` analog (oder Vercel/Docker).

### 12.2 Reverse-Proxy (`.github/server/nginx/site-available`)

- Domain `em2024.vcec.cloud`, **HTTPS via Let's Encrypt**, HTTP→HTTPS 301-Redirect.
- `proxy_pass http://[::1]:4322` mit Standard-Forwarding-Headern (`X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`, `Host`).
- **WebSocket-Support aktiv** (`Upgrade` / `Connection`) — vermutlich für Astro HMR im Dev-Modus (im Prod ungenutzt). Bei Next.js: gleich behalten falls Realtime/HMR-Tunnel gewollt.
- **Statisches Caching**: `/public/svg/` + `/favicon.svg` direkt vom Filesystem mit `expires 24h; Cache-Control: public`.
- **gzip** für JSON/CSS/JS/XML/HTML mit `gzip_min_length 1000`.

→ Im Neubau: SVGs unter `public/svg/` lassen, Next.js liefert sie eh statisch. nginx-Snippet kann fast 1:1 übernommen werden (nur upstream-Port ändert sich nicht).

### 12.3 CI/CD (`.github/workflows/main.yml`)

- Trigger: push + pr auf `main`.
- **Node 21** + pnpm.
- **Timezone Europe/Berlin** wird explizit gesetzt — wichtig wegen `formatDate('de-DE')` und Zeitstempel-Tests.
- Steps: `pnpm install` → `pnpm run init-demo-data` → `pnpm exec vitest`.
- **Playwright-Steps sind auskommentiert** (Zeile 38–55). E2E-Tests laufen in CI nicht.

→ Neubau: Playwright reaktivieren oder durch Vitest+Testing-Library-Komponententests ersetzen.

### 12.4 `.gitignore` — was NICHT versioniert ist

```
dist/
.astro/
node_modules/
.env, .env.production
playwright-report/, test-results/, coverage/
migrations/         ⚠️ Drizzle-Migrations werden nicht eingecheckt!
db/database.db      ⚠️ DB-File nicht im Repo
```

**Konsequenz**: `pnpm run init` muss bei jedem fresh-clone Migrations neu generieren. Im Neubau: **Migrations einchecken** (Standard-Best-Practice), `init` macht nur `migrate`.

---

## 13) Theme / Typografie (Neubau)

> **Quelle der Wahrheit für Design-Tokens:** `frontend/design/DESIGN.md`.
> Dieser Abschnitt fasst nur die Schrift-Wahl zusammen — alles andere
> (Farben, Spacing, Radii, Komponenten) wird beim Bootstrap (FE-001) aus
> `DESIGN.md` ins Tailwind-v4 `@theme`-Block portiert.

### 13.1 Tailwind v4 `@theme`

Die alten v3-spezifischen Config-Felder (`tailwind.config.mjs`) entfallen.
Tokens werden in `app/globals.css` via `@theme` deklariert. Der Pflicht-Stack:

- `--font-sans: 'Hanken Grotesk'` (Body, UI, Headlines)
- `--font-mono: 'JetBrains Mono'` (Tabellen-Zahlen, Score-Anzeige, Match-Zeiten)

Beide Fonts via `next/font/google` — keine TTF-Dateien mehr im Repo,
keine `@font-face`-Blöcke in `globals.css`.

### 13.2 Schriftverwendung

- **Hanken Grotesk** Regular/SemiBold/Bold/ExtraBold → Body + UI + alle
  Headlines (`display`, `headline-lg`, `headline-md`, `body-lg`, `body-sm`).
- **JetBrains Mono** → Score-Zahlen, Punkte-Werte, Match-Minute, Kick-off-Zeit,
  Ranking-Tabellen-Zahlen.

> Die UX-Intention „Score-Zahlen lesen sich wie Digital-Display" wird im
> neuen Design über JetBrains Mono + `font-weight: bold` + `letter-spacing`
> erfüllt. Die alten Schriften (Chakra Petch, Bebas Neue, Seven Segment)
> entfallen — der `.seven-segmnet`-Tippfehler ist damit gegenstandslos.

### 13.3 Icons — font-loaded + browser-cached only

**Harte Regel:** Ein Icon darf **null nennenswerte Bytes** zum HTML
hinzufügen, das der Server schickt. Das Icon-Asset selbst wird **einmal**
geladen (Font-Datei oder Sprite/PNG) und vom Browser für alle weiteren
Aufrufe gecached.

**Pflicht-Mechanismus für alle UI-Icons: Material Symbols Outlined.**
Eingebunden via `<link>` in `<head>` von `app/layout.tsx`. Verwendung:

```tsx
<span className="material-symbols-outlined">home</span>
```

→ Im HTML steht pro Icon nur ein `<span>` mit dem Icon-Namen als Text
(≈30 Bytes). Die Font-Datei wird einmalig geladen, der Browser cached
sie für die gesamte Session.

**Fallback (nur falls Material Symbols ein Icon nicht hat):** eine
einzelne PNG- oder SVG-Datei aus `public/icons/`, referenziert als
`<img src="/icons/foo.svg" />` oder als CSS-Background-Sprite. Nie inline.

**Verboten:**

- Inline `<svg>…</svg>` in JSX
- `dangerouslySetInnerHTML` mit SVG-Inhalt
- SVG-as-React-Component (`import Icon from './icon.svg'`), SVGR-Loader
- Icon-Bibliotheken mit Per-Icon-React-Components:
  `lucide-react`, `@heroicons/react`, `react-icons`,
  `@radix-ui/react-icons`, `@tabler/icons-react` und alle weiteren mit
  dem `import { Icon } from 'lib'; <Icon />`-Pattern.

**Flaggen** (24 Dateien in `public/svg/<TLA>.svg`) sind die einzigen
SVG-Assets im Projekt und werden ausschließlich als `<img>` referenziert,
niemals inline.

**Verifikations-Grep für CI / Pre-Merge:**

```bash
grep -rn "<svg" app/ components/ lib/
grep -rn "dangerouslySetInnerHTML" app/ components/ lib/
grep -rn "lucide-react|@heroicons|react-icons|@radix-ui/react-icons|@tabler/icons-react" \
  --include='*.ts' --include='*.tsx' --include='*.json' .
```

Alle drei Greps müssen 0 Treffer liefern.

### 13.3 Layout-Patterns die übernommen werden müssen (nicht das Styling)

| Pattern                    | Wofür                                                                    |
| -------------------------- | ------------------------------------------------------------------------ |
| 2-Spalten-Grid auf Desktop | Dashboard: Ranking links, Spielplan rechts (`lg:grid-cols-2`)            |
| Match-Card als Grid (6×2)  | Teams links, Score Mitte, Tipp/Eingabe rechts                            |
| Tabs via Radio-Buttons     | `<input type=radio>` + `peer-checked` → in React mit `useState` ersetzen |
| Mobile-Abkürzungen         | Spalten-Header werden in `<lg` zu Kürzeln (RE/T/S/EP/P) — UX behalten    |
| Aktive Zeile gelb          | `match.user_id === userId` → `text-yellow-100 font-black` + linker Rand  |

---

## 14) Test-Verhaltens-Spezifikation (1:1 zu erhaltende Logik)

Die Tests dokumentieren das **erwartete Verhalten** — beim Neubau müssen diese Cases weiter funktionieren.

### 14.1 Unit-Tests (`tests/unit/lib/function.test.ts`)

| Funktion             | Eingabe                                     | Erwartet                                   |
| -------------------- | ------------------------------------------- | ------------------------------------------ |
| `filterValidGames`   | `{homeTeam:{name:'A'},awayTeam:{name:'B'}}` | true                                       |
| `filterValidGames`   | `{homeTeam:{name:null}, ...}`               | false                                      |
| `formatDate`         | `new Date(2022,11,31).getTime()`            | `"Samstag, 31. Dezember 2022"` (de-DE)     |
| `extractTime`        | `new Date(2022,11,31,13,45)`                | `"13:45"`                                  |
| `abbreviateUsername` | 26 Zeichen                                  | erste 14 + `"..."` → `"verylonguserna..."` |
| `abbreviateUsername` | 9 Zeichen                                   | unverändert                                |

### 14.2 Integration: `lib/tip.test.ts`

1. `getTipByUserAndMatch(1,1)` initial → `undefined`.
2. `saveTip(1,1,3,2)` → `getTipByUserAndMatch(1,1)` liefert `{userId:1, matchId:1, scoreHome:3, scoreAway:2}`.
3. `saveTip(1,1,1,3)` (selber User+Match) → **UPDATE**, neue Werte `{1,3}`.
4. **Date-Update**: nach erneutem `saveTip` muss `tip.date` **größer** sein als der vorherige Wert. → `saveTip` MUSS `date = new Date()` bei UPDATE setzen (siehe heute `lib/tip.ts:13`).
5. `getTipByUserAndMatchIds(1, [1,3])` → exakt 2 Treffer für `user_id=1, match_id ∈ {1,3}`, sortiert nach Einfüge-Reihenfolge.
6. `getTipByUserAndMatchIds(_, [])` → leeres Array (Early-Return, kein DB-Call).

### 14.3 Integration: `lib/api.test.ts` (Ranking-Slicing)

`getRating(userId)` liest von Rust API und schneidet so:

- **User auf Platz 5 (von 7)**: `topThree = global[0..3]` + `userAndNeighbors = global[3..6]` (3 Einträge: User + 1 davor + 1 dahinter).
- **User auf Platz 1**: `topThree = global[0..6]` (6 Einträge), `userAndNeighbors = []`.
- **Leere Liste**: beide leer.

→ Logik exakt so übernehmen (siehe heute `lib/api.ts:7–17`).

### 14.4 Integration: `api/auth/login.test.ts`

| Eingabe                         | Status | Error-Message                             |
| ------------------------------- | ------ | ----------------------------------------- |
| `email="a@"` (length 2 < 3)     | 400    | `"Ungültige E-Mail"`                      |
| `password="123"` (length 3 < 4) | 400    | `"Ungültiges Passwort"`                   |
| User nicht in DB                | 400    | `"E-Mail ist bei uns nicht registriert."` |

⚠️ Login-Validierung ist sehr lax (kein Regex, nur Längenchecks).

### 14.5 Integration: `api/tip/[matchId].test.ts`

| Szenario                                    | Status | Error                                                                 |
| ------------------------------------------- | ------ | --------------------------------------------------------------------- |
| Keine Session                               | 401    | `"user is not logged in"`                                             |
| `session.userId="userId"` (nicht numerisch) | 401    | `"UserId not found"`                                                  |
| `params.matchId` fehlt                      | 401    | `"MatchId not found"`                                                 |
| `matchId=9999999` (nicht in DB)             | 401    | `"Match not found"`                                                   |
| `tip1=21, tip2=-1` (out of range)           | 401    | enthält `"außerhalb des erlaubten Bereichs"`, `"tip1"`, `"tip2"`      |
| Valid (matchId=5, tip1=2, tip2=1, userId=1) | 200    | `{success:true, tip:{matchId:5, userId:1, scoreHome:2, scoreAway:1}}` |

⚠️ Test verlässt sich auf Demo-Daten: `matchId=5` ist `NLD vs POL` in der **Zukunft** (1 Monat später) — sonst greift der Past-Match-Guard.

### 14.6 Integration: `api/user/index.test.ts`

| Szenario                         | Erwartet                                                                                                                                                                                                                  |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Erfolgreicher Signup             | redirect zu `"/login?registered=true"`, User in DB mit Argon2-Hash                                                                                                                                                        |
| Selbe E-Mail nochmal             | 400, `"User test@example.com already exists"`                                                                                                                                                                             |
| `username` + `department` fehlen | 400, `"Missing required fields: username, departments"` ⚠️ **kein Tippfehler — `s` wird IMMER angehängt** an die joined-Liste (`...join(', ')}s\``, `pages/api/user/index.ts:33`). Nur 1 fehlend `email`→`"...: emails"`. |
| `winner === secretWinner`        | 400, `"Winner and secret winner cannot be the same team."`                                                                                                                                                                |

→ **`s`-Tippfehler in Error-Message** ist live und wird im Test fixiert. Beim Neubau: korrigieren (User-facing!), Test anpassen.

### 14.7 Acceptance (Playwright, in CI deaktiviert)

- `signup_and_login.spec.ts`: Vollständiger Signup → automatischer Redirect zu Login mit Success-Banner → Login → Dashboard mit Heading "Spielplan" sichtbar.
- `login_and_tip.spec.ts`: Login mit Fixture-User → Dashboard → erstes Tipp-Form füllen → save → Wert sichtbar → Logout → Login-Heading sichtbar.

### 14.8 Test-Datenbank-Setup

- **Kein Test-DB-Isolation** — Tests laufen gegen dieselbe `db/database.db` wie Dev.
- `afterEach` löscht User-Tipps manuell (`tip.test.ts`: userId 1+2).
- `afterAll` löscht erstellte User (`user/index.test.ts`: `test@example.com`).
- Vitest-Config (`vitest.config.mjs`): excluded `tests/acceptance/**`, lädt `.env` + `.env.test` (in dieser Reihenfolge).

→ Neubau: **In-Memory-SQLite oder Test-Container** für Isolation. Heute zerstört ein fehlgeschlagener Test ggf. Dev-Daten.

---

## 15) `src/icon/` und `Icon`-Komponente

- Enthält genau **eine** SVG: `refresh.svg` (Material-Symbol "refresh").
- Wird via `Icon name="refresh"` lazy importiert (`import(\`../icon/${name}.svg?raw\`)`).
- **Aber: kein Aufruf von `<Icon>` im aktuellen Code** (grep zeigt nur die Komponente selbst).
- Ist also tote Infrastruktur — beim Neubau **streichen oder als Pattern für `lucide-react` / `@radix-ui/react-icons` ersetzen**.

---

## 16) `App.Locals` Type-Definition (`src/env.d.ts`)

```ts
declare namespace App {
  interface Locals {
    session: import("lucia").Session | null;
    user: import("lucia").User | null;
  }
}
interface ImportMetaEnv {
  readonly API_URL: string; // = Rust betting-api Base-URL
}
```

→ Next.js-Equivalent:

- Session/User aus `auth()`-Helper (NextAuth) oder Lucia-Adapter direkt
- `API_URL` als `process.env.RUST_API_URL` (nicht `NEXT_PUBLIC_` — Server-only, leakt sonst)

---

## 17) `fetchApi`-Helper Detail (`src/core/api.ts`)

```ts
fetchApi<T>(endpoint: string, wrappedByKey?: string): Promise<T>
```

- Baut URL: `API_URL` + `endpoint`, trimmt führende Slashes auf beiden Seiten.
- Macht `fetch` (kein Auth-Header — Rust-API ist unauthenticated, public!).
- Wenn `wrappedByKey` gesetzt: `return data[wrappedByKey]`.
  - Beispiel: `fetchApi<UserRating>('user/'+id, 'data')` — Rust antwortet mit `{data: UserRating}`, Helper extrahiert.
- Kein Error-Handling: HTTP-Fehler werden nicht abgefangen, JSON-Parse-Fehler crashen die Seite.

→ Neubau: Wrapper mit Retry/Timeout/Error-Boundary + (falls Rust-API public bleibt) Server-Side-only-fetch um kein CORS zu brauchen.

---

## 18) Vollständigkeits-Audit (was geprüft wurde)

✅ Alle 7 Pages (`index, login, signup, password-forget, table, user/[id], match/[id]`)
✅ Alle 6 API-Routes (`auth/login, auth/logout, auth/password-forget, user, tip/[matchId], match/import`)
✅ Alle 9 Components (`Button, ButtonLink, ErrorAlert, Flag, Icon, Input, Logo, ShortTable, SuccessAlert`)
✅ Beide Layouts (`Layout, LogginLayout`)
✅ Alle 6 lib-Module (`api, auth, function, match, tip, user`)
✅ Alle 5 Interfaces (`match, sideBarItem, table, tip, user`)
✅ Beide core-Module (`api, db`)
✅ Middleware
✅ DB-Schema (4 Tabellen)
✅ Beide Scripts (`migrate, demo_data`)
✅ Alle 8 Tests (1 unit, 5 integration, 2 acceptance)
✅ Beide Styles (`global, index`)
✅ Konfigs (`astro, drizzle, tailwind, tsconfig, vitest, playwright, ecosystem, .env.test, .gitignore`)
✅ CI (`main.yml`) + nginx-Snippet
✅ Public-Assets (24 Flag-SVGs, favicon, 7 Fonts)
✅ Type-Decls (`env.d.ts, bun.d.ts`)
✅ Icon-Verzeichnis (1 SVG)

**Nicht im Repo, aber durch CLAUDE.md-/Kontext-Wissen bekannt:**

- Echte Migrations werden bei `pnpm run init` von Drizzle generiert (gitignored).
- DB-File `db/database.db` wird bei Demo-Init gefüllt; in Prod kommt sie über Rust-Importer (`macht-api`) dazu.

---

## 19) Empfehlungen für den Neubau (was man besser machen sollte)

Funktional gleich bleiben — diese Punkte verbessern Sicherheit, Wartbarkeit und UX **ohne** das Spielprinzip zu ändern.

> **Mapping zu Tickets (Stand: Backlog-Audit 2026-05-27):**
>
> - **In FE-002 adressiert:** generische Login-Fehler, Logout POST,
>   Argon2id-Parameter, Passwort-Policy ≥8, Email-Regex (Zod),
>   Rate-Limit auf `/api/auth/login` + `/api/user`, Secure-Cookies.
> - **Per FE-019 entfernt:** `/api/match/import` und damit auch die
>   `Origin: RUST_APPLICATION`-Ausnahme. macht-api schreibt direkt
>   in SQLite; der HTTP-Hook war ungenutzt.
> - **In FE-009 (Security-Audit) adressiert:** CSRF-Token auf Forms,
>   Header-Hardening (CSP, X-Frame-Options, Permissions-Policy),
>   Dependency-Audit.
> - **Aufgeschoben / Tech-Debt (kein Ticket, bewusst zurückgestellt):**
>   `username UNIQUE`-Constraint, `tip.userId NOT NULL`,
>   `tip.matchId NOT NULL`, `'Maintz'`-Tippfehler in DB. Grund:
>   Schema 1:1 mit Astro-Vorgänger erhalten, damit `betting-api` und
>   `macht-api` (Rust-Structs) unangetastet bleiben. Wenn dieses
>   Tech-Debt später angegangen wird: XR-Ticket mit koordinierten
>   Drizzle-Migration + Rust-Struct-Updates.

### 19.1 Sicherheit

- **CSRF-Token** auf allen POST-Forms (heute nur Origin/Host-Check — anfällig gegen Same-Origin-XSS).
- **`Origin: RUST_APPLICATION` Magic-String → API-Key/Bearer-Token** für `/api/match/import`.
- **Rate-Limit** auf `/api/auth/login` und `/api/user` (Brute-Force-Schutz). Z.B. via `@upstash/ratelimit` oder Edge-Middleware.
- **Einheitliche Login-Fehler** — kein Email-Existenz-Leak (`"E-Mail ist bei uns nicht registriert."` verrät zu viel).
- **Logout via POST** (heute GET → CSRF-anfällig).
- **Argon2id-Parameter explizit setzen**: `new Argon2id({ memorySize: 19456, iterations: 2, tagLength: 32, parallelism: 1 })` (OWASP 2024).
- **Password-Policy**: aktuell nur `length >= 4`. Mindestens 8 Zeichen + Zod-validiertes Strength-Check (z.B. `zxcvbn`).
- **`username UNIQUE`-Constraint** in DB ergänzen — heute können Duplikate auftreten, Ranking wäre verwirrend.
- **Email-Regex-Validierung** statt nur `length >= 3` (Zod schemas).
- **Secure-Cookie-Flags**: heute `secure: !!import.meta.env.PROD`. Im Neubau: zusätzlich `httpOnly`, `sameSite: 'lax'`.

### 19.2 Code-Qualität

- **Zod/Valibot** als zentrale Validation-Layer (login, signup, tip, match/import). Heute manuelles `if (!field)`-Geprügel.
- **Server-Actions** (Next.js) statt `fetch + FormData` mit inline `<script>`-Blocks. Vereinfacht alles im Dashboard/Login/Signup.
- **`departments` und EM-Teams** in eine Konstantendatei (`lib/data/teams.ts`, `lib/data/departments.ts`). Heute 2× in JSX dupliziert.
- **`countryMapping` (DEU→GER etc.)** in `lib/flags.ts` zentralisieren. Heute in `Flag.astro` versteckt.
- **`'Maintz'`-Tippfehler** in einer Migration auf `'Mainz'` korrigieren. Frontend-Mapping entfernen.
- **`.seven-segmnet` → `.seven-segment`** (CSS-Klasse-Tippfehler).
- **`s`-Suffix in Error-Messages** fixen → richtige Pluralisierung mit i18n-Lib oder Template-Literal.
- **Drizzle-Migrations EINCHECKEN** statt gitignoren. Standard-Best-Practice.
- **In-Memory-Test-DB** statt geteilter Dev-DB — heute zerstört ein gecrashter Test reale Daten.
- **`tip.userId` und `tip.matchId` sind nullable** im Schema (`integer('user_id').references(...)`) — sollte `notNull()` haben. Migration nötig.

### 19.3 UX / Frontend-Verhalten

- **Mobile-Menu** komplett implementieren (heute auskommentiert in `LogginLayout`). Nav ist auf <450px gequetscht.
- **Optimistic Updates** beim Tipp-Speichern (React-Query/SWR `mutate`). Heute Spinner + Reload-DOM.
- **Live-Match-Updates per SSE/WebSocket** statt page-Reload. Rust könnte einen `/events`-Stream öffnen oder Frontend pollt `/user/{id}` alle 30s.
- **Time-Zone-Handling**: heute speichert SQLite `utcDate` als int, JS rendert via `toLocaleDateString('de-DE')` mit Server-TZ. Im Neubau explizit auf UTC umrechnen oder `Intl.DateTimeFormat` mit `timeZone` config.
- **Accessibility**: Radio-Button-Tabs sind nicht ARIA-konform → `<Tabs>`-Pattern (Radix UI / shadcn) verwenden. Fehlertexte mit `aria-live="polite"`.
- **Forms ohne JS** funktionieren heute (action+method-Attribute), aber die Antworten sind JSON. Bei No-JS-Submit zeigt der Browser raw JSON. Im Neubau: Server-Actions oder echte HTML-Redirects bei Fehlern.
- **`/password-forget`** entweder vollständig implementieren (Mail-Provider wie Resend/Postmark) oder Route + UI entfernen.
- **i18n-vorbereitet bauen** auch wenn aktuell nur Deutsch — `next-intl` mit `de` als Default. Erleichtert spätere Sprachen für Mannheim/Mainz/Langenfeld-Standort + ggf. weitere.
- **Loading-States** als Skeleton statt Spinner (`<div class="loading">`).
- **Username-Truncation** als CSS `text-ellipsis` statt JS-`abbreviateUsername` — wäre responsive.

### 19.4 Performance / Architektur

- **`fetchApi` mit Caching**: `next: { revalidate: 30 }` für `/rating`. Heute jeder Page-Render = neuer Rust-Call.
- **Server Components** für Ranking-Daten (kein Hydration nötig).
- **Edge Runtime** für `/api/tip/[matchId]` — leichte Validierung, schnelles Speichern.
- **Postgres statt SQLite** falls Multi-Server gewünscht. Drizzle-Schema bleibt fast identisch (`text` → `varchar`, `mode: 'json'` → `jsonb`). Aber: **Rust-Side muss dann auch Postgres-fähig sein** — heute `rusqlite` hardcoded.
- **Match-Import-Architektur überdenken**: Heute schreibt Rust direkt in SQLite, Frontend liest direkt aus SQLite, Frontend ruft Rust-API für Rankings. Wenn der Plan Postgres ist: Rust-Service muss `tokio-postgres`/`sqlx` werden.

### 19.5 Konkrete „Nice to have"-Features (waren wahrscheinlich auf der Wunschliste)

- **Push-Notifications** vor Match-Start (Web Push API).
- **Statistik-Seite** pro User: Trefferquote, beste Saison, durchschn. Punkte pro Spiel.
- **Match-Detail mit User-Tipps-Verteilung** als Histogramm (z.B. „45% getippt 1:1").
- **Department-Verwaltung** über UI statt hardcoded.
- **Admin-Bereich** für Match-Resync, Winner-/SecretWinner-Korrekturen.
- **Pre-Turnier-Sperre**: Winner/SecretWinner-Auswahl darf nicht mehr nach Turnier-Start geändert werden — heute via UI auch nicht änderbar (nur DB).

---

## 20) Demo-Data / Fixtures (PFLICHT für lokale Entwicklung)

Beim Neubau **nicht optional**. Ohne korrekte Seed-Daten kann man weder Dashboard, Ranking, Scoring-Farben noch Tipp-Eingabe lokal testen.

### 20.1 Aktueller Zustand (kaputt — nicht so übernehmen)

- `em2024-frontend/scripts/demo_data.ts` legt 7 User + 5 Matches an, **aber 0 Tipps** → Ranking lokal immer leer, Punkte-Farben (4=grün/2=gelb/0=rot) nie sichtbar.
- 3 von 7 Demo-Usern haben Department `"London"` → wird nirgendwo angezeigt, weil Tabs nur Langenfeld/Mannheim/Mainz kennen.
- `betting-api/src/db/fixtures.rs` hat zwar 11 Tipps mit Scoring-Verteilung, ist aber **nur in `MODE=test`** aktiv (cargo test). Dev-Server lädt sie nicht.
- Tests + Dev teilen sich `db/database.db` → ein gecrashter Integration-Test korrumpiert Demo-Daten.

### 20.2 Ziel-Architektur (One source of truth)

**Wichtig**: Die DB-Datei liegt **nicht mehr im Frontend-Repo**, sondern an einem **neutralen Pfad außerhalb aller drei Repos** (siehe §21). Der Frontend-Code referenziert sie nur via `DATABASE_URL` Env-Variable.

```
new-frontend/                     # neues Next.js Repo
├── db/
│   ├── schema.ts                 # Drizzle schema (KEIN .db-File mehr hier!)
│   └── seeds/
│       ├── users.ts
│       ├── matches.ts
│       ├── tips.ts
│       └── seed.ts               # Master-Script
├── scripts/
│   ├── migrate.ts                # liest DATABASE_URL aus env
│   ├── seed-dev.ts               # liest DATABASE_URL aus env (.env)
│   └── seed-test.ts              # liest DATABASE_URL aus env (.env.test)
└── .env.example                  # DATABASE_URL=../shared/db/database.db
                                  # API_URL=http://localhost:8080

# DB liegt extern:
shared/                           # gleichlevel wie alle Repos
└── db/
    ├── database.db               # Dev-DB (gitignored im shared-Repo / als Ordner)
    └── test.db                   # Test-DB, isoliert
```

### 20.3 NPM-Scripts (verbindlich)

```json
{
  "db:migrate": "tsx scripts/migrate.ts",
  "db:reset": "rm -f $DATABASE_URL && pnpm db:migrate",
  "db:seed": "tsx scripts/seed-dev.ts",
  "db:seed:test": "dotenv -e .env.test -- tsx scripts/seed-test.ts",
  "db:fresh": "pnpm db:reset && pnpm db:seed",
  "test": "pnpm db:seed:test && dotenv -e .env.test -- vitest"
}
```

`scripts/migrate.ts`, `seed-dev.ts`, `seed-test.ts` lesen alle `process.env.DATABASE_URL` — **kein Pfad im Code**.

→ Dev-Workflow: `pnpm db:fresh` reicht für komplettes Reset+Seed. Test-Workflow: automatisch isoliert (`.env.test` → `shared/db/test.db`).

### 20.4 Konkrete Seed-Daten — User (8 Personen, 3 Departments)

```ts
[
  // Mainz (2)
  {
    email: "ada@dev.local",
    username: "AdaLovelace",
    firstName: "Ada",
    lastName: "Lovelace",
    department: "Mainz",
    winner: "DEU",
    secretWinner: "ESP",
  },
  {
    email: "alan@dev.local",
    username: "AlanTuring",
    firstName: "Alan",
    lastName: "Turing",
    department: "Mainz",
    winner: "ENG",
    secretWinner: "FRA",
  },

  // Mannheim (3)
  {
    email: "marie@dev.local",
    username: "MarieCurie",
    firstName: "Marie",
    lastName: "Curie",
    department: "Mannheim",
    winner: "FRA",
    secretWinner: "DEU",
  },
  {
    email: "nikola@dev.local",
    username: "NikolaTesla",
    firstName: "Nikola",
    lastName: "Tesla",
    department: "Mannheim",
    winner: "HRV",
    secretWinner: "ITA",
  },
  {
    email: "rosa@dev.local",
    username: "RosaParks",
    firstName: "Rosa",
    lastName: "Parks",
    department: "Mannheim",
    winner: "ESP",
    secretWinner: "POR",
  },

  // Langenfeld (3) — incl. der "Du"-User für Testing der gelben Hervorhebung
  {
    email: "me@dev.local",
    username: "TestUser",
    firstName: "Test",
    lastName: "User",
    department: "Langenfeld",
    winner: "DEU",
    secretWinner: "NLD",
  },
  {
    email: "albert@dev.local",
    username: "AlbertEinstein",
    firstName: "Albert",
    lastName: "Einstein",
    department: "Langenfeld",
    winner: "DEU",
    secretWinner: "ITA",
  },
  {
    email: "isaac@dev.local",
    username: "IsaacNewton",
    firstName: "Isaac",
    lastName: "Newton",
    department: "Langenfeld",
    winner: "POR",
    secretWinner: "ENG",
  },
];
```

**Passwort für alle**: `test123` (Argon2id-Hash beim Seed berechnen, nicht hardcoded).
**Login-Convention**: `me@dev.local` / `test123` → das ist "ich selbst" beim Testen.

### 20.5 Konkrete Seed-Daten — Matches (12 Spiele in 3 Status-Buckets)

Verwende **relative Datumsangaben** zu `now`, damit der Seed reproduzierbar bleibt.

```ts
const now = Date.now();
const HOUR = 3600_000,
  DAY = 86400_000;

[
  // ── 4× FINISHED (Vergangenheit, Tipps NICHT mehr änderbar) ──
  {
    id: 1,
    homeTeam: TEAM.GER,
    awayTeam: TEAM.ESP,
    utcDate: now - 7 * DAY,
    status: "FINISHED",
    homeScore: 2,
    awayScore: 0,
  },
  {
    id: 2,
    homeTeam: TEAM.POL,
    awayTeam: TEAM.FRA,
    utcDate: now - 5 * DAY,
    status: "FINISHED",
    homeScore: 1,
    awayScore: 1,
  },
  {
    id: 3,
    homeTeam: TEAM.ENG,
    awayTeam: TEAM.NED,
    utcDate: now - 3 * DAY,
    status: "FINISHED",
    homeScore: 0,
    awayScore: 2,
  },
  {
    id: 4,
    homeTeam: TEAM.ITA,
    awayTeam: TEAM.HRV,
    utcDate: now - 1 * DAY,
    status: "FINISHED",
    homeScore: 3,
    awayScore: 2,
  },

  // ── 2× IN_PLAY (Live, treibt Live-Block auf Dashboard) ──
  {
    id: 5,
    homeTeam: TEAM.FRA,
    awayTeam: TEAM.DEU,
    utcDate: now - 2 * HOUR,
    status: "IN_PLAY",
    homeScore: 1,
    awayScore: 1,
  },
  {
    id: 6,
    homeTeam: TEAM.POR,
    awayTeam: TEAM.ENG,
    utcDate: now - 1 * HOUR,
    status: "IN_PLAY",
    homeScore: 0,
    awayScore: 0,
  },

  // ── 6× SCHEDULED (Zukunft, Tippen möglich) ──
  {
    id: 7,
    homeTeam: TEAM.ESP,
    awayTeam: TEAM.ITA,
    utcDate: now + 2 * HOUR,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
  {
    id: 8,
    homeTeam: TEAM.NED,
    awayTeam: TEAM.HRV,
    utcDate: now + 1 * DAY,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
  {
    id: 9,
    homeTeam: TEAM.DEU,
    awayTeam: TEAM.POR,
    utcDate: now + 2 * DAY,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
  {
    id: 10,
    homeTeam: TEAM.FRA,
    awayTeam: TEAM.POL,
    utcDate: now + 3 * DAY,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
  {
    id: 11,
    homeTeam: TEAM.ENG,
    awayTeam: TEAM.ESP,
    utcDate: now + 7 * DAY,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
  {
    id: 12,
    homeTeam: TEAM.ITA,
    awayTeam: TEAM.DEU,
    utcDate: now + 14 * DAY,
    status: "SCHEDULED",
    homeScore: null,
    awayScore: null,
  },
];
```

Team-Konstante zentral (mit FIFA-TLA für Flag-Anzeige):

```ts
const TEAM = {
  GER: { name: "Germany", tla: "GER" },
  ESP: { name: "Spain", tla: "ESP" },
  FRA: { name: "France", tla: "FRA" },
  ITA: { name: "Italy", tla: "ITA" },
  POR: { name: "Portugal", tla: "POR" },
  ENG: { name: "England", tla: "ENG" },
  NED: { name: "Netherlands", tla: "NED" },
  POL: { name: "Poland", tla: "POL" },
  HRV: { name: "Croatia", tla: "CRO" }, // ISO HRV → FIFA CRO
};
```

### 20.6 Konkrete Seed-Daten — Tipps (alle Scoring-Cases sichtbar)

**Ziel**: Nach dem Seed zeigt das Dashboard für jeden User unterschiedliche Punkte, alle 4 Punkte-Farben sind sichtbar, das Ranking hat keine Gleichstände (sonst sieht man Tie-Logik nicht).

**Scoring zur Erinnerung** (aus Rust `betting-api/src/service/mod.rs`):

- 5 Punkte = exakt (z.B. 2:0 getippt, 2:0 gespielt)
- 3 Punkte = Tordifferenz korrekt, kein Unentschieden, Ergebnis falsch (3:1 getippt, 2:0 gespielt)
- 2 Punkte = Sieger korrekt **ODER** Unentschieden korrekt (aber andere Tordifferenz)
- 0 Punkte = alles falsch
- +12 wenn `user.winner === 'ESP'` (Turnier-Sieger hardcoded), +6 wenn `user.secretWinner === 'ESP'`

**Tipp-Matrix** (4 vergangene + 2 Live-Matches = 6 mit Score; SCHEDULED-Matches → Tipps optional):

| User           | M1 (GER:ESP 2:0) | M2 (POL:FRA 1:1) | M3 (ENG:NED 0:2) | M4 (ITA:HRV 3:2) | M5 (live FRA:DEU 1:1) | M6 (live POR:ENG 0:0) | M7 (zukunft, getippt) |
| -------------- | ---------------- | ---------------- | ---------------- | ---------------- | --------------------- | --------------------- | --------------------- |
| AdaLovelace    | 2:0 → **5**      | 1:1 → **5**      | 0:2 → **5**      | 3:2 → **5**      | 1:1 → **5**           | 0:0 → **5**           | 2:1 ESP:ITA           |
| AlanTuring     | 3:1 → **3**      | 0:0 → **2**      | 1:3 → **3**      | 2:1 → **3**      | 2:2 → **2**           | 1:1 → **2**           | (kein Tipp)           |
| MarieCurie     | 1:0 → **2**      | 2:2 → **2**      | 0:1 → **2**      | 1:0 → **2**      | (kein Tipp)           | (kein Tipp)           | 0:1                   |
| NikolaTesla    | 0:2 → **0**      | (kein Tipp)      | 2:0 → **0**      | 0:3 → **0**      | 0:2 → **0**           | 3:0 → **0**           | 1:2                   |
| RosaParks      | 2:0 → **5**      | 0:1 → **0**      | 1:2 → **3**      | 2:2 → **2**      | 1:0 → **0**           | (kein Tipp)           | 0:0                   |
| **TestUser**   | 1:1 → **0**      | 2:2 → **2**      | 0:2 → **5**      | 3:3 → **2**      | 0:0 → **2**           | 1:0 → **0**           | 2:0                   |
| AlbertEinstein | 3:0 → **3**      | 1:1 → **5**      | 1:1 → **2**      | (kein Tipp)      | 1:1 → **5**           | 0:0 → **5**           | (kein Tipp)           |
| IsaacNewton    | (kein Tipp)      | 1:0 → **0**      | 2:1 → **0**      | 4:3 → **3**      | 2:1 → **0**           | 2:2 → **2**           | 1:1                   |

**Erwartetes Ranking nach Seed (Match-Punkte, ohne Extra-Punkte für Winner='ESP')**:

1. AdaLovelace — 30 P (alle 6 exakt, +0 weil ESP nur secretWinner: +6 = **36 P**)
2. AlbertEinstein — 20 P (+0 ESP-Extra)
3. AlanTuring — 15 P
4. RosaParks — 10 P (winner ESP! → **+12 = 22 P**)
5. TestUser — 11 P
6. IsaacNewton — 5 P
7. MarieCurie — 4 P
8. NikolaTesla — 0 P

→ **Sichtbar testbar**: alle Punkte-Farben, ESP-Extra-Bonus, Mixed Ranking mit/ohne Extra-Punkte, Hervorhebung von "TestUser" als angemeldeter User, Tipp-Edit auf Match 7 (Future), Live-Punkte auf Match 5+6.

### 20.7 Idempotenz + Reset

```ts
// scripts/seed-dev.ts (Pseudocode)
import { db } from "@/lib/db";
import { user, match, tip, session } from "@/db/schema";

await db.delete(session); // FK-Reihenfolge
await db.delete(tip);
await db.delete(match);
await db.delete(user);

await db.insert(user).values(userSeed);
await db.insert(match).values(matchSeed);
await db.insert(tip).values(tipSeed); // userId/matchId mapping pflegen
console.log(
  `✓ seeded ${userSeed.length} users, ${matchSeed.length} matches, ${tipSeed.length} tips`,
);
```

**Wichtig**: User-Passwörter beim Seed mit `Argon2id().hash('test123')` hashen, **nicht** den Hash hardcoden — sonst bricht's wenn man Argon2id-Params ändert.

### 20.8 Verifikations-Befehl

Nach `pnpm db:fresh` muss folgendes alles funktionieren — als Smoke-Test im README dokumentieren:

```bash
# 1. Login mit Test-User
curl -c jar -X POST http://localhost:3000/api/auth/login \
  -F email=me@dev.local -F password=test123 -i | grep "302\|Location"

# 2. Ranking abrufen (über Rust-API)
curl http://localhost:8080/rating | jq '.table.global | length'
# erwartet: 8

# 3. Live-Matches sichtbar
curl http://localhost:8080/rating | jq '.table.global[] | {name, score_sum}'
# erwartet: AdaLovelace mit höchstem Score, NikolaTesla mit 0
```

### 20.9 Test-DB-Isolation

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";
import dotenv from "dotenv";
dotenv.config({ path: ".env.test" }); // setzt DATABASE_URL=db/test.db

export default defineConfig({
  test: {
    setupFiles: ["./tests/setup.ts"], // ruft seed-test.ts vor jedem Run
    pool: "forks", // saubere DB pro Worker (SQLite-Lock)
  },
});
```

**`.env.test`** (im neuen Frontend-Repo):

```
DATABASE_URL=../shared/db/test.db
API_URL=http://localhost:8080
NODE_ENV=test
```

**`.env`** (Dev):

```
DATABASE_URL=../shared/db/database.db
API_URL=http://localhost:8080
```

→ Tests können nicht mehr Dev-Daten zerstören. Beide DBs leben extern unter `shared/db/`.

### 20.10 Was migriert werden muss vs. neu zu schreiben

| Quelle                                       | Aktion                                         |
| -------------------------------------------- | ---------------------------------------------- |
| `em2024-frontend/scripts/demo_data.ts`       | **Verwerfen**, war unvollständig               |
| `betting-api/src/db/fixtures.rs`             | **Behalten** — bleibt für Rust-Tests in-memory |
| `em2024-frontend/scripts/migrate.ts`         | 1:1 übernehmen (Drizzle-Standard)              |
| EM-Team-Liste aus `pages/signup.astro:56–80` | Nach `lib/data/teams.ts` extrahieren           |
| Departments aus `pages/signup.astro:43–45`   | Nach `lib/data/departments.ts` extrahieren     |

---

## 21) DB-Pfad-Migration & Cross-Repo-Setup

Das alte `em2024-frontend/` wird abgelöst. Damit geht die DB-Datei (heute `em2024-frontend/db/database.db`) **mit aus dem Frontend raus**. Alle drei Services (neues Frontend, `betting-api`, `macht-api`) referenzieren sie über env-vars auf einen **neutralen Pfad außerhalb aller Repos**.

### 21.1 Neue Verzeichnis-Struktur (lokal)

```
~/workspace/github/football-betting/
├── new-frontend/             # neues Next.js Repo (ersetzt em2024-frontend)
├── betting-api/              # bleibt — Read-API in Rust
├── macht-api/                # bleibt — Match-Importer in Rust
└── shared/
    └── db/
        ├── database.db       # Dev-DB
        └── test.db           # Test-DB
```

`shared/` ist **kein Git-Repo** — nur ein Ordner zum Halten der DB-Files lokal. In Prod liegt sie an einem Server-Pfad (§21.3).

### 21.2 Konkrete `.env`-Änderungen (alle drei Services)

| Repo                     | Heute                                        | Neu                                                                                       |
| ------------------------ | -------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `new-frontend/.env`      | (gab's nicht in dieser Form)                 | `DATABASE_URL=../shared/db/database.db`<br>`API_URL=http://localhost:8080`                |
| `new-frontend/.env.test` | `IS_TEST=1`, `API_URL=...`                   | `DATABASE_URL=../shared/db/test.db`<br>`API_URL=http://localhost:8080`<br>`NODE_ENV=test` |
| `betting-api/.env`       | `DATABASE_URL=/path/to/your/database.sqlite` | `DATABASE_URL=../shared/db/database.db`                                                   |
| `macht-api/.env`         | `DB_PATH=../em2024-frontend/db/database.db`  | `DB_PATH=../shared/db/database.db`                                                        |

→ Eine zentrale Änderung pro Repo, kein Code-Eingriff in Rust nötig (`env::var("DB_PATH")` bzw. `"DATABASE_URL"` ist schon dynamisch).

### 21.3 Production-Pfad

Auf dem Server (heute `em2024.vcec.cloud` mit nginx + PM2):

```
/var/lib/football-betting/
├── database.db          # Prod-DB
└── backups/             # Cron-Snapshot z.B. täglich
```

PM2-Env (`ecosystem.config.json`) für alle drei Services:

```
DATABASE_URL=/var/lib/football-betting/database.db
DB_PATH=/var/lib/football-betting/database.db
```

User/Permissions: alle PM2-Prozesse müssen RW auf dieser Datei haben. Üblicherweise via dedizierten User `football-betting:football-betting`.

### 21.4 Umzugs-Checkliste (für den Migrations-Tag)

Wenn das neue Frontend live geht und das alte raus:

1. **DB-Backup** ziehen: `cp em2024-frontend/db/database.db ~/backups/db-before-migration.db`.
2. **Neuen Pfad anlegen**:
   - Dev: `mkdir -p ~/workspace/github/football-betting/shared/db`
   - Prod: `sudo mkdir -p /var/lib/football-betting && sudo chown football-betting:football-betting /var/lib/football-betting`
3. **DB verschieben**:
   - Dev: `mv em2024-frontend/db/database.db shared/db/database.db`
   - Prod: `mv /old/path/database.db /var/lib/football-betting/database.db`
4. **`.env` aller drei Services updaten** (siehe §21.2).
5. **`macht-api` neu laden**: `cd macht-api && cargo run` (Probe ob's findet).
6. **`betting-api` neu starten**: `pm2 restart em2024-api` (oder lokal `cargo run`).
7. **Neues Frontend starten**: `pm2 start ecosystem.config.json` (im neuen Repo).
8. **Smoke-Test** aus §20.8 ausführen.
9. **Altes `em2024-frontend`** archivieren (nicht löschen — als Referenz für 6 Monate behalten).

### 21.5 Konsequenz für `db/schema.ts`

Drizzle-Schema (heute `em2024-frontend/db/schemas/schema.ts`) zieht **mit ins neue Frontend**:

- Neuer Pfad: `new-frontend/db/schema.ts`
- 1:1 übernehmen (siehe §1)
- `drizzle.config.ts` im neuen Repo:
  ```ts
  export default {
    schema: "./db/schema.ts",
    out: "./db/migrations", // ← jetzt eingecheckt (§19.2)
    dbCredentials: { url: process.env.DATABASE_URL! },
  } satisfies Config;
  ```

**Wichtig**: Drizzle-Migrations für die existierende DB (`database.db` aus em2024-frontend) müssen **kompatibel** sein, sonst dropt der erste Run die Tabellen. Vorgehen:

- `drizzle-kit introspect` gegen die existierende DB → generiert Initial-Migration die "leeren" Drift produziert.
- Diese als `0000_baseline.sql` committen.
- Drizzle erkennt: Schema schon angewendet, macht nichts.

### 21.6 Was bleibt unverändert

- **Rust `betting-api`** Code: keine Änderung, nur `.env` updaten.
- **Rust `macht-api`** Code: keine Änderung, nur `.env` updaten.
- **Rust-Fixtures** (`betting-api/src/db/fixtures.rs`): bleiben für Rust-Tests (in-memory, kein Pfad-Bezug).
- **nginx-Config**: keine Änderung — proxy_pass bleibt auf Port 4322 (oder welchen Port das neue Frontend nutzt).
- **PM2-Setup**: nur Path/Name anpassen, Logik gleich.

---

## 22) Was bewusst NICHT migrieren

- Astro-spezifische Hacks (`Astro.locals`, `set:html`, Frontmatter-`---`)
- Alpine.js (komplett ersetzbar durch React Client Components)
- Custom-CSS-Grid für Match-Cards — neues Design wird das anders lösen
- Auskommentiertes Mobile-Menu in `LogginLayout` (Zeile 33–73) — neu bauen, nicht copy/paste
- Inline-Script-Blocks (`<script>` am Ende jeder Page) — wandeln in Client Components + `fetch`/`mutation`
- Tab-Mechanismus via `<input type="radio" checked>` + peer-selectors → State in React
- Stub `password-forget` — entweder voll implementieren (Mail-Provider!) oder UI streichen
