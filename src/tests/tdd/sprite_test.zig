const std = @import("std");
const zclip = @import("zclip");
const sprite = zclip.sprite;
const testing = std.testing;

test "PlayMode enum variants exist" {
    _ = sprite.PlayMode.once;
    _ = sprite.PlayMode.loop;
    _ = sprite.PlayMode.ping_pong;
}

test "Rect fields" {
    const r = sprite.Rect{ .x = 0, .y = 0, .w = 64, .h = 64 };
    try testing.expectEqual(r.x, 0);
    try testing.expectEqual(r.w, 64);
}

test "Frame fields" {
    const r = sprite.Rect{ .x = 0, .y = 0, .w = 32, .h = 32 };
    const f = sprite.Frame{ .rect = r, .duration = 0.1 };
    try testing.expectEqual(f.duration, 0.1);
}

test "Atlas type exists" {
    const atlas: sprite.Atlas = .{ .frames = &.{} };
    _ = atlas;
}

test "Clip type exists" {
    const clip: sprite.Clip = .{ .frames = &.{}, .duration = 1.0 };
    try testing.expectEqual(clip.duration, 1.0);
}
