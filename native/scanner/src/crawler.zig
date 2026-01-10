const std = @import("std");
const api = @import("api.zig");
const resource = @import("resource.zig");

pub const CHUNK_SIZE: usize = 250;
const w = std.os.windows;

// Exported for the C Entry shim (entry.c)
pub export fn zig_resource_destructor(env: ?*api.ErlNifEnv, obj: ?*anyopaque) void {
    _ = env;
    if (obj) |ptr| {
        const res: *resource.ScannerResource = @ptrCast(@alignCast(ptr));
        res.deinit(std.heap.c_allocator);
    }
}

pub export fn zig_scan_yieldable(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    _ = env;
    _ = argc;
    _ = argv;
    _ = nif_api;
    // Real implementation follows in Phase 2
    return 0; // enif_make_int(env, 0) - raw value 0 is usually an atom or int in BEAM internal
}
