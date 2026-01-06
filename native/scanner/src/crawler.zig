//! Crawler Module: File system scanning logic
//! Implements parallel and sequential directory traversal

const std = @import("std");
const api = @import("api.zig");
const alloc_mod = @import("allocator.zig");

// Configuration
pub const PARALLEL_THRESHOLD: usize = 50;
pub const MAX_THREADS: u32 = 4;
pub const CHUNK_SIZE: usize = 1000;

/// Shared context for scanning
pub const ScanContext = struct {
    buffer: *std.ArrayListUnmanaged(u8),
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,
    base_path: []const u8,
    env: ?*api.ErlNifEnv,
    nif_api: *const api.WinNifApi,
    pid: *const anyopaque,
    entry_count: usize,
};

/// Flush buffer to Elixir process
pub fn flush_buffer(ctx: *ScanContext) void {
    ctx.mutex.lock();
    defer ctx.mutex.unlock();

    if (ctx.buffer.items.len == 0) return;
    send_chunk(ctx.env, ctx.nif_api, ctx.pid, ctx.buffer);
    ctx.buffer.clearRetainingCapacity();
    ctx.entry_count = 0;
}

/// Send a binary chunk to Elixir
pub fn send_chunk(
    env: ?*api.ErlNifEnv,
    nif_api: *const api.WinNifApi,
    pid: *const anyopaque,
    buffer: *std.ArrayListUnmanaged(u8),
) void {
    var bin: api.ErlNifBinary = undefined;
    if (nif_api.alloc_binary(buffer.items.len, &bin) == 0) return;
    @memcpy(bin.data[0..bin.size], buffer.items);

    const tag = nif_api.make_atom(env, "binary");
    const val = nif_api.make_binary(env, &bin);
    const msg = nif_api.make_tuple2(env, tag, val);

    _ = nif_api.send(env, pid, null, msg);
}

/// Send scan completion signal
pub fn send_done(env: ?*api.ErlNifEnv, nif_api: *const api.WinNifApi, pid: *const anyopaque) void {
    const msg = nif_api.make_tuple2(env, nif_api.make_atom(env, "scan_completed"), nif_api.make_atom(env, "ok"));
    _ = nif_api.send(env, pid, null, msg);
}

/// Worker function for parallel scanning
pub fn scanSubdirWorker(ctx: *ScanContext, subdir_name: []const u8) void {
    var path_buf: [4096]u8 = undefined;
    const full_path = std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ ctx.base_path, subdir_name }) catch return;

    var dir = std.fs.cwd().openDir(full_path, .{ .iterate = true }) catch return;
    defer dir.close();

    var local_buffer = std.ArrayListUnmanaged(u8){};
    defer local_buffer.deinit(ctx.allocator);

    var iterator = dir.iterate();
    while (iterator.next() catch null) |entry| {
        const type_byte: u8 = switch (entry.kind) {
            .file => 1,
            .directory => 2,
            .sym_link => 3,
            else => 0,
        };
        local_buffer.append(ctx.allocator, type_byte) catch return;

        var rel_path_buf: [4096]u8 = undefined;
        const rel_path = std.fmt.bufPrint(&rel_path_buf, "{s}/{s}", .{ subdir_name, entry.name }) catch return;

        const len: u16 = @intCast(rel_path.len);
        local_buffer.writer(ctx.allocator).writeInt(u16, len, .little) catch return;
        local_buffer.appendSlice(ctx.allocator, rel_path) catch return;
    }

    ctx.mutex.lock();
    defer ctx.mutex.unlock();
    ctx.buffer.appendSlice(ctx.allocator, local_buffer.items) catch return;
    ctx.entry_count += 50;
}

