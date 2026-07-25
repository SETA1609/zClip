#!/usr/bin/env bash
# The CI gate, runnable locally — the same checks .github/workflows/build.yml
# runs (it just installs the Zig toolchain, then calls this).
#   ./scripts/ci/ci.sh     # fmt + build + run demo + module test
set -uo pipefail
cd "$(dirname "$0")/.."

echo "== zig fmt --check =="
zig fmt --check build.zig build.zig.zon src || exit 1
echo "== zig build =="
zig build || exit 1
echo "== zig build run (demo) =="
zig build run || exit 1
echo "== zig build test (module) =="
zig build test || exit 1
echo "== zig build test-tdd (behavioural) =="
zig build test-tdd || exit 1
echo "== zig build test-contract (enum values / layout) =="
zig build test-contract || exit 1
echo "ok: all green"
