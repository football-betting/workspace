# Open questions & follow-ups

Pending decisions and small fixes parked for later. Address before the new
`frontend` repo gets serious work.

## From the `.claude/` review

### 1. `.unwrap()` rule wording in CLAUDE.md
- **State**: `CLAUDE.md` says absolute "No `.unwrap()` in Rust production paths".
  `reviewer.md` says "newly introduced". Existing Rust repos are full of `.unwrap()`.
- **Decision needed**: Soften CLAUDE.md to "newly introduced" (grandfathered)
  OR file refactor tickets to remove existing `.unwrap()` calls over time.
- **Suggested fix**: Soften now, file cleanup tickets later if desired.

### 2. README setup step doesn't match reality
- **State**: README step 2 says "clone the three service repos". But
  `betting-api/` and `macht-api/` are already present, and `frontend/` is
  an empty `.git`-only stub.
- **Decision needed**: Rewrite step to "ensure all three repos are present;
  skip any already cloned", OR explicitly describe the current state as the
  starting point.

### 3. Style-fix hook still handles `.astro`
- **State**: `.claude/hooks/style-fix.sh` includes `*.astro` in the prettier
  branch. This is legacy from `em2024-frontend/` and harmless (silent fail
  if `prettier-plugin-astro` is missing).
- **Decision needed**: Remove once `em2024-frontend/` is fully retired from
  the workspace folder.

## From earlier setup discussion

### 4. Move `em2024-frontend/` into `archive/`?
- **Current**: Archived on GitHub, still sits at workspace root locally.
- **Option A**: Move to `archive/em2024-frontend/` for clearer separation.
- **Option B**: Leave as-is — it's gitignored anyway and easy to delete
  later.

### 5. Initial commit of the workspace repo
- **State**: `.claude/`, `docs/`, `tickets/`, `README.md`, `.gitignore` all
  untracked. `git status` shows everything as new.
- **Action**: `git add . && git commit -m "chore: bootstrap workspace"`
  whenever you're happy with the structure.

### 6. MCP server permissions in `settings.local.json.example`
- **Current**: Only `context7` listed for library docs.
- **If you use** Postgres-MCP, GitHub-MCP, Linear-MCP etc., add their tool
  names to `permissions.allow`.

### 7. Optional `deny` list
- **Current**: No `deny` in permissions. Defaults to "ask" for unmatched.
- **Consider** denying outright:
  - `Bash(git push --force*)` (force push to main)
  - `Bash(git push --no-verify*)` (skips confidentiality-check hook!)
  - `Bash(rm -rf /:*)` (obvious)
  - `Bash(cargo install*)` (modifies global Cargo state)

### 8. Statusline / output-style customisation
- **Current**: defaults.
- **Optional**: Configure via `/statusline` in Claude Code if you want
  custom info (current branch, ticket-id, etc.) in the prompt.

## Notes

- These are not blockers. The setup is functional as-is.
- Revisit this file after the first ticket lands in the new `frontend` repo.
