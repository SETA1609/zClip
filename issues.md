# Issues — zClip

Each issue is one PR. Status is `todo`, `doing`, `review`, `done`, or `dropped`. The changelog entry for an issue uses its number.

---

## Issue 1 — Port to Zig 0.17.0

Status: review

Zig 0.17.0 removed `Build.pathFromRoot` and `Build.args`, and changed enum `@typeInfo` (`fields` → `field_names`/`field_values`), so the build script no longer compiles. Port the build, keep `scripts/ci.sh` green, and move the Dockerfile, CI, and docs to 0.17.0.

Done when: `scripts/ci.sh` passes on Zig 0.17.0.

---

## Issue 2 — Container devops CLI for contributors

Status: review

Contributors whose host Zig is not 0.17.0 need a pinned toolchain. Add a host-side CLI (`tools/devops/`, uv, standard library only at runtime) that runs the repo's Dockerfile image, timestamps and logs every output line to `cache/logs/`, and offers `image`, `build`, `test`, `zig`, `ci`, `tdd`, `shell`, `prune`, and `clean` through `./scripts/container.sh`. Add `.zig-version`.

Done when: `./scripts/container.sh ci` passes; the CLI's pytest and ruff checks pass.
