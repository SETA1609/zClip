//! glTF document loading for zClip's skeletal animation path.
//!
//! Wraps [cgltf](https://github.com/jkuhlmann/cgltf) (once vendored) to load
//! glTF 2.0 files from disk or memory. Currently a stub — all functions panic.
//!
//! The `Document` owns the loaded data; call `free` to release it.

const std = @import("std");

pub const Document = struct {
    data: []u8,
};

pub fn loadFile(allocator: std.mem.Allocator, path: []const u8) !Document {
    _ = allocator;
    _ = path;
    @panic("TODO");
}

pub fn loadMemory(allocator: std.mem.Allocator, data: []const u8) !Document {
    _ = allocator;
    _ = data;
    @panic("TODO");
}

pub fn free(doc: *Document, allocator: std.mem.Allocator) void {
    _ = doc;
    _ = allocator;
    @panic("TODO");
}
