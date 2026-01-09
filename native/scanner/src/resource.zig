//! Resource Module: BEAM Resource Handles (ADR-017)
//! Enables persistent native state managed by Erlang GC

const std = @import("std");
const api = @import("api.zig");

/// StackEntry: Holds a directory path and its depth in the tree
pub const StackEntry = struct {
    path: []const u8,
    depth: u8,
};

/// ScannerResource: Persistent native state
/// Future: Add search index, file watchers, cached state here
pub const ScannerResource = struct {
    created_at: i64,
    is_active: bool,
    pool: std.Thread.Pool,
    stack: std.ArrayListUnmanaged(StackEntry), // Stack of directories for re-entrant scanning
    ignore_patterns: std.ArrayListUnmanaged([]u8), // List of patterns to ignore
    total_count: usize, // Track total files found
};

/// Resource destructor - called by BEAM GC when Elixir drops the reference
pub export fn zig_resource_destructor(env: ?*api.ErlNifEnv, obj: *anyopaque) void {
    _ = env;
    const res: *ScannerResource = @ptrCast(@alignCast(obj));
    if (res.is_active) {
        res.is_active = false;
        res.pool.deinit();
    }

    // Clean up stack
    const allocator = std.heap.c_allocator;
    for (res.stack.items) |entry| {
        allocator.free(entry.path);
    }
    res.stack.deinit(allocator);

    // Clean up ignore patterns
    for (res.ignore_patterns.items) |pattern| {
        allocator.free(pattern);
    }
    res.ignore_patterns.deinit(allocator);

    // Note: The BEAM will free the resource memory after this returns
}

/// Create a new resource context
pub export fn zig_create_context(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 1) return nif_api.make_badarg(env);

    const resource_ptr = nif_api.alloc_resource(@sizeOf(ScannerResource)) orelse {
        return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "alloc_failed"));
    };

    const resource: *ScannerResource = @ptrCast(@alignCast(resource_ptr));
    resource.created_at = std.time.timestamp();
    resource.is_active = true;
    resource.stack = .{}; // Initialize empty stack
    resource.total_count = 0; // Reset count
    resource.ignore_patterns = .{};

    // Parse Ignore List
    const allocator = std.heap.c_allocator;
    const ignore_list = argv[0];
    var list_len: c_uint = 0;

    if (nif_api.get_list_length(env, ignore_list, &list_len) != 0) {
        var head: api.ERL_NIF_TERM = undefined;
        var tail: api.ERL_NIF_TERM = ignore_list;

        while (nif_api.get_list_cell(env, tail, &head, &tail) != 0) {
            var bin: api.ErlNifBinary = undefined;
            if (nif_api.inspect_binary(env, head, &bin) != 0) {
                const pattern = allocator.dupe(u8, bin.data[0..bin.size]) catch {
                    // Cleanup on failure
                    nif_api.release_resource(resource_ptr);
                    return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "alloc_failed"));
                };
                resource.ignore_patterns.append(allocator, pattern) catch {
                    allocator.free(pattern);
                    nif_api.release_resource(resource_ptr);
                    return nif_api.make_tuple2(env, nif_api.make_atom(env, "error"), nif_api.make_atom(env, "alloc_failed"));
                };
            }
        }
    }

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
