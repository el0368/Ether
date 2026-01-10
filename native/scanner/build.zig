const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/crawler.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "scanner_nif",
        .root_module = mod,
    });

    // Add C entry point shim
    lib.addCSourceFile(.{
        .file = b.path("src/entry.c"),
        .flags = &.{"-std=c11"},
    });

    // Include Erlang headers
    // We assume the user has Erlang installed in a standard location
    // or we'll need to pass this via an environment variable.
    lib.addIncludePath(.{ .cwd_relative = "C:\\Program Files\\Erlang OTP\\erts-16.2\\include" });

    lib.linkLibC();
    b.installArtifact(lib);
}
