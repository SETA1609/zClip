# Security Policy — zClip

## Supported versions

Pre-1.0, single-maintainer library. Security fixes land on the **latest tagged
release + `main`** only; there are no long-term-support branches.

| Version | Supported |
| --- | --- |
| latest tag / `main` | ✅ |
| older tags | ❌ (upgrade to latest) |

## Reporting a vulnerability

**Please do not open a public issue for a security problem.** Report privately
via a **[GitHub Security Advisory on this repo](https://github.com/SETA1609/zClip/security/advisories/new)**.

Include: affected version / commit, platform (OS + toolchain), reproduction
steps, and impact. Expect a best-effort acknowledgement — this is a small
project.

## Scope / threat model

zClip is a small **C/C++/Zig hybrid library** linked into a host binary. It is
not network-facing. The realistic surface is the **cross-language FFI boundary**:

- C/C++ functions reached over the C ABI from Zig (`extern fn`) and vice versa.
- Any data passed across that boundary as pointer + length — a length/pointer
  mismatch is a memory-safety hazard, not a feature bug.
- A C++ exception must never propagate across the `extern "C"` boundary into
  Zig; bridge functions should be `noexcept` and catch before crossing.

## Upstream dependencies

zClip has **no external Zig dependencies** — the C/C++ translation units are
compiled in-tree by Zig's bundled Clang frontend. Toolchain vulnerabilities
belong to the [Zig project](https://github.com/ziglang/zig/security).

## Out of scope

Bugs that require an already-compromised process, or that live entirely in a
consumer's own code, are not vulnerabilities in this library.
