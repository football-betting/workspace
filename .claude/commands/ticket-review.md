---
description: Hand a finished ticket over to review
argument-hint: <ticket-id>
---

Move ticket `$ARGUMENTS` to review.

1. Find the ticket file for `$ARGUMENTS` in `tickets/backlog/in-progress/`. If nothing matches, stop and list what *is* in `in-progress/`.
2. Check the Definition of Done from `.claude/CLAUDE.md`: Quality Gate green in every touched repo, every acceptance criterion met, no `.unwrap()` introduced on Rust production paths, no `any` in new TypeScript, no AI-attribution lines in commits. If anything is open, stop and list it — do not move the ticket.
3. Move the file to `tickets/backlog/review/`.
4. Confirm it is ready for review and note whether an external review is required (`Risk: high`).
