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