/// Main scan entry point
pub export fn zig_scan(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 2) return nif_api.make_badarg(env);

    // Phase 3-4: Defensive Input Validation
    if (nif_api.is_binary(env, argv[0]) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_path_type");
    }
    if (nif_api.is_pid(env, argv[1]) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_pid_type");
    }

    // 1. Parse Path
    var path_bin: api.ErlNifBinary = undefined;
    if (nif_api.inspect_binary(env, argv[0], &path_bin) == 0) {
        return nif_api.make_badarg(env);
    }
    const path_slice = path_bin.data[0..path_bin.size];

    // 2. Parse PID
    var pid_buffer: [128]u8 = undefined;
    if (nif_api.get_local_pid(env, argv[1], &pid_buffer) == 0) {
        return nif_api.make_badarg(env);
    }

    var dir = std.fs.cwd().openDir(path_slice, .{ .iterate = true }) catch {
        return api.make_error_tuple(env, nif_api, "path_open_failure");
    };
    defer dir.close();

    // Use BEAM Allocator
    var beam_alloc = alloc_mod.BeamAllocator.init(nif_api, env);
    const allocator = beam_alloc.allocator();

    var buffer = std.ArrayListUnmanaged(u8){};
    defer buffer.deinit(allocator);

    var ctx = ScanContext{
        .buffer = &buffer,
        .allocator = allocator,
        .mutex = std.Thread.Mutex{},
        .base_path = path_slice,
        .env = env,
        .nif_api = nif_api,
        .pid = &pid_buffer,
        .entry_count = 0,
    };

    // Collect subdirs
    var subdirs = std.ArrayListUnmanaged([]const u8){};
    defer {
        for (subdirs.items) |subdir| {
            allocator.free(subdir);
        }
        subdirs.deinit(allocator);
    }

    var iterator = dir.iterate();
    var iteration_count: usize = 0;
    while (iterator.next() catch null) |entry| {
        iteration_count += 1;

        if (iteration_count % 100 == 0) {
            _ = nif_api.consume_timeslice(env, 1);
        }

        // FILTER: Ignore Heavy Directories
        if (entry.kind == .directory) {
            if (std.mem.eql(u8, entry.name, "node_modules") or
                std.mem.eql(u8, entry.name, "_build") or
                std.mem.eql(u8, entry.name, "deps") or
                std.mem.eql(u8, entry.name, ".git") or
                std.mem.eql(u8, entry.name, ".elixir_ls"))
            {
                continue;
            }
        }

        const type_byte: u8 = switch (entry.kind) {
            .file => 1,
            .directory => 2,
            .sym_link => 3,
            else => 0,
        };
        buffer.append(allocator, type_byte) catch return api.make_error_tuple(env, nif_api, "oom");

        const len: u16 = @intCast(entry.name.len);
        buffer.writer(allocator).writeInt(u16, len, .little) catch return api.make_error_tuple(env, nif_api, "oom");
        buffer.appendSlice(allocator, entry.name) catch return api.make_error_tuple(env, nif_api, "oom");

        ctx.entry_count += 1;

        if (ctx.entry_count >= CHUNK_SIZE) {
            flush_buffer(&ctx);
        }

        if (entry.kind == .directory) {
            const name_copy = allocator.dupe(u8, entry.name) catch continue;
            subdirs.append(allocator, name_copy) catch continue;
        }
    }

    flush_buffer(&ctx);

    if (subdirs.items.len >= PARALLEL_THRESHOLD) {
        var pool: std.Thread.Pool = undefined;
        pool.init(.{ .allocator = allocator, .n_jobs = MAX_THREADS }) catch {
            for (subdirs.items) |subdir_name| {
                scanSubdirWorker(&ctx, subdir_name);
                if (ctx.buffer.items.len > 1024 * 64) flush_buffer(&ctx);
            }
            flush_buffer(&ctx);
            send_done(env, nif_api, &pid_buffer);
            return nif_api.make_atom(env, "ok");
        };
        defer pool.deinit();

        for (subdirs.items) |subdir_name| {
            pool.spawn(scanSubdirWorker, .{ &ctx, subdir_name }) catch continue;
        }
    }

    flush_buffer(&ctx);
    send_done(env, nif_api, &pid_buffer);

    return nif_api.make_atom(env, "ok");
}
