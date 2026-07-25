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

## Build system

Unlike the sibling stack-adapter libraries (which use a three-file DAG under
`build/`), zClip keeps a **single flat `build.zig`** — the library has fewer
build concerns (no external Zig dependencies, no optional shaderc/VMA), so a
multi-file split would add ceremony without benefit.

The `build.zig` structure:

| Section | What it does |
|---------|-------------|
| **Configuration constants** | File extensions (`c_suffix`, `cpp_suffix`), base directories (`path_to_c`, `path_to_cpp`), and compiler flags (`c_flags`, `cpp_flags`) |
| **Source discovery** | `getFilesFromDir()` — recursively walks a directory and returns all `.c`/`.cpp` files relative to the package root, so adding a new source file requires no build-script edits |
| **Module creation** | `b.addModule("zclip", ...)` — registers the public Zig API under the name a downstream `b.dependency("zclip", ...).module("zclip")` resolves |
| **Static library** | `b.addLibrary(.{ .name = "zclip", .linkage = .static })` — produces `zig-out/lib/libzclip.a`; downstream calls `linkLibrary` to pull in the Zig glue + any C/C++ objects |
| **Demo executable** | `demo` — a standalone binary (`src/main.zig`) that imports the module and links the artifact exactly as a consumer would |
| **Test targets** | `test` (refAllDecls), `test-tdd` (sprite + skeletal behavioural suite), `test-contract` (enum/struct layout) |

### Build steps

| Command | What it runs |
|---------|-------------|
| `zig build` | Build the static-library artifact (`zig-out/lib/libzclip.a`) |
| `zig build test` | Analyze + link the zclip module (refAllDecls) |
| `zig build test-tdd` | Run the TDD behavioural suite (sprite + skeletal) |
| `zig build test-contract` | Run contract tests (enum values / struct defaults / layout) |
| `zig build run` | Build + run the scaffold demo |

### Flags

- `-Dtarget=<triple>` — cross-compile target (default: host)
- `-Doptimize=<mode>` — Debug / ReleaseFast / ReleaseSafe / ReleaseSmall

### CI

```bash
./scripts/ci/ci.sh    # the full local CI gate (fmt + build + run + test)
```

Requires **Zig 0.16+**. The cgltf C backend (once vendored) is compiled in-tree
by Zig's bundled Clang frontend — no external C toolchain needed. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the FFI rules and C style.
