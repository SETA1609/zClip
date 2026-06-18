# Contributing — zClip

Thanks for your interest! This is a standalone, single-maintainer Zig library.
Please read this before opening a PR so we're aligned on scope.

## What this library is

zClip is a small **C/C++/Zig hybrid** library: Zig is the public surface
(`src/root.zig`), with C and C++ translation units compiled in-tree by Zig's
bundled Clang frontend and reached over the C ABI. It exposes a Zig module
(`zclip`) and a static-library artifact (`zclip`), consumed by zGameLib under
its libs-first / link-the-artifact model.

## Source layout

```
src/
├── root.zig    # public Zig API (the `zclip` module)
├── main.zig    # standalone demo — imports the module like a consumer would
├── c/          # *.c files — auto-discovered, compiled with -std=c23
└── cpp/         # *.cpp files — auto-discovered, compiled with -std=c++23
```

Drop a new `.c`/`.cpp` anywhere under `src/c/` or `src/cpp/` — `build.zig`
discovers it on the next build. No manifest to update.

## Cross-language FFI rules

These are load-bearing — get them wrong and it fails at link time or corrupts
memory at runtime:

- **C++ called from Zig** must be declared `extern "C"` in the `.cpp`, or C++
  name-mangling hides the symbol from Zig's `extern fn`.
- **Zig called from C/C++** must be marked `export fn`.
- **No exceptions across the boundary.** A bridge `extern "C"` function must be
  `noexcept` and catch before returning into Zig.
- **C-compatible types only across the ABI.** Slices (`[]T`) are not
  ABI-compatible — pass pointer + length as separate args; stick to `i32`,
  `*T`, etc.

## C++ style

Google conventions, max **C++23**, encoded in [`.clang-format`](.clang-format)
(`BasedOnStyle: Google`, `Standard: Latest`). Run `clang-format` on any C/C++
you add and keep `zig fmt --check .` green for the Zig side. Do not use
language features past C++23.

## Dev setup

- **Zig 0.16+** (the build uses post-0.16 APIs).
- `zig build` — build the artifact; `zig build run` — build + run the demo;
  `zig build test` — analyze + link the `zclip` module.
- **`./scripts/ci.sh`** runs the exact CI gate locally (fmt + build + run +
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
