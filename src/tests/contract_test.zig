const std = @import("std");
const zclip = @import("zclip");
const sprite = zclip.sprite;
const skeletal = zclip.skeletal;
const testing = std.testing;

test "PlayMode discriminants are stable" {
    try testing.expectEqual(@intFromEnum(sprite.PlayMode.once), 0);
    try testing.expectEqual(@intFromEnum(sprite.PlayMode.loop), 1);
    try testing.expectEqual(@intFromEnum(sprite.PlayMode.ping_pong), 2);
}

test "Interpolation discriminants are stable" {
    try testing.expectEqual(@intFromEnum(skeletal.Interpolation.step), 0);
    try testing.expectEqual(@intFromEnum(skeletal.Interpolation.linear), 1);
    try testing.expectEqual(@intFromEnum(skeletal.Interpolation.cubic_spline), 2);
}

test "ChannelTarget discriminants are stable" {
    try testing.expectEqual(@intFromEnum(skeletal.ChannelTarget.translation), 0);
    try testing.expectEqual(@intFromEnum(skeletal.ChannelTarget.rotation), 1);
    try testing.expectEqual(@intFromEnum(skeletal.ChannelTarget.scale), 2);
    try testing.expectEqual(@intFromEnum(skeletal.ChannelTarget.weights), 3);
}

test "PathKind discriminants are stable" {
    try testing.expectEqual(@intFromEnum(skeletal.PathKind.sprite), 0);
    try testing.expectEqual(@intFromEnum(skeletal.PathKind.skeletal), 1);
}

test "Rect layout" {
    const r = sprite.Rect{ .x = 1.0, .y = 2.0, .w = 3.0, .h = 4.0 };
    try testing.expectEqual(r.x, 1.0);
    try testing.expectEqual(r.y, 2.0);
    try testing.expectEqual(r.w, 3.0);
    try testing.expectEqual(r.h, 4.0);
}

test "Frame defaults" {
    const r = sprite.Rect{ .x = 0, .y = 0, .w = 16, .h = 16 };
    const f = sprite.Frame{ .rect = r, .duration = 0.05 };
    try testing.expectEqual(f.duration, 0.05);
    try testing.expectEqual(f.rect.w, 16);
}

test "Joint defaults" {
    const ibm = [16]f32{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
    const j = skeletal.Joint{ .name = "hip", .parent = null, .inverse_bind_matrix = ibm };
    try testing.expectEqual(j.parent, null);
    try testing.expectEqual(j.inverse_bind_matrix[0], 1);
    try testing.expectEqual(j.inverse_bind_matrix[5], 1);
    try testing.expectEqual(j.inverse_bind_matrix[10], 1);
    try testing.expectEqual(j.inverse_bind_matrix[15], 1);
}

test "Atlas can be empty" {
    const atlas = sprite.Atlas{ .frames = &.{} };
    try testing.expectEqual(atlas.frames.len, 0);
}

test "Skeleton can be empty" {
    const skel = skeletal.Skeleton{ .joints = &.{} };
    try testing.expectEqual(skel.joints.len, 0);
}

test "Clip sprite can be empty" {
    const clip = sprite.Clip{ .frames = &.{}, .duration = 0 };
    try testing.expectEqual(clip.frames.len, 0);
    try testing.expectEqual(clip.duration, 0);
}

test "Clip skeletal can be empty" {
    const clip = skeletal.Clip{ .duration = 0, .channels = &.{} };
    try testing.expectEqual(clip.channels.len, 0);
    try testing.expectEqual(clip.duration, 0);
}
