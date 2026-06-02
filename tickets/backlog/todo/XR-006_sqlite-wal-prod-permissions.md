# XR-006 SQLite/WAL production permissions: shared user/group, UMask, synchronous

## Repo
multi

## Type
chore

## Risk
medium

## Priority
high

## Status
todo

## Owner
implementer

## Background
Three production services share one SQLite file (`shared/db/database.db`):
`betting-api` reads, `macht-api` inserts/updates matches (oneshot every minute),
and the Next.js frontend reads and writes tips/sessions/avatars. The SQLite
concurrency primitives are already correct everywhere — WAL + `busy_timeout=5000`
on all three, short per-match autocommit writes in macht-api, a single atomic
`INSERT … ON CONFLICT DO UPDATE` for tips — so lock *contention* is handled.

The remaining gap is at the OS/deployment layer, not in the code. In WAL mode
**every** process that opens the database — including the read-only `betting-api`
— needs **write** access to the database *directory* and to the `-wal` / `-shm`
sidecar files (readers create/maintain `-shm` and may run checkpoints).
`busy_timeout` does not help here; the failure mode is
`unable to open database file` / `attempt to write a readonly database` /
`disk I/O error`.

The systemd units from XR-004 set no `User=`, `Group=`, or `UMask=`, so the
services run as root, while the frontend process typically runs as a separate
app user. Whoever creates `database.db-wal`/`-shm` first fixes their ownership
and mode (root → 0644), and the other user can then no longer write — so tip
writes (or even reads) fail in production despite correct WAL/busy_timeout
config. The docs (`FRONTEND_FUNKTIONS_SPEC.md`) already imply a shared
`football-betting:football-betting` owner under `/var/lib/football-betting`, but
the units don't implement it and point at `/opt/...` instead.

## Symptom (bugs only)
Under concurrent access by services running as different OS users, writes to the
shared WAL database intermittently fail with `attempt to write a readonly
database` / `unable to open database file` / `disk I/O error`, even though WAL
and `busy_timeout` are configured. The first process to create the `-wal`/`-shm`
files determines their ownership/mode; the other user then cannot write them.

## Scope
- **In scope**:
  - `betting-api/deploy/betting-api.service` — run as a shared service
    account, add `UMask=0002` (and `Group=`).
  - `macht-api/deploy/macht-api.service` — same `User=`/`Group=`/`UMask=0002`.
  - A documented, consistent DB directory + ownership convention so the dir is
    group-writable with setgid (e.g. `chmod 2775`, shared group), used by all
    three services; reconcile the `/opt` vs `/var/lib/football-betting` path
    mismatch between the units and `FRONTEND_FUNKTIONS_SPEC.md`.
  - Frontend deployment: document (and, if a unit/PM2 config exists, set) the
    same user/group so the Next.js writer shares ownership of the DB files.
  - Add `PRAGMA synchronous = NORMAL` on the writing connections
    (`frontend/lib/db.ts`, `macht-api` connection setup) — recommended with WAL,
    shortens fsync and therefore the write-lock hold time. (betting-api is
    read-only; optional there.)
  - Update `betting-api/deploy/README.md` + `macht-api/deploy/README.md` with the
    user/group/UMask + directory-permission setup steps.
- **Out of scope (explicit)**:
  - Any change to the SQLite concurrency logic already in place (WAL +
    `busy_timeout` stay as they are).
  - Moving off SQLite / introducing a DB server.
  - The macht-api import cadence (`OnCalendar=*:0/1`).

## References
- `betting-api/deploy/betting-api.service`, `betting-api/deploy/README.md`
- `macht-api/deploy/macht-api.service`, `macht-api/deploy/macht-api.timer`,
  `macht-api/deploy/README.md`
- `betting-api/src/db/mod.rs` (WAL + busy_timeout, read-only)
- `macht-api/src/api/match_client.rs` (`get_connection`, `persist_match`)
- `frontend/lib/db.ts` (WAL + busy_timeout pragmas)
- `docs/FRONTEND_FUNKTIONS_SPEC.md` (the `/var/lib/football-betting` owner note)
- `docs/TECH_ARCHITEKTUR.md`

## Acceptance Criteria
- [ ] Both Rust units declare a shared `User=`/`Group=` and `UMask=0002`; the
      frontend deployment is documented (or configured) to use the same group.
- [ ] The deploy READMEs describe creating the DB directory group-writable with
      setgid (e.g. `sudo chgrp football-betting <dir> && sudo chmod 2775 <dir>`)
      and a single canonical DB path (no `/opt` vs `/var/lib` mismatch).
- [ ] `frontend/lib/db.ts` and the macht-api writer connection set
      `PRAGMA synchronous = NORMAL`; betting-api unchanged in behaviour.
- [ ] Quality Gate passes in every touched repo:
  - Rust: `cargo clippy -- -D warnings && cargo test`
  - Next.js: `pnpm exec tsc --noEmit && pnpm exec vitest run`
- [ ] No application-logic change; WAL + `busy_timeout` remain intact.

## Verification (manual)
1. As **userA**, run a writer that creates the WAL files; as **userB** (the
   other service's account, sharing the group) run a writer against the same DB
   → both succeed; `ls -l` shows `-wal`/`-shm` group-owned and group-writable
   (mode `…rw-rw-…`).
2. Start all three services per the updated READMEs, submit a tip from the
   frontend while the macht-api timer fires → tip persists, no
   `readonly database` / `unable to open database file` in
   `journalctl -u betting-api -u macht-api` or the frontend logs.
3. `PRAGMA synchronous;` on a writer connection returns `1` (NORMAL).

## Notes (multi-repo only)
Implementation order:
1. `frontend/lib/db.ts` — add `PRAGMA synchronous = NORMAL`.
2. `macht-api` connection setup — add `PRAGMA synchronous = NORMAL`; update
   `macht-api/deploy/*.service` (`User`/`Group`/`UMask`) + `deploy/README.md`.
3. `betting-api/deploy/*.service` (`User`/`Group`/`UMask`) + `deploy/README.md`.
4. Reconcile the canonical DB path + directory-permission instructions across
   the deploy READMEs and `docs/FRONTEND_FUNKTIONS_SPEC.md`.

Open question to confirm before/while implementing: the exact OS user the
Next.js process runs as in production (or standardize all three on a dedicated
`football-betting` user/group, which is the documented intent).
