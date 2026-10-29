# Changelog

Last updated: 2026-10-29T00:17Z

Changes per issue, newest first. Issues are tracked in [issues.md](issues.md). Each PR adds its entry and updates the timestamp above. History before this file: `git log`.

## Unreleased

### Issue 2 Container devops CLI for contributors

Branch `issue-2-container-devops-cli`, stacked on Issue 1.

- Add `.zig-version` (`0.17.0`), checked against `ARG ZIG_VERSION` in the `Dockerfile`.
- Add `tools/devops/`, a host-side Python CLI (uv; standard library only at runtime). It runs the toolchain container with every output line timestamped and logged to `cache/logs/`.
- One shim: `./scripts/container.sh <subcommand>` with `image`, `build`, `test`, `zig`, `ci` (runs `scripts/ci.sh`), `tdd` (`zig build test-tdd`), `shell`, `prune`, and `clean`.
- A leading `--keep-cache` keeps the Zig global cache in the volume `zclip-zig-cache` until `clean`.
- `scripts/ci.sh` is unchanged and still runs without a container.

### Issue 1 Port to Zig 0.17.0

Branch `issue-1-port-to-zig-0.17.0`, based on `feat/animation-lib` (PR #1).

- `b.pathFromRoot` is removed in 0.17: source discovery uses a `pathFromBuildRoot` helper over `b.root.joinString`.
- `b.args` → `addPassthruArgs()`; enum `@typeInfo` `.fields` → `.field_names`/`.field_values`; `zig fmt` rewrites `@intFromEnum`/`@enumFromInt` to `@backingInt`/`@fromBackingInt`.
- `minimum_zig_version`, the Dockerfile, CI, README, and CONTRIBUTING say 0.17.0; `docs/cheat_sheet.md` lists the port changes.
- Checked in a Zig 0.17.0 container: `scripts/ci.sh` passes.
