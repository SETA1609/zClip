# Contributing — zClip

Thanks for your interest! This is a standalone, single-maintainer Zig library.
Please read this before opening a PR so we're aligned on scope.

## What this library is

zClip is the **animation library** of zGameLib (see [`PLAN.md`](PLAN.md)): the
raw building blocks for two animation paths — sprite-atlas and skeletal (glTF
via cgltf). Zig is the public surface (`src/root.zig`); the cgltf C backend is
compiled in-tree by Zig's bundled Clang frontend and reached over the C ABI. It
exposes a Zig module (`zclip`) and a static-library artifact (`zclip`), consumed
by zGameLib under its libs-first / link-the-artifact model. The timeline /
playback abstraction lives in the framework, not here.

## Source layout

```
src/
├── root.zig     # public Zig API (the `zclip` module): re-exports the paths
├── gltf.zig     # cgltf binding (glTF ingestion)
├── sprite.zig   # path 1: sprite-atlas
├── skeletal.zig # path 2: skeletal-from-glTF
├── main.zig     # standalone demo — imports the module like a consumer would
└── c/           # *.c files — auto-discovered, compiled with -std=c23 (cgltf)
```

`build.zig` auto-discovers `src/c/*.c` (and `src/cpp/*.cpp` if you add any) and
links libc on the next build — no manifest to update.

## Cross-language FFI rules

These are load-bearing for the cgltf binding — get them wrong and it fails at
link time or corrupts memory at runtime:

- **C called from Zig** is resolved by symbol name via `extern fn`; **Zig called
  from C** must be marked `export fn`.
- **C-compatible types only across the ABI.** Slices (`[]T`) are not
  ABI-compatible — pass pointer + length as separate args; stick to `i32`,
  `*T`, etc.
- If any C++ is ever added, a bridge `extern "C"` function must be `noexcept`
  and catch before returning into Zig (no exceptions across the boundary), and
  link libc++ in `build.zig`.

## C style

Google conventions, max **C++23**, encoded in [`.clang-format`](.clang-format).
Run `clang-format` on any C/C++ you add and keep `zig fmt --check .` green for
the Zig side.

## Dev setup

- **Zig 0.16+** (the build uses post-0.16 APIs).
- `zig build` — build the artifact; `zig build run` — build + run the demo;
  `zig build test` — analyze + link the `zclip` module.
- **`./scripts/ci/ci.sh`** runs the exact CI gate locally (fmt + build + run +
  test) — the workflow just installs Zig and calls this same script.
- **Reproducible container:** `docker build -t zclip .` then
  `docker run --rm zclip` runs that gate in a clean image.

## Licensing & legal

- Contributions are licensed under this repo's **MIT** license. By submitting a
  PR you agree to license your contribution under MIT. **No CLA required.**
- **No GPL / LGPL / AGPL dependencies — ever.**
- Don't copy code from LGPL/GPL projects. Reimplement from understanding.

## Commits & PRs

- **Conventional Commits** (`feat:` / `fix:` / `docs:` / `chore:` / `ci:` /
  `test:`), atomic — one concern per commit, subject ≤ 72 chars.
- Small fixes: open a PR directly. Larger work: **open an issue first.**
