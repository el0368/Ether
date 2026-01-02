const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for the C source
    // root_source_file is optional (can be null if only C sources)
    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    
    // Add C source file
    mod.addCSourceFile(.{
        .file = b.path("src/scanner.c"),
        .flags = &.{}, 
                         // Note: might need "-std=c11" or similar if defaults are strict
                         // But usually defaults rely on extensions which is good for erl_nif
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
        mod.addIncludePath(.{ .cwd_relative = "C:\\Program Files\\Erlang OTP\\erts-16.2\\include" });
    }

    lib.linkLibC();
    b.installArtifact(lib);
}
