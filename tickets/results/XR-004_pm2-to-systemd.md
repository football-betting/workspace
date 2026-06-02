# XR-004 Result — PM2 → systemd für die Rust-Services

**Geschlossen**: 2026-06-02
**Commits**: betting-api (main) `ef75047 (#5)` · macht-api (master) `e654335 (#4)`

## Was wurde gemacht
- **betting-api**: obsolete PM2-`ecosystem.config.json` entfernt (referenzierte
  zudem den alten Binärnamen `em2021_api`). Referenz-systemd-Unit
  `deploy/betting-api.service` (Dauer-Service, `target/release/betting_api`,
  EnvironmentFile, Restart, MemoryMax) + `deploy/README.md`.
- **macht-api**: `deploy/macht-api.service` (`Type=oneshot`,
  `target/release/rust-api`) + `deploy/macht-api.timer` (Minuten-Takt,
  `OnCalendar=*:0/1`) + `deploy/README.md`. macht-api ist ein oneshot-Importer
  → Timer statt Dauer-Service.

## Verifikation
- Binärnamen korrekt (`betting_api`, `rust-api`).
- `cargo build --release` (betting-api) grün — keine Code-Änderung.

## Quality-Gate
- Reine Deploy-Config (keine App-Logik). Self-Review.
