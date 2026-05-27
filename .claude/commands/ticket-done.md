---
description: Close a reviewed ticket and write its result document
argument-hint: <ticket-id>
---

Close ticket `$ARGUMENTS`.

1. Find the ticket file for `$ARGUMENTS` in `tickets/backlog/review/`. If nothing matches, stop and list what *is* in `review/`.
2. Confirm the review passed. For `Risk: high` tickets, confirm an external review was carried out. If either is missing, stop.
3. Move the file to `tickets/backlog/done/`.
4. Write a result document to `tickets/results/<ticket-id>_<ticket-slug>.md` with: what was done, which files changed (group by repo), Quality Gate / test result. Keep it factual and short.
5. Confirm the ticket is closed.
