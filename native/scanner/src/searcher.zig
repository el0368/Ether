const std = @import("std");
const api = @import("api.zig");
const allocator = @import("allocator.zig");
const resource = @import("resource.zig");

pub const SearchOptions = struct {
    case_sensitive: bool,
    max_results: u32,
};

const ResultList = std.ArrayListUnmanaged([]u8);

// Result context to share across threads
const SearchContext = struct {
    alloc: std.mem.Allocator,
    query: []const u8,
    results: ResultList,
    mutex: std.Thread.Mutex,
    pool: *std.Thread.Pool,
    wg: std.Thread.WaitGroup,

    pub fn addResult(self: *SearchContext, path: []u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        try self.results.append(self.alloc, path);
    }
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
    const resource_obj: *resource.ScannerResource = @ptrCast(@alignCast(ctx_ptr));

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
    const root_path = path_bin.data[0..path_bin.size];

    // 4. Setup Execution Context
    // We use BeamAllocator for main thread (results list), but file reading uses page_allocator inside threads
    var beam_alloc = allocator.BeamAllocator.init(nif_api, env);
    const alloc = beam_alloc.allocator();

    var search_ctx = SearchContext{
        .alloc = alloc,
        .query = query,
        .results = .{}, // Unmanaged init
        .mutex = .{},
        .pool = &resource_obj.pool,
        .wg = .{},
    };
    defer search_ctx.results.deinit(alloc);

    // 5. Start Search (Parallel)
    // We treat the root path as a potential directory or file
    process_path(&search_ctx, root_path) catch {
        // Log error?
    };

    // Wait for all spawned file searches to finish
    search_ctx.wg.wait();

    // 6. Build Result List
    var list = nif_api.make_empty_list(env); // Start with empty list (NIL)
    for (search_ctx.results.items) |match_path| {
        // Create binary for path
        var bin: api.ErlNifBinary = undefined;
        if (nif_api.alloc_binary(match_path.len, &bin) != 0) {
            @memcpy(bin.data[0..match_path.len], match_path);
            const bin_term = nif_api.make_binary(env, &bin);
            // Prepend to list
            list = nif_api.make_list_cell(env, bin_term, list);
        }
        alloc.free(match_path);
    }

    return nif_api.make_tuple2(env, nif_api.make_atom(env, "ok"), list);
}

// Unified recursive walker
fn process_path(ctx: *SearchContext, path: []const u8) !void {
    // Try to open as directory
    var dir = std.fs.openDirAbsolute(path, .{ .iterate = true }) catch |err| {
        if (err == error.NotDir) {
            // It's a file, spawn search task
            const path_dupe = try ctx.alloc.dupe(u8, path);
            ctx.wg.start();
            try ctx.pool.spawn(search_file_task, .{ ctx, path_dupe });
            return;
        }
        return err;
    };
    defer dir.close();

    // It's a directory, iterate
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        // Skip common ignore patterns
        if (std.mem.eql(u8, entry.name, ".git")) continue;
        if (std.mem.eql(u8, entry.name, "tmp")) continue;
        if (std.mem.eql(u8, entry.name, "deps")) continue;
        if (std.mem.eql(u8, entry.name, "_build")) continue;
        if (std.mem.eql(u8, entry.name, "node_modules")) continue;

        const full_path = try std.fs.path.join(ctx.alloc, &.{ path, entry.name });
        defer ctx.alloc.free(full_path);

        if (entry.kind == .directory) {
            try process_path(ctx, full_path);
        } else if (entry.kind == .file) {
            const path_dupe = try ctx.alloc.dupe(u8, full_path);
            ctx.wg.start();
            try ctx.pool.spawn(search_file_task, .{ ctx, path_dupe });
        }
    }
}

fn search_file_task(ctx: *SearchContext, path: []u8) void {
    defer ctx.wg.finish();
    // We own path, must free or pass ownership
    // If not match, free. If match, pass to results.
    defer {
        // We do NOT free path here if we added it to results?
        // Result list needs it.
        // Actually, let's keep it simple: always free here unless we move ownership.
    }

    // Use page allocator for file buffer (thread local)
    const file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch {
        ctx.alloc.free(path);
        return;
    };
    defer file.close();

    // Limit read size to 1MB for search
    const max_size = 1024 * 1024;
    const buffer = std.heap.page_allocator.alloc(u8, max_size) catch {
        ctx.alloc.free(path);
        return;
    };
    defer std.heap.page_allocator.free(buffer);

    const bytes = file.readAll(buffer) catch 0;
    const content = buffer[0..bytes];

    if (std.mem.indexOf(u8, content, ctx.query) != null) {
        // Found match!
        ctx.addResult(path) catch {
            ctx.alloc.free(path); // failed to add
        };
    } else {
        // No match, free path
        ctx.alloc.free(path);
    }
}
