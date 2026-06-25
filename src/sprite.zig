const std = @import("std");

pub const PlayMode = enum(u2) {
    once,
    loop,
    ping_pong,
};

pub const Rect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};

pub const Frame = struct {
    rect: Rect,
    duration: f32,
};

pub const Atlas = struct {
    frames: []const Frame,

    pub fn grid(allocator: std.mem.Allocator, cols: u32, rows: u32, frame_w: f32, frame_h: f32, total_duration: f32) !Atlas {
        const count = cols * rows;
        const frames = try allocator.alloc(Frame, count);
        const per_frame = if (count > 0) total_duration / @as(f32, @floatFromInt(count)) else 0;
        for (0..rows) |row| {
            for (0..cols) |col| {
                const i = row * cols + col;
                frames[i] = .{
                    .rect = .{
                        .x = @as(f32, @floatFromInt(col)) * frame_w,
                        .y = @as(f32, @floatFromInt(row)) * frame_h,
                        .w = frame_w,
                        .h = frame_h,
                    },
                    .duration = per_frame,
                };
            }
        }
        return .{ .frames = frames };
    }

    pub fn parse(allocator: std.mem.Allocator, json_data: []const u8) !Atlas {
        var tree = try std.json.parseFromSlice(std.json.Value, allocator, json_data, .{});
        defer tree.deinit();
        const root = tree.value;
        const frames_arr = root.object.get("frames").?.array;
        const n = frames_arr.items.len;
        const frames = try allocator.alloc(Frame, n);
        for (frames_arr.items, 0..) |item, i| {
            const obj = item.object;
            frames[i] = .{
                .rect = .{
                    .x = @floatFromInt(obj.get("x").?.integer),
                    .y = @floatFromInt(obj.get("y").?.integer),
                    .w = @floatFromInt(obj.get("w").?.integer),
                    .h = @floatFromInt(obj.get("h").?.integer),
                },
                .duration = @floatCast(obj.get("duration").?.float),
            };
        }
        return .{ .frames = frames };
    }

    pub fn deinit(atlas: *Atlas, allocator: std.mem.Allocator) void {
        allocator.free(atlas.frames);
        atlas.* = undefined;
    }
};

pub const Clip = struct {
    frames: []const Frame,
    duration: f32,

    pub fn init(frames: []const Frame) Clip {
        var total: f32 = 0;
        for (frames) |f| total += f.duration;
        return .{ .frames = frames, .duration = total };
    }

    pub fn frameAt(clip: Clip, phase: f32) Frame {
        const p = std.math.clamp(phase, 0, 1);
        if (clip.frames.len == 0) return undefined;
        if (clip.frames.len == 1 or p <= 0) return clip.frames[0];
        const target = p * clip.duration;
        var accum: f32 = 0;
        for (clip.frames) |frame| {
            accum += frame.duration;
            if (target < accum) return frame;
        }
        return clip.frames[clip.frames.len - 1];
    }
};
