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
    send_chunk(ctx.nif_api, ctx.pid, ctx.buffer);
    ctx.buffer.clearRetainingCapacity();
    ctx.entry_count = 0;
}

/// Send a binary chunk to Elixir
pub fn send_chunk(
    nif_api: *const api.WinNifApi,
    pid: *const anyopaque,
    buffer: *std.ArrayListUnmanaged(u8),
) void {
    const msg_env = nif_api.alloc_env() orelse return;
    defer nif_api.free_env(msg_env);

    var bin: api.ErlNifBinary = undefined;
    if (nif_api.alloc_binary(buffer.items.len, &bin) == 0) return;
    @memcpy(bin.data[0..bin.size], buffer.items);

    const tag = nif_api.make_atom(msg_env, "scanner_chunk");
    const val = nif_api.make_binary(msg_env, &bin);
    const msg = nif_api.make_tuple2(msg_env, tag, val);

    _ = nif_api.send(null, pid, msg_env, msg);
}

/// Send scan completion signal
pub fn send_done(nif_api: *const api.WinNifApi, pid: *const anyopaque) void {
    const msg_env = nif_api.alloc_env() orelse return;
    defer nif_api.free_env(msg_env);

    const tag = nif_api.make_atom(msg_env, "scanner_done");
    const val = nif_api.make_atom(msg_env, "ok");
    const msg = nif_api.make_tuple2(msg_env, tag, val);

    _ = nif_api.send(null, pid, msg_env, msg);
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

    var dir = std.fs.cwd().openDir(path_slice, .{ .iterate = true }) catch |err| {
        return switch (err) {
            error.AccessDenied => api.make_error_tuple(env, nif_api, "e_acces"),
            error.FileNotFound => api.make_error_tuple(env, nif_api, "e_noent"),
            else => api.make_error_tuple(env, nif_api, "e_io"),
        };
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
            send_done(nif_api, &pid_buffer);
            return nif_api.make_atom(env, "ok");
        };
        defer pool.deinit();

        for (subdirs.items) |subdir_name| {
            pool.spawn(scanSubdirWorker, .{ &ctx, subdir_name }) catch continue;
        }
    } else {
        for (subdirs.items) |subdir_name| {
            scanSubdirWorker(&ctx, subdir_name);
        }
    }

    flush_buffer(&ctx);
    send_done(nif_api, &pid_buffer);

    return nif_api.make_atom(env, "ok");
}

/// Yieldable scan entry point (Level 5)
pub export fn zig_scan_yieldable(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 3) return nif_api.make_badarg(env);

    // 1. Get Resource
    var resource_ptr: ?*anyopaque = null;
    if (nif_api.get_resource(env, argv[0], &resource_ptr) == 0) {
        return api.make_error_tuple(env, nif_api, "invalid_resource");
    }
    const resource: *@import("resource.zig").ScannerResource = @ptrCast(@alignCast(resource_ptr.?));

    // 2. Parse Path (only if stack is empty - initial call)
    if (resource.stack.items.len == 0) {
        var path_bin: api.ErlNifBinary = undefined;
        if (nif_api.inspect_binary(env, argv[1], &path_bin) == 0) {
            return nif_api.make_badarg(env);
        }
        const path_slice = path_bin.data[0..path_bin.size];

        const path_copy = std.heap.page_allocator.dupe(u8, path_slice) catch return api.make_error_tuple(env, nif_api, "oom");
        resource.stack.append(std.heap.page_allocator, path_copy) catch {
            std.heap.page_allocator.free(path_copy);
            return api.make_error_tuple(env, nif_api, "oom");
        };
    }

    // 3. Parse PID
    var pid_buffer: [128]u8 = undefined;
    if (nif_api.get_local_pid(env, argv[2], &pid_buffer) == 0) {
        return nif_api.make_badarg(env);
    }

    // Use page_allocator for the scan loop (needs to be persistent if interrupted)
    const allocator = std.heap.page_allocator;
    var beam_alloc = alloc_mod.BeamAllocator.init(nif_api, env);
    const nif_allocator = beam_alloc.allocator();

    var buffer = std.ArrayListUnmanaged(u8){};
    defer buffer.deinit(nif_allocator);

    var ctx = ScanContext{
        .buffer = &buffer,
        .allocator = nif_allocator,
        .mutex = std.Thread.Mutex{},
        .base_path = "", // Will be set per directory
        .env = env,
        .nif_api = nif_api,
        .pid = &pid_buffer,
        .entry_count = 0,
    };

    var iteration_count: usize = 0;
    while (resource.stack.items.len > 0) {
        const dir_path = resource.stack.items[resource.stack.items.len - 1];
        resource.stack.items.len -= 1;
        ctx.base_path = dir_path;

        iteration_count += 1;
        if (iteration_count % 50 == 0) {
            if (nif_api.consume_timeslice(env, 1) != 0) {
                // YIELD! Push directory BACK so it's processed on resume
                resource.stack.append(allocator, dir_path) catch {
                    allocator.free(dir_path);
                    return api.make_error_tuple(env, nif_api, "oom");
                };
                return nif_api.make_tuple2(env, nif_api.make_atom(env, "cont"), argv[0]);
            }
        }

        var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch {
            allocator.free(dir_path);
            continue;
        };
        defer dir.close();

        var iterator = dir.iterate();
        while (iterator.next() catch null) |entry| {
            // FILTER: Standard Aether Filters
            if (entry.kind == .directory) {
                if (std.mem.eql(u8, entry.name, "node_modules") or
                    std.mem.eql(u8, entry.name, ".git") or
                    std.mem.eql(u8, entry.name, "_build") or
                    std.mem.eql(u8, entry.name, "deps"))
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
            buffer.append(nif_allocator, type_byte) catch break;

            const name_with_path = std.fs.path.join(nif_allocator, &[_][]const u8{ dir_path, entry.name }) catch break;
            defer nif_allocator.free(name_with_path);

            const len: u16 = @intCast(name_with_path.len);
            buffer.writer(nif_allocator).writeInt(u16, len, .little) catch break;
            buffer.appendSlice(nif_allocator, name_with_path) catch break;

            if (entry.kind == .directory) {
                const sub_path = allocator.dupe(u8, name_with_path) catch continue;
                resource.stack.append(allocator, sub_path) catch {
                    allocator.free(sub_path);
                    continue;
                };
            }
        }

        // Processing of this directory is finished. Free the path.
        allocator.free(dir_path);

        if (buffer.items.len > CHUNK_SIZE) {
            flush_buffer(&ctx);
        }
    }

    flush_buffer(&ctx);
    send_done(nif_api, &pid_buffer);

    return nif_api.make_atom(env, "ok");
}
