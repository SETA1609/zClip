# zClip — plan

> Status: **scaffold**. Structure and docs only — no implementation yet. This
> file is the source of truth for what zClip is and how it gets built out.

## What zClip is

zClip is the **animation library** of [zGameLib](../../README.md). It is a raw,
single-purpose lib in the same tier as the platform and vulkan adapters: it
provides the building blocks, and the framework abstracts them (see
[`shared/animation.zig`](../../shared/animation.zig)). Consumers reach the raw
lib as `zgame.zclip` and the framework abstraction as `zgame.animation`.

It exposes a Zig module (`zclip`) and a static-library artifact (`zclip`); the C
backend (cgltf) is compiled in-tree by Zig's bundled Clang frontend.

## Two paths

zClip drives animation two ways over a common asset story. Neither path owns
timeline logic — that lives in the framework abstraction; each path only answers
"given a phase in `[0,1]`, what is the current visual?".

1. **Sprite-atlas** (`src/sprite.zig`) — 2D frame-by-frame animation. A sheet is
   a grid/list of frame sub-rectangles; a clip is an ordered sequence of frames
   with per-frame durations. Answers: *which frame rect?*

2. **Skeletal** (`src/skeletal.zig`) — skinned/skeletal animation loaded from
   **glTF** via cgltf (`src/gltf.zig`). A skeleton is a joint hierarchy + bind
   pose; a clip is sampled TRS channels per joint. Answers: *what joint pose /
   matrix palette?*

## cgltf integration (planned)

The skeletal path parses glTF with [cgltf](https://github.com/jkuhlmann/cgltf),
a single-header C parser. Build-out steps:

1. Vendor `cgltf.h` (e.g. under `vendor/cgltf/`) and add a one-line impl TU
   `src/c/cgltf.c` (`#define CGLTF_IMPLEMENTATION` + `#include "cgltf.h"`). The
   build already auto-discovers `src/c/*.c` and links libc, so dropping the file
   in is enough — no `build.zig` edit needed.
2. Add the include path for the vendored header to the `zclip` module.
3. Flesh out `src/gltf.zig` as the Zig binding (load file → owned structs;
   surface skins/joints/samplers).

## Layout

```
src/
├── root.zig      # public API: re-exports the two paths + gltf
├── gltf.zig      # cgltf binding (glTF ingestion)   [scaffold]
├── sprite.zig    # path 1: sprite-atlas             [scaffold]
├── skeletal.zig  # path 2: skeletal-from-glTF       [scaffold]
└── main.zig      # standalone demo (zig build run)
```

## Build-out order

1. Shared cursor/playback policy in the framework (`shared/animation.zig`):
   `PlayMode`, `Cursor`, the unified `Animator`.
2. Sprite-atlas path end-to-end (no external deps) — the simplest path first.
3. Vendor cgltf; implement `gltf.zig` loading.
4. Skeletal path: skeleton + sampled channels → joint palette.
5. Wire both into the framework `Animator` so a consumer swaps clip types
   without changing call sites.

---

# The consuming project — `prototype`

zClip's first consumer is **prototype** (repo root), a **top-down action RPG**
blending: the dungeon/overworld feel of *Zelda: A Link to the Past*, the
open-world/sim depth of *Daggerfall*, the farming/life-sim loop of *Stardew
Valley*, and the crafting/alchemy systems of the *Atelier* games.

The sprite-atlas path serves the 2D top-down characters/tiles; the skeletal path
is available for richer glTF-driven animation where it fits. Project-level
design docs will be generated later and live in the prototype repo.
