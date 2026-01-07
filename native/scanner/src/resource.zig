//! Resource Module: BEAM Resource Handles (ADR-017)
//! Enables persistent native state managed by Erlang GC

const std = @import("std");
const api = @import("api.zig");

/// ScannerResource: Persistent native state
/// Future: Add search index, file watchers, cached state here
pub const ScannerResource = struct {
    created_at: i64,
    is_active: bool,
    pool: std.Thread.Pool,
    stack: std.ArrayListUnmanaged([]const u8), // Stack of directories for re-entrant scanning
    total_count: usize, // Track total files found
};

/// Resource destructor - called by BEAM GC when Elixir drops the reference
pub export fn zig_resource_destructor(env: ?*api.ErlNifEnv, obj: *anyopaque) void {
    _ = env;
    const resource: *ScannerResource = @ptrCast(@alignCast(obj));
    if (resource.is_active) {
        resource.is_active = false;
        resource.pool.deinit();
    }

    // Clean up stack
    const allocator = std.heap.c_allocator;
    for (resource.stack.items) |path| {
        allocator.free(path);
    }
    resource.stack.deinit(allocator);
    // Note: The BEAM will free the resource memory after this returns
}

/// Create a new resource context
pub export fn zig_create_context(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    _ = argc;
    _ = argv;

    const resource_ptr = nif_api.alloc_resource(@sizeOf(ScannerResource)) orelse {
        return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "alloc_failed"));
    };

    const resource: *ScannerResource = @ptrCast(@alignCast(resource_ptr));
    resource.created_at = std.time.timestamp();
    resource.is_active = true;
    resource.stack = .{}; // Initialize empty stack
    resource.total_count = 0; // Reset count

    // Initialize Thread Pool (Level 6)
    // Use c_allocator for long-lived thread resources
    // If pool fails to init (out of memory), we return error tuple
    resource.pool.init(.{ .allocator = std.heap.c_allocator }) catch {
        // Optimization: If pool alloc fails, we should probably fail the NIF
        // Release the resource as we are aborting
        nif_api.release_resource(resource_ptr);
        return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "pool_init_failed"));
    };

    const term = nif_api.make_resource(env, resource_ptr);
    nif_api.release_resource(resource_ptr);

    return nif_api.make_tuple2(env, nif_api.make_atom(env, "ok"), term);
}

/// Close a resource context explicitly
pub export fn zig_close_context(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 1) return nif_api.make_badarg(env);

    var resource_ptr: ?*anyopaque = null;
    if (nif_api.get_resource(env, argv[0], &resource_ptr) == 0) {
        return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "invalid_resource"));
    }

    const resource: *ScannerResource = @ptrCast(@alignCast(resource_ptr.?));
    if (resource.is_active) {
        resource.is_active = false;
        resource.pool.deinit();
    }

    return nif_api.make_atom(env, "ok");
}
