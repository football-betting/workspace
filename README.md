# football-betting workspace

Local development workspace for the football-betting project. Three production
repos that share a SQLite database, plus the docs, tickets, and tooling that
keep them coordinated.

```
football-betting/                  ← this repo (workspace)
├── docs/                          # Specs & architecture
│   ├── FRONTEND_FUNKTIONS_SPEC.md
│   └── TECH_ARCHITEKTUR.md
├── tickets/                       # Active development workflow
│   ├── backlog/{todo,in-progress,review,done}/
│   ├── results/
│   └── testdata/
├── .claude/                       # Claude Code configuration
└── (after bootstrap.sh:)
    ├── frontend/                  ← github.com/football-betting/frontend
    ├── betting-api/               ← github.com/football-betting/betting-api
    ├── macht-api/                 ← github.com/football-betting/macht-api
    └── shared/db/                 # database.db + test.db (gitignored)
```

## Architecture in one paragraph

`frontend` (Next.js) owns the SQLite schema (Drizzle) and writes users + tips
directly. `macht-api` (Rust cron job) imports match data from the external
football API into the same SQLite file. `betting-api` (Rust HTTP server)
reads from that file and exposes ranking endpoints that the frontend consumes
for the leaderboard. All three share `shared/db/database.db` — schema
authority lives in the frontend, but every consumer must stay in lockstep.

Full spec: [`docs/TECH_ARCHITEKTUR.md`](docs/TECH_ARCHITEKTUR.md)
Frontend behaviour: [`docs/FRONTEND_FUNKTIONS_SPEC.md`](docs/FRONTEND_FUNKTIONS_SPEC.md)

## First-time setup

1. Clone this workspace repo.
2. Clone the three service repos as siblings inside it:
   ```bash
   git clone git@github.com:football-betting/frontend.git
   git clone git@github.com:football-betting/betting-api.git
   git clone git@github.com:football-betting/macht-api.git
   ```
3. Create the shared DB folder:
   ```bash
   mkdir -p shared/db
   ```
4. Configure each service's `.env`:
   - `frontend/.env`:        `DATABASE_URL=../shared/db/database.db`
   - `betting-api/.env`:     `DATABASE_URL=../shared/db/database.db`
   - `macht-api/.env`:       `DB_PATH=../shared/db/database.db`
5. Seed the database (from `frontend/`):
   ```bash
   cd frontend && pnpm install && pnpm db:fresh
   ```
6. Copy Claude settings:
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   chmod +x .claude/hooks/*.sh
   ```

## Daily workflow

Start each service in its own terminal:

```bash
# Terminal 1 — Frontend
cd frontend && pnpm dev

# Terminal 2 — Read API
cd betting-api && cargo run

# Terminal 3 — Match importer (once, or on cron)
cd macht-api && cargo run -- --full
```

## Tickets

Pick a ticket from `tickets/backlog/todo/`, then:

```
/ticket-start <id>     # → in-progress, summarises the ticket
… implement, run quality gate …
/ticket-review <id>    # → review, after Definition of Done passes
/ticket-done <id>      # → done, writes result document
```

Template: `.claude/templates/ticket-template.md`.
Workflow rules: `.claude/CLAUDE.md`.

## Repos at a glance

| Repo | Stack | Quality gate |
|---|---|---|
| [`frontend`](https://github.com/football-betting/frontend) | Next.js + TypeScript + Drizzle | `pnpm exec tsc --noEmit && pnpm exec vitest run` |
| [`betting-api`](https://github.com/football-betting/betting-api) | Rust + Actix-web + rusqlite | `cargo clippy -- -D warnings && cargo test` |
| [`macht-api`](https://github.com/football-betting/macht-api) | Rust + Tokio + reqwest + rusqlite | `cargo clippy -- -D warnings && cargo test` |

## Archived

- [`em2024-frontend`](https://github.com/football-betting/em2024-frontend) — Astro,
  Version 2 (Rust edition). Superseded by `frontend`.
