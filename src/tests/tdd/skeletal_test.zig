const std = @import("std");
const zclip = @import("zclip");
const skeletal = zclip.skeletal;
const testing = std.testing;

test "Interpolation enum variants exist" {
    _ = skeletal.Interpolation.step;
    _ = skeletal.Interpolation.linear;
    _ = skeletal.Interpolation.cubic_spline;
}

test "ChannelTarget enum variants exist" {
    _ = skeletal.ChannelTarget.translation;
    _ = skeletal.ChannelTarget.rotation;
    _ = skeletal.ChannelTarget.scale;
    _ = skeletal.ChannelTarget.weights;
}

test "PathKind enum variants exist" {
    _ = skeletal.PathKind.sprite;
    _ = skeletal.PathKind.skeletal;
}

test "Joint fields" {
    const ibm = [16]f32{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
    const j = skeletal.Joint{ .name = "root", .parent = null, .inverse_bind_matrix = ibm };
    try testing.expectEqualStrings(j.name, "root");
    try testing.expectEqual(j.parent, null);
}

test "Skeleton type exists" {
    const skel: skeletal.Skeleton = .{ .joints = &.{} };
    _ = skel;
}

test "Clip type exists" {
    const clip: skeletal.Clip = .{ .duration = 1.0, .channels = &.{} };
    try testing.expectEqual(clip.duration, 1.0);
}

test "JointPalette type exists" {
    const pal: skeletal.JointPalette = .{ .matrices = &.{} };
    _ = pal;
}

test "Sampler fields" {
    const s = skeletal.Sampler{ .interpolation = .linear, .input = &.{}, .output = &.{} };
    try testing.expectEqual(s.interpolation, skeletal.Interpolation.linear);
}

test "Channel fields" {
    const sampler = skeletal.Sampler{ .interpolation = .step, .input = &.{}, .output = &.{} };
    const ch = skeletal.Channel{ .joint_index = 0, .sampler = sampler, .target = .translation };
    try testing.expectEqual(ch.joint_index, 0);
    try testing.expectEqual(ch.target, skeletal.ChannelTarget.translation);
}
