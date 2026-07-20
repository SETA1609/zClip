//! Standalone demo entry point for zClip.
//!
//! Imports the `zclip` module just as a downstream consumer would, verifying
//! that the module links and the public symbols resolve. Currently prints a
//! version banner — the actual demo is pending v0.6+ implementation.

const std = @import("std");
const zclip = @import("zclip");

pub fn main(init: std.process.Init) !void {
    const stdout = std.Io.File.stdout();
    try stdout.writeStreamingAll(init.io, "zClip — animation library v0.6.0\n");

    _ = zclip.sprite;
    _ = zclip.skeletal;
    _ = zclip.gltf;
}
