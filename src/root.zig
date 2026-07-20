//! zClip — animation library for zGameLib.
//!
//! Provides three sub-modules:
//! - `gltf` — glTF document loading (skeletal animation input)
//! - `sprite` — 2D sprite-atlas frame-by-frame animation
//! - `skeletal` — skinned/skeletal animation data types
//!
//! Re-exports key types from each sub-module at the top level for convenience.

const std = @import("std");

pub const gltf = @import("gltf.zig");
pub const sprite = @import("sprite.zig");
pub const skeletal = @import("skeletal.zig");

pub const PlayMode = sprite.PlayMode;
pub const PathKind = skeletal.PathKind;
pub const Interpolation = skeletal.Interpolation;
pub const ChannelTarget = skeletal.ChannelTarget;

test {
    std.testing.refAllDecls(@This());
}
