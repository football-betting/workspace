#!/usr/bin/env bash
# Move a backlog ticket through its lifecycle, or show where it is.
#   bash scripts/ticket.sh <ID> <todo|in-progress|review|done>   -> git mv it
#   bash scripts/ticket.sh <ID>                                  -> print current status
# Example: bash scripts/ticket.sh FE-031 in-progress
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ID="${1:?usage: ticket.sh <ID> [todo|in-progress|review|done]}"

SRC="$(find "$ROOT/tickets/backlog" -type f -name "${ID}_*.md" | head -1)"
[ -n "$SRC" ] || { echo "ticket $ID not found under tickets/backlog/" >&2; exit 1; }

if [ -z "${2:-}" ]; then
  echo "$ID is in: $(basename "$(dirname "$SRC")")/"
  exit 0
fi

TO="$2"
case "$TO" in
  todo|in-progress|review|done) ;;
  *) echo "invalid status: $TO (todo|in-progress|review|done)" >&2; exit 1 ;;
esac

DEST="$ROOT/tickets/backlog/$TO/$(basename "$SRC")"
if [ "$SRC" = "$DEST" ]; then
  echo "$ID already in $TO/"
  exit 0
fi
git -C "$ROOT" mv "$SRC" "$DEST"
echo "$ID -> $TO/"
