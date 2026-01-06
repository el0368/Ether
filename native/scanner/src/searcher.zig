const std = @import("std");
const api = @import("api.zig");
const allocator = @import("allocator.zig");
const resource = @import("resource.zig");

pub const SearchOptions = struct {
    case_sensitive: bool,
    max_results: u32,
};

/// Main search entry point
pub export fn zig_search(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 3) return nif_api.make_badarg(env);

    // 1. Validate Context
    var ctx_ptr: ?*anyopaque = undefined;
    if (nif_api.get_resource(env, argv[0], &ctx_ptr) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_resource");
    }
    const ctx: *resource.ScannerResource = @ptrCast(@alignCast(ctx_ptr));

    // 2. Validate Query
    var query_bin: api.ErlNifBinary = undefined;
    if (nif_api.inspect_binary(env, argv[1], &query_bin) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_query");
    }
    const query = query_bin.data[0..query_bin.size];

    // 3. Validate Path
    var path_bin: api.ErlNifBinary = undefined;
    if (nif_api.inspect_binary(env, argv[2], &path_bin) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_path");
    }
    const path = path_bin.data[0..path_bin.size];

    // 4. Perform Search (Simple synchronous version for initial wiring)
    // TODO: Parallelize this
    var beam_alloc = allocator.BeamAllocator{ .env = env, .nif_api = nif_api };
    const alloc = beam_alloc.allocator();

    _ = ctx; // Mark used for now

    const result = perform_search(alloc, path, query) catch {
        return api.make_error_tuple(env, nif_api, "search_failed");
    };

    if (result) {
        return nif_api.make_atom(env, "match");
    } else {
        return nif_api.make_atom(env, "no_match");
    }
}

fn perform_search(alloc: std.mem.Allocator, path: []u8, query: []u8) !bool {
    // Zig std.fs handles Windows paths internally
    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    // Read file (limit 64KB for safety)
    const max_size = 64 * 1024;
    const buffer = try alloc.alloc(u8, max_size);
    defer alloc.free(buffer);

    const bytes_read = try file.readAll(buffer);
    const content = buffer[0..bytes_read];

    return std.mem.indexOf(u8, content, query) != null;
}
