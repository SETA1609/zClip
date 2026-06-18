// This script is the entire build system for the project. Running `zig build`
// invokes the `build` function at the bottom; everything above it is
// configuration and helpers. If you only know CMake/Make: `build.zig` is
// played as the role of `CMakeLists.txt`, but written in plain Zig instead
// of a custom DSL.
//
// To customize the build, you usually only need to touch the constants
// directly below: where the C/C++ sources live and which compiler flags
// to use.

const std = @import("std");

// --- Configuration --------------------------------------------------------
// File extensions used to identify compilation units. Headers (.h, .hpp)
// are intentionally not listed: they are #included by .c/.cpp files and
// must NOT be passed to the compiler as standalone inputs.
const c_suffix = ".c";
const cpp_suffix = ".cpp";

// Where the script looks for sources. Anything ending in `c_suffix` under
// `path_to_c` is compiled as C; anything ending in `cpp_suffix` under
// `path_to_cpp` is compiled as C++. Subdirectories are walked recursively,
// so e.g. `src/c/util/foo.c` is picked up automatically.
const path_to_c = "src/c";
const path_to_cpp = "src/cpp";

// Compiler flags forwarded to Zig's bundled Clang frontend. `++` is Zig's
// compile-time array-concatenation operator, so `c_flags` ends up as
// {"-std=c23", "-Wall", "-Wextra", "-pedantic"}.
const base_flags = [_][]const u8{ "-Wall", "-Wextra", "-pedantic" };
const c_flags = [_][]const u8{"-std=c23"} ++ base_flags;
// Bump this when Zig's bundled Clang gains better C++26 support.
const cpp_flags = [_][]const u8{"-std=c++23"} ++ base_flags;

// --- Source discovery -----------------------------------------------------

/// Returns true if `file` ends with any of the given `extensions`.
/// Used by `getFilesFromDir` to keep only translation units (.c/.cpp).
fn containsSuffix(
    file: []const u8,
    extensions: []const []const u8,
) bool {
    for (extensions) |extension| if (std.mem.endsWith(u8, file, extension)) return true;
    return false;
}

/// Recursively walks `scan_dir` (an absolute path) and returns, for every
/// regular file whose name ends in one of `extensions`, a path of the form
/// `rel_dir/<entry>` — relative to the package root.
///
/// Two paths are needed because the build can run from a different cwd than
/// this package: when zClip is consumed as a dependency, cwd is the parent's
/// build root. So we *open* the directory via its absolute path (`scan_dir =
/// b.pathFromRoot(rel_dir)`) but return *package-relative* paths, which is
/// what `addCSourceFiles` resolves against its `root` (the package root).
///
/// `io` is Zig's I/O interface (introduced in 0.16's "color-blind async"
/// refactor). Every filesystem call now takes it explicitly. In a build
/// script the value comes from `b.graph.io`.
///
/// The returned slice and its strings are owned by `allocator`. In the
/// build script we use `b.allocator`, which lives for the duration of the
/// build, so we never explicitly free them.
fn getFilesFromDir(
    io: std.Io,
    allocator: std.mem.Allocator,
    scan_dir: []const u8,
    rel_dir: []const u8,
    extensions: []const []const u8,
) ![]const []const u8 {
    // A missing source dir is not an error — the lib may be pure Zig until the
    // cgltf C backend is vendored. Treat it as "no sources" rather than panic.
    var dir = std.Io.Dir.cwd().openDir(io, scan_dir, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => return &.{},
        else => return err,
    };
    defer dir.close(io);
    var walker = try dir.walk(allocator);
    defer walker.deinit();
    // 0.16 unified ArrayList around the unmanaged form: initialize with
    // `.empty` and pass the allocator to each mutating call.
    var list: std.ArrayList([]const u8) = .empty;
    errdefer list.deinit(allocator);

    while (try walker.next(io)) |entry| {
        if (entry.kind == .file and containsSuffix(entry.path, extensions)) {
            // `entry.path` is relative to the walked dir, so prepend
            // `rel_dir` to get a path relative to the package root.
            const full_path = try std.fs.path.join(allocator, &.{ rel_dir, entry.path });
            try list.append(allocator, full_path);
        }
    }
    return list.toOwnedSlice(allocator);
}

