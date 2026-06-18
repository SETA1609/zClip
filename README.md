# zClip

The **animation library** of [zGameLib](../../README.md) — a raw, single-purpose
lib (same tier as the platform/vulkan adapters) that the framework abstracts
into a unified animation API.

> **Status:** scaffold. The foundation is in place — the `zclip` module +
> static-lib artifact build and are wired into zGameLib (`zgame.zclip` raw +
> `zgame.animation` abstraction) — but both playback paths are doc-only stubs:
> types declared, bodies unimplemented, cgltf not yet vendored. Sprite-atlas is
> the next path (v0.6), skeletal follows (v0.7–v0.8). See the per-version plan in
> [`docs/ROADMAP.md`](docs/ROADMAP.md) and [`PLAN.md`](PLAN.md).

## Two paths

zClip drives animation two ways over a common asset story. Neither owns timeline
logic — that lives in the framework abstraction
([`shared/animation.zig`](../../shared/animation.zig)); each path just answers
"given a phase, what is the current visual?".

1. **Sprite-atlas** (`src/sprite.zig`) — 2D frame-by-frame from a sprite sheet.
2. **Skeletal** (`src/skeletal.zig`) — skinned/skeletal animation loaded from
   **glTF** via [cgltf](https://github.com/jkuhlmann/cgltf) (`src/gltf.zig`).

## Consuming it

zClip exposes a Zig module (`zclip`) and a static-library artifact (`zclip`),
wired into zGameLib under the libs-first / link-the-artifact model. Through the
framework you reach the raw lib as `zgame.zclip` and the abstraction as
`zgame.animation`.

## Build

```bash
zig build          # build the static-library artifact
zig build run      # build + run the scaffold demo
zig build test     # analyze + link the zclip module
./scripts/ci.sh    # the full local CI gate (fmt + build + run + test)
```

Requires **Zig 0.16+**. The cgltf C backend (once vendored) is compiled in-tree
by Zig's bundled Clang frontend — no external C toolchain needed. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the FFI rules and C style.
