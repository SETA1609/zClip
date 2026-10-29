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

zClip is the **animation library** linked into a host binary. It is not
network-facing. The realistic surface is **asset parsing + the FFI boundary**:

- **glTF parsing** (via cgltf) of potentially untrusted `.gltf`/`.glb` files —
  the main attack surface: malformed/oversized inputs, out-of-bounds indices,
  integer overflow in buffer/accessor offsets. Treat asset files as untrusted.
- The **cgltf C backend** reached over the C ABI from Zig: a length/pointer
  mismatch across that boundary is a memory-safety hazard, not a feature bug.

## Upstream dependencies

zClip's only third-party code is **cgltf** (vendored, compiled in-tree by Zig's
bundled Clang frontend). Parser vulnerabilities in cgltf itself should be
reported to [cgltf upstream](https://github.com/jkuhlmann/cgltf); once fixed,
zClip bumps its vendored copy. Toolchain issues belong to the
[Zig project](https://github.com/ziglang/zig/security).

## Out of scope

Bugs that require an already-compromised process, or that live entirely in a
consumer's own code, are not vulnerabilities in this library.
