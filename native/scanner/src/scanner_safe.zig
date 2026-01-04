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
    // Raw Memory Management (for Zig Allocator)
    alloc: *const fn (size: usize) callconv(.c) ?*anyopaque,
    free: *const fn (ptr: ?*anyopaque) callconv(.c) void,
    // Messaging
    get_local_pid: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, pid: *anyopaque) callconv(.c) c_int,
    send: *const fn (env: ?*ErlNifEnv, to_pid: *const anyopaque, msg_env: ?*ErlNifEnv, msg: ERL_NIF_TERM) callconv(.c) c_int,
};

// Configuration
const PARALLEL_THRESHOLD: usize = 50; // Subdirs to trigger parallel mode
const MAX_THREADS: u32 = 4;
const CHUNK_SIZE: usize = 1000; // Files per chunk

// BeamAllocator Implementation
const BeamAllocator = struct {
    api: *const WinNifApi,
    env: ?*ErlNifEnv,

    pub fn init(api: *const WinNifApi, env: ?*ErlNifEnv) BeamAllocator {
        return .{ .api = api, .env = env };
    }

    pub fn allocator(self: *BeamAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            },
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, ptr_align: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        _ = ptr_align; _ = ret_addr;
        const self: *BeamAllocator = @ptrCast(@alignCast(ctx));
        // Use enif_alloc
        const ptr = self.api.alloc(len) orelse return null;
        return @as([*]u8, @ptrCast(ptr));
    }

    fn resize(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        _ = ctx; _ = buf; _ = buf_align; _ = new_len; _ = ret_addr;
        // enif_realloc not exposed, assume no in-place resize
        return false;
    }

    fn remap(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        _ = ctx; _ = buf; _ = buf_align; _ = new_len; _ = ret_addr;
        // Return null to indicate that the caller should perform the copy
        return null;
    }

    fn free(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, ret_addr: usize) void {
        _ = buf_align; _ = ret_addr;
        const self: *BeamAllocator = @ptrCast(@alignCast(ctx));
        self.api.free(buf.ptr);
    }
};

// Shared context for scanning
const ScanContext = struct {
    buffer: *std.ArrayListUnmanaged(u8),
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,
    base_path: []const u8,
    env: ?*ErlNifEnv,
    api: *const WinNifApi,
    pid: *const anyopaque, // Pointer to ErlNifPid buffer
    entry_count: usize,
};

fn flush_buffer(ctx: *ScanContext) void {
    ctx.mutex.lock();
    defer ctx.mutex.unlock();

    if (ctx.buffer.items.len == 0) return;

    // Send chunk
    send_chunk(ctx.env, ctx.api, ctx.pid, ctx.buffer, ctx.allocator);
    ctx.buffer.clearRetainingCapacity();
    ctx.entry_count = 0;
}

fn send_chunk(env: ?*ErlNifEnv, api: *const WinNifApi, pid: *const anyopaque, buffer: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator) void {
    _ = allocator;
    var bin: ErlNifBinary = undefined;
    if (api.alloc_binary(buffer.items.len, &bin) == 0) return; // Should handle error
    @memcpy(bin.data[0..bin.size], buffer.items);

    // Msg = {:binary, Binary}
    const tag = api.make_atom(env, "binary");
    const val = api.make_binary(env, &bin);
    const msg = api.make_tuple2(env, tag, val);

    _ = api.send(env, pid, null, msg);
}

// Worker function for parallel scanning
fn scanSubdirWorker(ctx: *ScanContext, subdir_name: []const u8) void {
    // Note: In parallel mode, we should use a local buffer and merge, or send directly if large enough.
    // To simplify, we'll accumulate locally and then lock-and-merge or lock-and-send.
    
    // Build full path
    var path_buf: [4096]u8 = undefined;
    const full_path = std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ ctx.base_path, subdir_name }) catch return;

    // We need our own allocator for local logic, but use shared BeamAllocator for buffers?
    // BeamAllocator is not thread safe if enif_alloc is not thread safe?
    // standard enif_alloc IS thread safe.

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

    // Lock and append to shared buffer (or flush if large enough)
    ctx.mutex.lock();
    defer ctx.mutex.unlock();
    
    ctx.buffer.appendSlice(ctx.allocator, local_buffer.items) catch return;
    ctx.entry_count += 50; // Approximation for checking
}

