const std = @import("std");

// Opaque types
const ErlNifEnv = opaque {};
const ERL_NIF_TERM = usize;

const ErlNifBinary = extern struct {
    size: usize,
    data: [*c]u8,
    ref_bin: ?*anyopaque,
    __spare__: [2]?*anyopaque,
};

// API Struct matching C definition
const WinNifApi = extern struct {
    make_badarg: *const fn (env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    inspect_binary: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, bin: *ErlNifBinary) callconv(.c) c_int,
    make_empty_list: *const fn (env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    make_list_cell: *const fn (env: ?*ErlNifEnv, head: ERL_NIF_TERM, tail: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_tuple2: *const fn (env: ?*ErlNifEnv, e1: ERL_NIF_TERM, e2: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_atom: *const fn (env: ?*ErlNifEnv, name: [*c]const u8) callconv(.c) ERL_NIF_TERM,
    make_binary: *const fn (env: ?*ErlNifEnv, bin: *ErlNifBinary) callconv(.c) ERL_NIF_TERM,
    alloc_binary: *const fn (size: usize, bin: *ErlNifBinary) callconv(.c) c_int,
    release_binary: *const fn (bin: *ErlNifBinary) callconv(.c) void,
    // BEAM Citizenship: Time-slice consumption for polite NIFs
    consume_timeslice: *const fn (env: ?*ErlNifEnv, percent: c_int) callconv(.c) c_int,
};

// Configuration
const PARALLEL_THRESHOLD: usize = 50; // Subdirs to trigger parallel mode
const MAX_THREADS: u32 = 4;

// Shared context for parallel scanning
const ScanContext = struct {
    buffer: *std.ArrayListUnmanaged(u8),
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,
    base_path: []const u8,
};

// Worker function for parallel scanning
fn scanSubdirWorker(ctx: *ScanContext, subdir_name: []const u8) void {
    // Build full path
    var path_buf: [4096]u8 = undefined;
    const full_path = std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ ctx.base_path, subdir_name }) catch return;

    var dir = std.fs.cwd().openDir(full_path, .{ .iterate = true }) catch return;
    defer dir.close();

    var local_buffer = std.ArrayListUnmanaged(u8){};
    defer local_buffer.deinit(ctx.allocator);

    var iterator = dir.iterate();
    while (iterator.next() catch null) |entry| {
        // 1. Type (1 byte)
        const type_byte: u8 = switch (entry.kind) {
            .file => 1,
            .directory => 2,
            .sym_link => 3,
            else => 0,
        };
        local_buffer.append(ctx.allocator, type_byte) catch return;

        // Build relative path: subdir/entry.name
        var rel_path_buf: [4096]u8 = undefined;
        const rel_path = std.fmt.bufPrint(&rel_path_buf, "{s}/{s}", .{ subdir_name, entry.name }) catch return;

        // 2. Length (2 bytes, LE)
        const len: u16 = @intCast(rel_path.len);
        local_buffer.writer(ctx.allocator).writeInt(u16, len, .little) catch return;

        // 3. Name (Bytes)
        local_buffer.appendSlice(ctx.allocator, rel_path) catch return;
    }

    // Merge into shared buffer (locked)
    ctx.mutex.lock();
    defer ctx.mutex.unlock();
    ctx.buffer.appendSlice(ctx.allocator, local_buffer.items) catch return;
}

export fn zig_scan(env: ?*ErlNifEnv, argc: c_int, argv: [*c]const ERL_NIF_TERM, api: *const WinNifApi) ERL_NIF_TERM {
    if (argc != 1) return api.make_badarg(env);

    var path_bin: ErlNifBinary = undefined;
    if (api.inspect_binary(env, argv[0], &path_bin) == 0) {
        return api.make_badarg(env);
    }

    const path_slice = path_bin.data[0..path_bin.size];

    var dir = std.fs.cwd().openDir(path_slice, .{ .iterate = true }) catch {
        return make_error_tuple(env, api, "path_open_failure");
    };
    defer dir.close();

    const allocator = std.heap.page_allocator;
    var buffer = std.ArrayListUnmanaged(u8){};
    defer buffer.deinit(allocator);

    // First pass: count entries and collect subdirs
    var subdirs = std.ArrayListUnmanaged([]const u8){};
    defer subdirs.deinit(allocator);

    var iterator = dir.iterate();
    var iteration_count: usize = 0;
    while (iterator.next() catch null) |entry| {
        iteration_count += 1;

        // BEAM Citizenship: Report work every 100 iterations
        // This allows the Erlang scheduler to balance load across cores
        if (iteration_count % 100 == 0) {
            _ = api.consume_timeslice(env, 1); // 1% timeslice consumed
        }

        // Always add top-level entry to buffer
        const type_byte: u8 = switch (entry.kind) {
            .file => 1,
            .directory => 2,
            .sym_link => 3,
            else => 0,
        };
        buffer.append(allocator, type_byte) catch return make_error_tuple(env, api, "oom");

        const len: u16 = @intCast(entry.name.len);
        buffer.writer(allocator).writeInt(u16, len, .little) catch return make_error_tuple(env, api, "oom");
        buffer.appendSlice(allocator, entry.name) catch return make_error_tuple(env, api, "oom");

        // Collect subdirs for potential parallel scan
        if (entry.kind == .directory) {
            const name_copy = allocator.dupe(u8, entry.name) catch continue;
            subdirs.append(allocator, name_copy) catch continue;
        }
    }

    // Parallel scan if above threshold
    if (subdirs.items.len >= PARALLEL_THRESHOLD) {
        var ctx = ScanContext{
            .buffer = &buffer,
            .allocator = allocator,
            .mutex = std.Thread.Mutex{},
            .base_path = path_slice,
        };

        // Create thread pool
        var pool: std.Thread.Pool = undefined;
        pool.init(.{ .allocator = allocator, .n_jobs = MAX_THREADS }) catch {
            // Fallback to sequential if pool fails
            for (subdirs.items) |subdir_name| {
                scanSubdirWorker(&ctx, subdir_name);
            }
            return finalize_result(env, api, &buffer, allocator);
        };
        defer pool.deinit();

        // Spawn parallel jobs
        for (subdirs.items) |subdir_name| {
            pool.spawn(scanSubdirWorker, .{ &ctx, subdir_name }) catch continue;
        }

        // Wait for completion (pool.deinit waits)
    }

    return finalize_result(env, api, &buffer, allocator);
}

fn finalize_result(env: ?*ErlNifEnv, api: *const WinNifApi, buffer: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator) ERL_NIF_TERM {
    _ = allocator;
    // Allocate NIF Binary
    var bin: ErlNifBinary = undefined;
    if (api.alloc_binary(buffer.items.len, &bin) == 0) {
        return make_error_tuple(env, api, "oom");
    }

    // Copy buffer to binary
    @memcpy(bin.data[0..bin.size], buffer.items);

    // Return {ok, Binary}
    return api.make_tuple2(env, api.make_atom(env, "ok"), api.make_binary(env, &bin));
}

fn make_error_tuple(env: ?*ErlNifEnv, api: *const WinNifApi, msg: [*c]const u8) ERL_NIF_TERM {
    return api.make_tuple2(env, api.make_atom(env, "error"), api.make_atom(env, msg));
}
