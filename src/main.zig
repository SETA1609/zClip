const std = @import("std");
const zclip = @import("zclip");

// Zig 0.16 changed `main`: instead of grabbing globals like `std.io.getStdOut()`,
// the runtime hands you an `Init` struct that carries the I/O interface.
// `init.io` is what filesystem and stdio calls thread through.
pub fn main(init: std.process.Init) !void {
    const stdout = std.Io.File.stdout();
    try stdout.writeStreamingAll(init.io, "🚀 Hello from Zig! \n");
    zclip.greetC();
    zclip.greetCpp();
    try stdout.writeStreamingAll(init.io, "\n ✅ Success!\n");
}
