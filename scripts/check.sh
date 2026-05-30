#!/usr/bin/env bash
# Frontend quality gate in one command.
#   bash scripts/check.sh           -> tsc + vitest
#   bash scripts/check.sh --build   -> tsc + vitest + next build
set -euo pipefail
cd "$(dirname "$0")/../frontend"

echo "▶ tsc --noEmit"
pnpm exec tsc --noEmit

echo "▶ vitest run"
pnpm exec vitest run

if [ "${1:-}" = "--build" ]; then
  echo "▶ next build"
  pnpm build
fi

echo "✓ gate green"
