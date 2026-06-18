//! zClip — public Zig API.
//!
//! This is the module downstream consumers import (registered as "zclip" in
//! build.zig). The C/C++ translation units under src/c and src/cpp are compiled
//! into this module's library artifact, so the `extern` symbols below resolve
//! at link time. See build.zig for the libs-first / link-the-artifact model.

const std = @import("std");

// C/C++ entry points, reached over the C ABI. The C++ side is declared
// `extern "C"` in its .cpp so its symbol isn't name-mangled.
extern fn greetFromC() c_int;
extern fn greetFromCpp() void;

/// Print the greeting from the C translation unit.
pub fn greetC() void {
    _ = greetFromC();
}

/// Print the greeting from the C++ translation unit.
pub fn greetCpp() void {
    greetFromCpp();
}

test {
    std.testing.refAllDecls(@This());
}
