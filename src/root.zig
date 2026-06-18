//! zClip — the raw **animation library** for zGameLib.
//!
//! Two independent paths over a common asset story, both raw-first: the
//! framework (zGameLib) abstracts them into one unified animation API, but you
//! can drive either directly.
//!
//!  1. **sprite** — 2D sprite-sheet *atlas* animation: a clip is an ordered set
//!     of sub-rectangles ("frames") of a texture, played on a timeline.
//!  2. **skeletal** — *skeletal/skinned* animation loaded from **glTF** via
//!     `cgltf`: a joint hierarchy + sampled channels (TRS keyframes).
//!
//! Scaffold only — types/signatures are declared; bodies `@panic`. The cgltf C
//! backend is not vendored yet. See ../PLAN.md.

const std = @import("std");

/// glTF ingestion (cgltf binding). The skeletal path's loader; also usable on
/// its own to pull meshes/materials a renderer needs.
pub const gltf = @import("gltf.zig");

/// Path 1 — 2D sprite-sheet atlas animation.
pub const sprite = @import("sprite.zig");

/// Path 2 — skeletal/skinned animation (glTF-driven).
pub const skeletal = @import("skeletal.zig");

test {
    std.testing.refAllDecls(@This());
}
