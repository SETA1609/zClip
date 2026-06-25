const std = @import("std");

/// How a clip advances through its frames. Used by the framework's `Animator`;
/// the raw `Clip` path treats phase as an opaque position in `[0, 1]` and
/// delegates playback policy to the caller.
pub const PlayMode = enum(u2) {
    once,
    loop,
    ping_pong,
};

/// An axis-aligned rectangle in pixel space.
pub const Rect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};

/// A single frame of a sprite animation: which sub-rectangle of the texture
/// to show, and how long (in seconds) it should be visible.
pub const Frame = struct {
    rect: Rect,
    duration: f32,
};

/// A collection of frames describing a sprite sheet. Owns its frame data —
/// call `deinit` to free.
///
/// Create one programmatically with `grid`, or load from external metadata
/// (texture-packer JSON) with `parse`.
pub const Atlas = struct {
    frames: []const Frame,

    /// Build an atlas from an evenly-spaced grid of frames.
    ///
    /// `cols` × `rows` frames are laid out left-to-right, top-to-bottom.
    /// Each frame gets an equal share of `total_duration`.
    /// Returns an empty atlas when either dimension is zero.
    ///
    /// The caller owns the returned atlas and must call `deinit` to free it.
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

    /// Parse an atlas from a JSON string in the zClip frame-list format:
    ///
    /// ```json
    /// {"frames":[
    ///   {"x":0, "y":0, "w":64, "h":64, "duration":0.1},
    ///   {"x":64,"y":0, "w":64, "h":64, "duration":0.1}
    /// ]}
    /// ```
    ///
    /// Each entry describes one frame: `x`, `y`, `w`, `h` are the sub-rectangle
    /// on the texture atlas (in pixels), and `duration` is the time in seconds.
    ///
    /// The caller owns the returned atlas and must call `deinit` to free it.
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

    /// Free the frame data owned by this atlas.
    /// The atlas is set to undefined after the call — do not use it again.
    pub fn deinit(atlas: *Atlas, allocator: std.mem.Allocator) void {
        allocator.free(atlas.frames);
        atlas.* = undefined;
    }
};

/// An ordered sequence of frames that forms a playable animation clip.
///
/// The clip stores a reference to the caller's frame slice and pre-computes
/// the total duration. Use `frameAt(phase)` to get the frame for a given
/// playback position in `[0, 1]`.
pub const Clip = struct {
    frames: []const Frame,
    duration: f32,

    /// Create a clip from an ordered slice of frames.
    ///
    /// `duration` is automatically computed as the sum of all per-frame
    /// durations. The clip borrows the frames slice — the caller must keep
    /// it alive for the clip's lifetime.
    pub fn init(frames: []const Frame) Clip {
        var total: f32 = 0;
        for (frames) |f| total += f.duration;
        return .{ .frames = frames, .duration = total };
    }

    /// Return the frame at playback position `phase` in `[0, 1]`.
    ///
    /// Phase is clamped to the valid range. The clip's frame list is walked
    /// linearly, accumulating durations until `phase * duration` is reached.
    /// An empty clip returns `undefined`; a single-frame clip always returns
    /// that frame.
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
