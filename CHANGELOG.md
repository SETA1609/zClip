# Changelog

Last updated: 2026-10-29T00:17Z

Changes per issue, newest first. Issues are tracked in [issues.md](issues.md). Each PR adds its entry and updates the timestamp above. History before this file: `git log`.

## Unreleased

### Issue 1 Port to Zig 0.17.0

Branch `issue-1-port-to-zig-0.17.0`, based on `feat/animation-lib` (PR #1).

- `b.pathFromRoot` is removed in 0.17: source discovery uses a `pathFromBuildRoot` helper over `b.root.joinString`.
- `b.args` → `addPassthruArgs()`; enum `@typeInfo` `.fields` → `.field_names`/`.field_values`; `zig fmt` rewrites `@intFromEnum`/`@enumFromInt` to `@backingInt`/`@fromBackingInt`.
- `minimum_zig_version`, the Dockerfile, CI, README, and CONTRIBUTING say 0.17.0; `docs/cheat_sheet.md` lists the port changes.
- Checked in a Zig 0.17.0 container: `scripts/ci.sh` passes.
