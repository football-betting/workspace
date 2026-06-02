#!/usr/bin/env bash
# Frontend quality gate in one command.
#   bash scripts/check.sh           -> tsc + vitest
#   bash scripts/check.sh --build   -> tsc + vitest + next build
#   bash scripts/check.sh --e2e     -> Playwright E2E suite ONLY (separate gate)
#
# The --e2e mode is intentionally separate from tsc/vitest: it boots an isolated
# stand on its own ports (frontend :3100 + a real betting-api :8090, both on
# ../shared/db/test.db, never the shared DB) via playwright.config.ts. It needs
# the Rust toolchain (the betting-api webServer runs `cargo run`) and installed
# browsers (`pnpm exec playwright install chromium`). It can run alongside a
# regular `next dev` because it uses its own build dir (NEXT_DIST_DIR=.next-e2e).
set -euo pipefail
cd "$(dirname "$0")/../frontend"

if [ "${1:-}" = "--e2e" ]; then
  echo "▶ playwright test (isolated test.db stand)"
  pnpm exec playwright test
  echo "✓ e2e green"
  exit 0
fi

echo "▶ tsc --noEmit"
pnpm exec tsc --noEmit

echo "▶ vitest run"
pnpm exec vitest run

if [ "${1:-}" = "--build" ]; then
  echo "▶ next build"
  pnpm build
fi

echo "✓ gate green"
