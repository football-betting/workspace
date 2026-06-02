# XR-004 PM2 → systemd für die Rust-Services

## Repo
betting-api, macht-api (cross-repo)

## Type
chore

## Risk
low

## Priority
medium

> User (2026-06-02): „wir nutzen systemd nicht mehr pm2 für Rust."

## Status
in-progress

## Owner
implementer

## Background
Die Rust-Services laufen jetzt unter **systemd**, nicht mehr PM2. Die obsolete
PM2-Config (`betting-api/ecosystem.config.json`) ist tote Konfiguration und
referenziert zudem den **alten Binärnamen** `em2021_api` (heute `betting_api`).

## Scope
- **In scope**:
  - `betting-api/ecosystem.config.json` (PM2) **entfernen**.
  - Referenz-systemd-Units im Repo ablegen:
    - betting-api: `deploy/betting-api.service` (Dauer-Service, `Type=simple`,
      Binär `target/release/betting_api`, `EnvironmentFile=.env`, Restart, MemoryMax).
    - macht-api: `deploy/macht-api.service` (`Type=oneshot`, Binär
      `target/release/rust-api`) + `deploy/macht-api.timer` (jede Minute —
      ersetzt den bisherigen PM2/cron-Trigger).
  - Kurze `deploy/README.md` je Repo (install/enable-Schritte, Pfade als Beispiel).
- **Out of scope**: tatsächliche Server-Provisionierung; CI/CD; Binär-Umbenennung.

## Lockstep
- Koordinierte, getrennte PRs je Repo (betting-api + macht-api).

## Acceptance Criteria
- [ ] `betting-api/ecosystem.config.json` entfernt; keine PM2-Referenzen mehr.
- [ ] systemd-Units mit **korrektem Binärnamen** (`betting_api` / `rust-api`).
- [ ] macht-api-Timer triggert die oneshot-Importe (Minuten-Takt).
- [ ] `cargo build` beider Services unverändert grün (keine Code-Änderung).
- [ ] Kurze Deploy-Doku vorhanden.
