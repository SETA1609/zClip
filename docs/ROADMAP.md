# Roadmap — zClip

> The versioned plan for this library's public API surface. zClip is the
> **animation** lib of zGameLib: two playback paths — **sprite-atlas** and
> **skeletal** (glTF via cgltf) — over a uniform "pose at phase" contract.
> Raw-first: the framework abstracts it (`zgame.animation`), or drive it
> directly (`zgame.zclip`). Actionable breakdown: [`completion-plan.md`](completion-plan.md).

## Backend

The library's public API is backend-neutral; the backend (for the skeletal
path only) is an implementation detail behind it.

| Path | Backend | Status |
| --- | --- | --- |
| **sprite** (2D sheet atlas) | none — **pure Zig**, no dependency | **Planned** — lands at v0.6 |
| **skeletal** (glTF ingestion) | **cgltf** (single-header C, [jkuhlmann/cgltf](https://github.com/jkuhlmann/cgltf)), to be **vendored** and compiled in-tree by Zig's bundled Clang (links libc, no libc++) | **Planned** — cgltf vendored at v0.7, path live at v0.8 |

cgltf will be **vendored** (a `cgltf.h` header + a one-line `src/c/cgltf.c`
implementation TU), **not** added as a package dependency — there is no GPL/LGPL
anywhere. zClip is animation **data + sampling** — it does no rendering or
texture upload.

## Two paths by design

Both paths answer one question — *given a phase in `[0,1]`, what is the current
visual?* — and neither owns a clock. The timeline (looping, speed, ping-pong)
lives in the framework abstraction ([`../../../shared/animation.zig`](../../../shared/animation.zig)),
so one `Animator` drives either path identically:

- **sprite** — a sprite sheet is a set of frame sub-rectangles; a clip is an
  ordered sequence of frames with per-frame durations. Answers: *which frame
  rect?* Pure Zig, no asset backend.
- **skeletal** — a skeleton is a joint hierarchy + bind pose; a clip is sampled
  TRS channels per joint, loaded from glTF via cgltf. Answers: *what joint
  pose / matrix palette?*

Because no asset-format type crosses the public boundary (glTF/cgltf stay behind
`gltf.zig`), a consumer can swap a sprite clip for a skeletal one without
touching call sites. See [`mission.md`](mission.md).

## Version milestones

**Status:** `stable` = shipped & API-complete on `main` · `dev` = currently in
development · `planned` = not yet started. *(No git tags are cut yet — formal
tagging is part of the 1.0 hardening pass.)* The **Steps to cut this version**
column is the concrete, ordered work that earns the tag — ☑ a shipped patch, ☐
still open; shipped versions list the patches that got them there. House rule for
every box: a gated TDD session (red→green), one atomic commit per group, and the
CI gate (`fmt` + build + run + test) stays green. Fuller TDD detail:
[`completion-plan.md`](completion-plan.md).

**Patch convention:** each ☐ task is one **patch** release. Working a minor line
`v0.x`, the first task done tags `v0.x.1`, the second `v0.x.2`, and so on (one
atomic commit → one patch bump) — the `.N` prefix on each step is the patch it
produces. The minor line is **complete** when its last ☐ lands; the next
milestone opens the next minor. **v1.0.0 = both paths implemented + frozen.**

| Version | Features | Steps to cut this version | Status |
| --- | --- | --- | --- |
| **v0.1.0** | Foundation — repository + package manifest. | ☑ **.1** repo scaffold + MIT license + `.clang-format`. ☑ **.2** `build.zig.zon` package manifest. | stable |
| **v0.2.0** | Foundation — the libs-first build shell. | ☑ **.1** `build.zig`: expose the `zclip` **module** + the static-lib **artifact**. ☑ **.2** framework wiring — `zgame.zclip` raw re-export + the `zgame.animation` abstraction module. | stable |
| **v0.3.0** | Foundation — the public data types. | ☑ **.1** enums — `PlayMode` / `Interpolation` / `ChannelTarget` / `PathKind`. ☑ **.2** sprite types (`Rect`/`Frame`/`Atlas`/`Clip`) + skeletal types (`Joint`/`Skeleton`/`Clip`/`JointPalette`) declared. ☑ **.3** enum value maps ([`enum-values.md`](enum-values.md)). | stable |
| **v0.4.0** | Foundation — the declared API surface. | ☑ **.1** the full documented public API surface, panic-on-call (sprite + skeletal + gltf all declared so consumers can compile against it). | stable |
| **v0.5.0** | Foundation — the test & CI scaffold. | ☑ **.1** gated red→green TDD suite + harness (`src/tests/tdd/`). ☑ **.2** contract test (enum values / struct defaults / layout). ☑ **.3** CI gate — `fmt` + build + run + test on PRs to main. | stable |
| **v0.6.0** | **Sprite-atlas path live** (pure Zig, no deps): build atlases and play sprite clips on a phase. | ☑ **.1** `Atlas.grid` + explicit-rect atlases. ☑ **.2** `Clip.duration` + `Clip.frameAt(phase)`. ☑ **.3** `Atlas.parse` — JSON deserialisation for external atlas metadata. | stable |
| **v0.7.0** | **cgltf ingestion**: vendor the parser and load glTF into owned Zig structs. | ☐ **.1** vendor cgltf (`cgltf.h` + `src/c/cgltf.c` impl TU; build auto-discovers it). ☐ **.2** `gltf.zig` binding — `loadFile`/`loadMemory`/`free` → owned `Document`. ☐ **.3** surface skins / joints / animation samplers. | planned |
| **v0.8.0** | **Skeletal path live**: a skeleton + sampled channels become a joint palette. | ☐ **.1** `Skeleton` + `Joint` built from glTF (inverse-bind matrices, parent indices). ☐ **.2** channel sampling (`step`/`linear`/`cubic_spline`) → `JointPalette` via `sample()`. | planned |
| **v0.9.0** | **Framework Animator** unifying both paths (lands in [`../../../shared/animation.zig`](../../../shared/animation.zig)). | ☐ **.1** `PlayMode` + `Cursor` (advance / phase / reset). ☐ **.2** `Animator.current()` over a `sprite.Clip` **or** `skeletal.Clip` from one call site. | planned |
| **v1.0.0** | **Both paths implemented & frozen** — validated on the example apps; API frozen. | ☐ **.1** every app in [`validation-apps.md`](validation-apps.md) green. ☐ **.2** pin the vendored cgltf to a released version. ☐ **.3** **freeze the API** → tag **v1.0.0**. | planned |

Critical path: v0.6 (sprite, no deps) → v0.7 (cgltf) → v0.8 (skeletal) → v0.9
(unify in the framework) → v1.0. v0.1–v0.2 are the shipped foundation (build
shell + framework wiring) the paths are built on. Versions may resequence as the
consuming project's needs firm up.

## Design rules (non-negotiable)

The four rules that keep the two paths interchangeable and the asset backend
swappable:

1. **Data, not policy** — a path computes poses for a phase; it owns no clock.
   The timeline (loop / speed / ping-pong) lives in the framework's `Animator`.
2. **No asset-format types leak** — glTF / cgltf types stay behind `gltf.zig`;
   the public API is Zig types only.
3. **Uniform "pose at phase" contract** — both paths expose the same shape, so
   the framework `Animator` treats sprite and skeletal identically and a
   consumer swaps clip kinds without changing call sites.
4. **Assets are untrusted** — glTF inputs are validated (bounds, sizes,
   accessor offsets) before use.

## Out of scope / deferred

- **Rendering / texture upload** — zClip yields frame rects and joint palettes;
  the consumer's renderer draws them.
- **A full glTF importer** — only skins + animation channels are surfaced, not a
  complete mesh + PBR-material import.
- **Scene graph, audio, multi-track blend trees** — blend trees are a possible
  post-1.0 line; the rest is out of scope.
- **The timeline policy** — that is the framework's `Animator`, not this lib's.

## See also

- The framework abstraction: [`../../../shared/animation.zig`](../../../shared/animation.zig) (`zgame.animation`)
- Sibling libs: [zig-cpp-platform-stack-adapter](https://github.com/SETA1609/zig-cpp-platform-stack-adapter) · [zig-cpp-vulkan-stack-adapter](https://github.com/SETA1609/zig-cpp-vulkan-stack-adapter)
- Path to 1.0: [`completion-plan.md`](completion-plan.md) · Test apps: [`validation-apps.md`](validation-apps.md) · Why it exists: [`vision.md`](vision.md) / [`mission.md`](mission.md) · Deps: [`dependencies.md`](dependencies.md)
- Implementing more of the API: [`../CONTRIBUTING.md`](../CONTRIBUTING.md)
