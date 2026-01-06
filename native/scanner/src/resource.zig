//! Resource Module: BEAM Resource Handles (ADR-017)
//! Enables persistent native state managed by Erlang GC

const std = @import("std");
const api = @import("api.zig");

/// ScannerResource: Persistent native state
/// Future: Add search index, file watchers, cached state here
pub const ScannerResource = struct {
    created_at: i64,
    is_active: bool,
};

/// Resource destructor - called by BEAM GC when Elixir drops the reference
pub export fn zig_resource_destructor(env: ?*api.ErlNifEnv, obj: *anyopaque) void {
    _ = env;
    const resource: *ScannerResource = @ptrCast(@alignCast(obj));
    resource.is_active = false;
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
    resource.is_active = false;

    return nif_api.make_atom(env, "ok");
}
