#!/usr/bin/env bash
#
# PostToolUse hook (Edit|Write): runs the right formatter for the file that
# was just created or edited. Stack-aware: .rs → rustfmt, .ts/.tsx/.astro/
# .js/.jsx/.json/.md/.css → prettier (using the nearest package.json).
#
# Silent on tool-missing — formatting is best-effort, never blocks Claude.
#
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

case "$file" in
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$file" 2>/dev/null || true
    ;;

  *.ts|*.tsx|*.js|*.jsx|*.astro|*.json|*.md|*.css|*.html|*.yaml|*.yml)
    # Walk up from file looking for the nearest package.json.
    # Use that package's prettier (local devDep) so config is picked up.
    dir=$(dirname "$file")
    while [ "$dir" != "/" ] && [ ! -f "$dir/package.json" ]; do
      dir=$(dirname "$dir")
    done

    if [ -f "$dir/package.json" ] && [ -x "$dir/node_modules/.bin/prettier" ]; then
      (cd "$dir" && ./node_modules/.bin/prettier --write --log-level=silent "$file" 2>/dev/null) || true
    fi
    ;;

  *)
    # Unknown extension — nothing to do.
    ;;
esac

exit 0