export fn zig_scan(env: ?*ErlNifEnv, argc: c_int, argv: [*c]const ERL_NIF_TERM, api: *const WinNifApi) ERL_NIF_TERM {
    if (argc != 2) return api.make_badarg(env);

    // 1. Parse Path
    var path_bin: ErlNifBinary = undefined;
    if (api.inspect_binary(env, argv[0], &path_bin) == 0) {
        return api.make_badarg(env);
    }
    const path_slice = path_bin.data[0..path_bin.size];

    // 2. Parse PID
    var pid_buffer: [128]u8 = undefined; // 128 bytes should hold ErlNifPid
    if (api.get_local_pid(env, argv[1], &pid_buffer) == 0) {
        return api.make_badarg(env);
    }

    var dir = std.fs.cwd().openDir(path_slice, .{ .iterate = true }) catch {
        // Warning: sending error message vs returning error tuple?
        // Let's return error tuple to caller for sync error, but stream logic is async.
        return make_error_tuple(env, api, "path_open_failure");
    };
    defer dir.close();

    // Use BEAM Allocator
    var beam_alloc = BeamAllocator.init(api, env);
    const allocator = beam_alloc.allocator();
    
    var buffer = std.ArrayListUnmanaged(u8){};
    defer buffer.deinit(allocator); // Cleanup incomplete buffer on error

    var ctx = ScanContext{
        .buffer = &buffer,
        .allocator = allocator,
        .mutex = std.Thread.Mutex{},
        .base_path = path_slice,
        .env = env,
        .api = api,
        .pid = &pid_buffer,
        .entry_count = 0,
    };

    // First pass: count entries and collect subdirs
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
            _ = api.consume_timeslice(env, 1);
        }

        // FILTER: Ignore Heavy Directories
        if (entry.kind == .directory) {
            if (std.mem.eql(u8, entry.name, "node_modules") or
                std.mem.eql(u8, entry.name, "_build") or
                std.mem.eql(u8, entry.name, "deps") or
                std.mem.eql(u8, entry.name, ".git") or
                std.mem.eql(u8, entry.name, ".elixir_ls")) {
                continue;
            }
        }

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

        ctx.entry_count += 1;

        if (ctx.entry_count >= CHUNK_SIZE) {
            flush_buffer(&ctx);
        }

        if (entry.kind == .directory) {
            const name_copy = allocator.dupe(u8, entry.name) catch continue;
            subdirs.append(allocator, name_copy) catch continue;
        }
    }

    // Flush remaining sequential items before parallel
    flush_buffer(&ctx);

    if (subdirs.items.len >= PARALLEL_THRESHOLD) {
        var pool: std.Thread.Pool = undefined;
        pool.init(.{ .allocator = allocator, .n_jobs = MAX_THREADS }) catch {
            for (subdirs.items) |subdir_name| {
                scanSubdirWorker(&ctx, subdir_name);
                if (ctx.buffer.items.len > 1024 * 64) flush_buffer(&ctx); // Check size in bytes approximation
            }
            flush_buffer(&ctx); // Final flush
            // Send Done
            send_done(env, api, &pid_buffer);
            return api.make_atom(env, "ok");
        };
        defer pool.deinit();

        for (subdirs.items) |subdir_name| {
            pool.spawn(scanSubdirWorker, .{ &ctx, subdir_name }) catch continue;
        }
    }
    // pool deinit waits for threads.
    // Note: threads might append to buffer. We should likely have a periodic flush or flush at end?
    // scanSubdirWorker locks and appends.
    // We need to flush after pool deinit! 
    // Wait, pool.deinit() is called at end of block.
    // So we flush after.
    
    // BUT we need to flush periodically during parallel scan? 
    // The workers only append. They don't flush.
    // To support streaming *during* parallel scan, we need the workers to flush?
    // But `send_chunk` uses `env`. `env` is thread safe?
    // "ErlNifEnv: Environments can be used in multiple threads..." -> NO.
    // "Process independent environments can be used..."
    // "The environment env passed to a NIF call... can only be used by the calling thread."
    // CRITICAL: We cannot use `env` in worker threads!
    
    // Solution:
    // 1. Use `enif_alloc_env` for each message? No.
    // 2. Only main thread sends messages.
    // 3. Use `enif_send` from main thread.
    // How to coordinate?
    // A: Collect everything then send (Not streaming).
    // B: Workers append to a queue, Main thread consumes? But main thread is waiting on pool.
    
    // Correct approach for Parallel Streaming NIF:
    // Zig Thread Pool is blocking the NIF call (main thread waits).
    // So we cannot easily stream *while* waiting unless we implement a complex queue consumer loop in the main thread.
    
    // However, `zig_scan` IS the main thread.
    // If we use `pool.init` and `pool.spawn`, and then `pool.deinit` (wait), the main thread is blocked.
    // If we want to stream, we should probably just accumulate in workers and let main thread chunk-send?
    // Or, can we use `enif_send` from threads?
    // "enif_send: ... This function is thread-safe."
    // "msg_env: If NULL... msg must be constructed in env... env must be valid."
    // "If msg_env is NOT NULL, it must be created by enif_alloc_env..."
    
    // So threads CAN send messages if they allocate their own environment or use NULL msg_env with term constructed in that env?
    // "Terms in an environment can only be accessed by the thread owning the environment."
    // So threads CANNOT access `env` to create terms/atoms.
    
    // Strategy:
    // Threads need to construct their own messages using `enif_alloc_env`?
    // Or, simplify:
    // Parallel scan fills a shared list of buffers.
    // But we are blocking the NIF anyway.
    // Maybe for this iteration, just flush AFTER parallel scan (Streaming huge chunks).
    // Or, implement `enif_send` with `enif_alloc_env` in threads.
    // This requires `alloc_env` in `WinNifApi`.
    // And `clear_env`, `free_env`.
    
    // Complexity check:
    // User wants streaming.
    // Parallel scan is for specialized cases (deep/wide dirs).
    // Sequential scan is fine to stream from main thread.
    // For Parallel: 
    // Let's stick to "Accumulate -> Flush" for parallel chunks for now to keep it safe.
    // Or just `flush_buffer` after `pool.deinit()`.
    // Effectively, parallel part will be one (or few) big chunks at the end.
    // That's acceptable for Phase 2.
    
    // So:
    // 1. Sequential part streams fine.
    // 2. Parallel part accumulates in `buffer`.
    // 3. After `pool.deinit()`, we flow `flush_buffer`.
    // 4. Send `done`.

    flush_buffer(&ctx); // Final flush of whatever parallel threads added
    send_done(env, api, &pid_buffer);

    return api.make_atom(env, "ok");
}

fn send_done(env: ?*ErlNifEnv, api: *const WinNifApi, pid: *const anyopaque) void {
    const msg = api.make_tuple2(env, api.make_atom(env, "scan_completed"), api.make_atom(env, "ok"));
    _ = api.send(env, pid, null, msg);
}

fn make_error_tuple(env: ?*ErlNifEnv, api: *const WinNifApi, msg: [*c]const u8) ERL_NIF_TERM {
    return api.make_tuple2(env, api.make_atom(env, "error"), api.make_atom(env, msg));
}
