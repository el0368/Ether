const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for the Zig source (Hybrid Shim)
    const mod = b.createModule(.{
        .root_source_file = b.path("src/scanner_safe.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add C source file (Shim)
    mod.addCSourceFile(.{
        .file = b.path("src/entry.c"),
        .flags = &.{},
    });

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "scanner_nif",
        .root_module = mod,
    });

    // Add Erlang Includes
    if (b.option([]const u8, "erl_include", "Path to Erlang include directory")) |path| {
        mod.addIncludePath(.{ .cwd_relative = path });
    } else {
        // Fallback for local dev if not passed by Mix
        mod.addIncludePath(.{ .cwd_relative = "C:\\Program Files\\Erlang OTP\\erts-16.2\\include" });
        // NOTE: In production/automation, this should always be passed by the Mix task.
    }

    lib.linkLibC();

    b.installArtifact(lib);
}
