# Issues — zClip

Each issue is one PR, on a branch `issue-<n>-<slug>`, with its changelog entry in `changes/issue-<n>.md`. Status is `todo`, `done (#pull-request)`, or `dropped`; statuses and new issues are edited only on bookkeeping branches. See *Releases* in [`docs/ROADMAP.md`](docs/ROADMAP.md).

---

## Issue 1 — Port to Zig 0.17.0

Status: done (#2)

Zig 0.17.0 removed `Build.pathFromRoot` and `Build.args`, and changed enum `@typeInfo` (`fields` → `field_names`/`field_values`), so the build script no longer compiles. Port the build, keep `scripts/ci.sh` green, and move the Dockerfile, CI, and docs to 0.17.0.

Done when: `scripts/ci.sh` passes on Zig 0.17.0.

---

## Issue 2 — Container devops CLI for contributors

Status: done (#3)

Contributors whose host Zig is not 0.17.0 need a pinned toolchain. Add a host-side CLI (`tools/devops/`, uv, standard library only at runtime) that runs the repo's Dockerfile image, timestamps and logs every output line to `cache/logs/`, and offers `image`, `build`, `test`, `zig`, `ci`, `tdd`, `shell`, `prune`, and `clean` through `./scripts/container.sh`. Add `.zig-version`.

Done when: `./scripts/container.sh ci` passes; the CLI's pytest and ruff checks pass.

---

## Issue 3 — Make the sprite path safe on untrusted and empty input

Status: todo

`docs/ROADMAP.md` treats assets as untrusted, but three paths in `src/sprite.zig` can abort or corrupt memory:

- `Atlas.parse` uses unchecked `.?` and direct union field access, so valid but unexpected JSON aborts instead of returning an error: `"duration":1` parses as an integer and panics on the `.float` access, and a missing key, a non-object root, or a float coordinate reach the same unchecked paths. In `ReleaseFast` these are undefined behaviour. The doc comment advertises TexturePacker output, whose nested `frame` objects and missing `duration` are not read. Support that shape, or stop advertising it. Reject negative durations.
- `Atlas.grid` multiplies `cols * rows` as unchecked `u32`. `65536 × 65536` panics in safe builds; in `ReleaseFast` it can wrap to a zero-length buffer that the loop then writes past.
- `Clip.frameAt` returns `undefined` for an empty clip, and a grid with 0 columns or `{"frames":[]}` produces one. Return `?Frame`, or reject empty clips where they are built.

Done when: tests cover each malformed JSON shape returning an error, an overflowing grid returning `error.Overflow`, and an empty clip giving no garbage frame, in Debug and `ReleaseFast`.

---

## Issue 4 — Handle clips whose total duration is zero

Status: todo

`Clip.frameAt` searches with a strict `target < accumulated`. When every frame has duration 0, the target is 0 and the comparison is never true, so phase 0 gives the first frame and every later phase gives the last. A NaN phase, which `dt / clip.duration` produces at zero duration, also lands on the last frame. Define the behaviour (for example, frames spaced evenly by phase) and handle NaN.

Done when: tests cover an all-zero-duration clip across phases and a NaN phase.

---

## Issue 5 — Make the declared skeletal API implementable

Status: todo

The signatures in `src/skeletal.zig` cannot be implemented as declared. `bakeJointPalette(skeleton, phase)` receives no `Clip`, so the phase cannot select a pose, and it has no allocator or error return for the `matrices` slice it must return. `Clip.sample(clip, phase, palette)` has no `Skeleton` for the hierarchy walk and writes through `JointPalette.matrices`, which is `[]const [16]f32`. Redesign the two so the sampled pose reaches the bake, update `docs/skeletal-animation.md` steps 4 and 5 and the contract tests, and do it before the v0.8.0 skeletal work.

Done when: a test using the new signatures compiles against stub bodies, and the docs describe one flow from sampling to the joint palette.

---

## Issue 6 — Make `-Dbackend` real and use descriptive names

Status: todo

- `-Dbackend` has no effect: nothing imports `build_config`, and C source discovery ignores the selected backend, so `-Dbackend=none` would still compile a vendored `cgltf.c`. `link_libc = true` is unconditional, which forces libc on consumers of the pure-Zig sprite path. Gate the C sources and libc on the backend.
- Replace the string option and `parseBackend` with `b.option(Backend, "backend", ...) orelse .none`, which validates the value and lists the choices in `zig build --help`. Remove the unused `Backend.all`.
- Rename the short names in `src/sprite.zig` and `build.zig` (`p`, `accum`, `n`, `cols`, `frame_w`, `b`, `opt`) to spelled-out ones before the public API is frozen.

Done when: `-Dbackend=none` builds with no C sources and no libc, an invalid value is reported by the option parser, and `scripts/ci.sh` passes.

---

## Issue 7 — Turn on the dev to main branch rules

Status: todo
Needs: —

`dev` is meant for first testing and `main` for releases, but issue branches currently merge straight into `main`. `dev` has `.github/workflows/branch-rules.yml`, and that version puts `github.head_ref` and `github.base_ref` directly into a shell script, so a crafted branch name can run commands in CI. Fix that first: pass both through `env` and move the check to `scripts/ci/check_branch_source.py`, as the platform adapter does.

The rest waits for a decision to gate `main` behind `dev`, because merging the check into `main` fails every pull request into `main` that does not come from `dev`. At that point, add `.github/workflows/rebase-branches.yml` and `scripts/ci/rebase-branches.sh`, matching `issue-<n>-<slug>` branches, retarget issue branches at `dev`, and update `CONTRIBUTING.md`.

Done when: `branch-rules.yml` expands no branch name inside a `run` block; once the flow starts, a pull request from an issue branch into `main` fails the check and one from `dev` passes.