// --- Build entry point ----------------------------------------------------
// `zig build` calls this function once. It does not compile anything
// directly — instead it describes a graph of build steps (compile, link,
// install, run) that Zig then executes in dependency order.
//
// zClip is consumed as a library by zGameLib (the libs-first / link-the-
// artifact model). This script produces two things downstream depends on:
//   1. A Zig module named "zclip" (the public API in src/root.zig).
//   2. A static-library artifact named "zclip" that bundles the compiled
//      Zig glue plus any C translation units (the cgltf backend, once vendored).
// Downstream imports the module and `linkLibrary` the artifact. A standalone
// `demo` (built from src/main.zig, importing the module like a consumer would)
// is kept for `zig build run`.
pub fn build(b: *std.Build) void {
    // Target triple (CPU/OS/ABI). Defaults to the host. Override on the
    // command line, e.g. `zig build -Dtarget=x86_64-windows`.
    const target = b.standardTargetOptions(.{});

    // Optimization mode. Defaults to Debug. Override with
    // `-Doptimize=ReleaseFast | ReleaseSafe | ReleaseSmall`.
    const optimize = b.standardOptimizeOption(.{});

    // Discover C and C++ sources at build-script run time instead of
    // listing them by hand. Drop a new file into `src/c/` or `src/cpp/`
    // (or any subdirectory of those) and it gets picked up automatically
    // on the next `zig build`. Failure to read the directory is fatal —
    // there is no useful recovery in a build script, so we panic.
    // Open dirs by absolute path (`pathFromRoot`) so discovery works even when
    // this package builds as a dependency (cwd is then the parent's build root).
    const c_sources = getFilesFromDir(b.graph.io, b.allocator, b.pathFromRoot(path_to_c), path_to_c, &.{c_suffix}) catch |err|
        std.debug.panic("Failed to scan {s}: {s}", .{ path_to_c, @errorName(err) });
    const cpp_sources = getFilesFromDir(b.graph.io, b.allocator, b.pathFromRoot(path_to_cpp), path_to_cpp, &.{cpp_suffix}) catch |err|
        std.debug.panic("Failed to scan {s}: {s}", .{ path_to_cpp, @errorName(err) });

    // Public Zig API. `addModule` registers it under the name "zclip" so
    // downstream `b.dependency("zclip", ...).module("zclip")` resolves it.
    // Any C translation units (the cgltf backend, once vendored) are compiled
    // into this module, so their `extern` symbols resolve at link time. libc
    // is linked for the C backend; cgltf is C, so no libc++.
    const zclip_mod = b.addModule("zclip", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // Hand the C sources to Zig's bundled Clang-based C frontend. No
    // external C compiler is required.
    zclip_mod.addCSourceFiles(.{
        .files = c_sources,
        .flags = &c_flags,
    });

    // Same for C++. Each C++ function called from Zig must be declared
    // `extern "C"` in its .cpp file, otherwise its symbol gets C++
    // name-mangled and Zig's `extern fn` won't find it at link time.
    zclip_mod.addCSourceFiles(.{
        .files = cpp_sources,
        .flags = &cpp_flags,
    });

    // Static-library artifact. Downstream `linkLibrary` on this pulls in the
    // compiled Zig glue and the bundled C/C++ objects.
    const zclip_lib = b.addLibrary(.{
        .name = "zclip",
        .linkage = .static,
        .root_module = zclip_mod,
    });
    b.installArtifact(zclip_lib);

    // --- `zig build run` ----------------------------------------------------
    // A standalone demo that imports the module and links the artifact exactly
    // as a downstream consumer would.
    const demo_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    demo_mod.addImport("zclip", zclip_mod);
    demo_mod.linkLibrary(zclip_lib);

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_module = demo_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the demo application");
    run_step.dependOn(&run_cmd.step);

    // --- `zig build test` ---------------------------------------------------
    // Analyze + link the public module (refAllDecls in src/root.zig).
    const mod_tests = b.addTest(.{ .root_module = zclip_mod });
    b.step("test", "Analyze + link the zclip module")
        .dependOn(&b.addRunArtifact(mod_tests).step);
}
