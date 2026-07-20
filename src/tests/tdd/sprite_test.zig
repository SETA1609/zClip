const std = @import("std");
const zclip = @import("zclip");
const sprite = zclip.sprite;
const testing = std.testing;

test "PlayMode variants exist" {
    _ = sprite.PlayMode.once;
    _ = sprite.PlayMode.loop;
    _ = sprite.PlayMode.ping_pong;
}

test "Atlas.grid creates correct number of frames" {
    var atlas = try sprite.Atlas.grid(testing.allocator, 4, 3, 32, 32, 0.5);
    defer atlas.deinit(testing.allocator);
    try testing.expectEqual(atlas.frames.len, 12);
}

test "Atlas.grid frame positions" {
    var atlas = try sprite.Atlas.grid(testing.allocator, 2, 2, 16, 16, 0.4);
    defer atlas.deinit(testing.allocator);
    try testing.expectEqual(atlas.frames[0].rect.x, 0);
    try testing.expectEqual(atlas.frames[0].rect.y, 0);
    try testing.expectEqual(atlas.frames[1].rect.x, 16);
    try testing.expectEqual(atlas.frames[1].rect.y, 0);
    try testing.expectEqual(atlas.frames[2].rect.x, 0);
    try testing.expectEqual(atlas.frames[2].rect.y, 16);
}

test "Atlas.grid frame durations equal total / count" {
    var atlas = try sprite.Atlas.grid(testing.allocator, 4, 3, 32, 32, 1.2);
    defer atlas.deinit(testing.allocator);
    try testing.expectEqual(atlas.frames[0].duration, 0.1);
    try testing.expectEqual(atlas.frames[5].duration, 0.1);
    try testing.expectEqual(atlas.frames[11].duration, 0.1);
}

test "Clip.init computes duration correctly" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 0, .y = 0, .w = 32, .h = 32 }, .duration = 0.2 },
        .{ .rect = .{ .x = 32, .y = 0, .w = 32, .h = 32 }, .duration = 0.3 },
        .{ .rect = .{ .x = 64, .y = 0, .w = 32, .h = 32 }, .duration = 0.5 },
    };
    const clip = sprite.Clip.init(&frames);
    try testing.expectEqual(clip.duration, 1.0);
    try testing.expectEqual(clip.frames.len, 3);
}

test "Clip.frameAt phase 0 returns first frame" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 0, .y = 0, .w = 16, .h = 16 }, .duration = 0.2 },
        .{ .rect = .{ .x = 16, .y = 0, .w = 16, .h = 16 }, .duration = 0.8 },
    };
    const clip = sprite.Clip.init(&frames);
    const f = clip.frameAt(0);
    try testing.expectEqual(f.rect.x, 0);
}

test "Clip.frameAt phase 1 returns last frame" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 0, .y = 0, .w = 16, .h = 16 }, .duration = 0.2 },
        .{ .rect = .{ .x = 16, .y = 0, .w = 16, .h = 16 }, .duration = 0.8 },
    };
    const clip = sprite.Clip.init(&frames);
    const f = clip.frameAt(1);
    try testing.expectEqual(f.rect.x, 16);
}

test "Clip.frameAt maps phase to correct frame" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 0, .y = 0, .w = 10, .h = 10 }, .duration = 0.2 },
        .{ .rect = .{ .x = 10, .y = 0, .w = 10, .h = 10 }, .duration = 0.3 },
        .{ .rect = .{ .x = 20, .y = 0, .w = 10, .h = 10 }, .duration = 0.5 },
    };
    const clip = sprite.Clip.init(&frames);
    try testing.expectEqual(clip.frameAt(0.0).rect.x, 0);
    try testing.expectEqual(clip.frameAt(0.1).rect.x, 0);
    try testing.expectEqual(clip.frameAt(0.2).rect.x, 10);
    try testing.expectEqual(clip.frameAt(0.4).rect.x, 10);
    try testing.expectEqual(clip.frameAt(0.5).rect.x, 20);
    try testing.expectEqual(clip.frameAt(0.7).rect.x, 20);
    try testing.expectEqual(clip.frameAt(1.0).rect.x, 20);
}

test "Clip.frameAt single-frame clip" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 5, .y = 5, .w = 32, .h = 32 }, .duration = 1.0 },
    };
    const clip = sprite.Clip.init(&frames);
    const f0 = clip.frameAt(0);
    const f1 = clip.frameAt(0.5);
    const f2 = clip.frameAt(1);
    try testing.expectEqual(f0.rect.x, 5);
    try testing.expectEqual(f1.rect.x, 5);
    try testing.expectEqual(f2.rect.x, 5);
}

test "Clip.frameAt clamps phase" {
    const frames = [_]sprite.Frame{
        .{ .rect = .{ .x = 0, .y = 0, .w = 8, .h = 8 }, .duration = 0.5 },
        .{ .rect = .{ .x = 8, .y = 0, .w = 8, .h = 8 }, .duration = 0.5 },
    };
    const clip = sprite.Clip.init(&frames);
    try testing.expectEqual(clip.frameAt(-0.5).rect.x, 0);
    try testing.expectEqual(clip.frameAt(1.5).rect.x, 8);
}

test "Atlas.parse basic JSON" {
    const json =
        \\{"frames":[
        \\  {"x":0,"y":0,"w":64,"h":64,"duration":0.1},
        \\  {"x":64,"y":0,"w":64,"h":64,"duration":0.1},
        \\  {"x":0,"y":64,"w":64,"h":64,"duration":0.2}
        \\]}
    ;
    var atlas = try sprite.Atlas.parse(testing.allocator, json);
    defer atlas.deinit(testing.allocator);
    try testing.expectEqual(atlas.frames.len, 3);
    try testing.expectEqual(atlas.frames[0].rect.w, 64);
    try testing.expectEqual(atlas.frames[2].duration, 0.2);
}

test "Atlas.deinit frees memory" {
    var atlas = try sprite.Atlas.grid(testing.allocator, 1, 1, 10, 10, 1.0);
    atlas.deinit(testing.allocator);
}

test "Atlas.grid with zero rows returns empty" {
    var atlas = try sprite.Atlas.grid(testing.allocator, 4, 0, 32, 32, 0);
    defer atlas.deinit(testing.allocator);
    try testing.expectEqual(atlas.frames.len, 0);
}
