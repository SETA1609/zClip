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
        _ = allocator;
        _ = cols;
        _ = rows;
        _ = frame_w;
        _ = frame_h;
        _ = total_duration;
        @panic("TODO");
    }

    pub fn parse(allocator: std.mem.Allocator, json_data: []const u8) !Atlas {
        _ = allocator;
        _ = json_data;
        @panic("TODO");
    }

    pub fn deinit(atlas: *Atlas, allocator: std.mem.Allocator) void {
        _ = atlas;
        _ = allocator;
        @panic("TODO");
    }
};

pub const Clip = struct {
    frames: []const Frame,
    duration: f32,

    pub fn init(frames: []const Frame) Clip {
        _ = frames;
        @panic("TODO");
    }

    pub fn frameAt(clip: Clip, phase: f32) Frame {
        _ = clip;
        _ = phase;
        @panic("TODO");
    }
};
