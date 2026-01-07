//! Crawler Module: File system scanning logic
//! Implements iterative stack-safe directory traversal for Windows
//! ADR-021: Stack-Safe Windows NIF Infrastructure

const std = @import("std");
const api = @import("api.zig");
const beam = @import("beam/erl_nif.zig");
const resource = @import("resource.zig");

// Configuration
pub const CHUNK_SIZE: usize = 1000;

const w = std.os.windows;
const CP_UTF8 = 65001;

const kernel32 = struct {
    extern "kernel32" fn MultiByteToWideChar(CodePage: u32, dwFlags: u32, lpMultiByteStr: [*]const u8, cbMultiByte: c_int, lpWideCharStr: ?[*]u16, cchWideChar: c_int) callconv(.winapi) c_int;
    extern "kernel32" fn CreateFileW(lpFileName: [*]const u16, dwDesiredAccess: u32, dwShareMode: u32, lpSecurityAttributes: ?*anyopaque, dwCreationDisposition: u32, dwFlagsAndAttributes: u32, hTemplateFile: ?*anyopaque) callconv(.winapi) w.HANDLE;
    extern "kernel32" fn CloseHandle(hObject: w.HANDLE) callconv(.winapi) bool;
    extern "kernel32" fn GetFileAttributesW(lpFileName: [*]const u16) callconv(.winapi) u32;
    extern "kernel32" fn FindFirstFileW(lpFileName: [*]const u16, lpFindFileData: *w.WIN32_FIND_DATAW) callconv(.winapi) w.HANDLE;
    extern "kernel32" fn FindNextFileW(hFindFile: w.HANDLE, lpFindFileData: *w.WIN32_FIND_DATAW) callconv(.winapi) bool;
    extern "kernel32" fn FindClose(hFindFile: w.HANDLE) callconv(.winapi) bool;
    extern "kernel32" fn WideCharToMultiByte(CodePage: u32, dwFlags: u32, lpWideCharStr: [*]const u16, cchWideChar: c_int, lpMultiByteStr: ?[*]u8, cbMultiByte: c_int, lpDefaultChar: ?[*]const u8, lpUsedDefaultChar: ?*bool) callconv(.winapi) c_int;
};

fn sliceToHeapUTF16(mem_alloc: std.mem.Allocator, path_u8: []const u8) ![]u16 {
    const res_len = kernel32.MultiByteToWideChar(CP_UTF8, 0, path_u8.ptr, @intCast(path_u8.len), null, 0);
    if (res_len <= 0) return error.UnicodeError;
    const path_utf16 = try mem_alloc.alloc(u16, @intCast(res_len + 1));
    _ = kernel32.MultiByteToWideChar(CP_UTF8, 0, path_u8.ptr, @intCast(path_u8.len), path_utf16.ptr, res_len);
    path_utf16[@intCast(res_len)] = 0;
    return path_utf16;
}

/// Shared context for scanning
pub const ScanContext = struct {
    buffer: *std.ArrayListUnmanaged(u8),
    allocator: std.mem.Allocator,
    env: ?*api.ErlNifEnv,
    nif_api: *const api.WinNifApi,
    pid: *const beam.ErlNifPid,
    entry_count: usize,
};

/// Flush buffer to Elixir process
pub fn flush_buffer(ctx: *ScanContext) void {
    if (ctx.buffer.items.len == 0) return;

    const msg_env = ctx.nif_api.alloc_env() orelse return;
    var bin: api.ErlNifBinary = undefined;
    if (ctx.nif_api.alloc_binary(ctx.buffer.items.len, &bin) == 0) {
        ctx.nif_api.free_env(msg_env);
        return;
    }
    @memcpy(bin.data[0..bin.size], ctx.buffer.items);

    const tag = ctx.nif_api.make_atom(msg_env, "scanner_chunk");
    const val = ctx.nif_api.make_binary(msg_env, &bin);
    const msg = ctx.nif_api.make_tuple2(msg_env, tag, val);

    if (ctx.nif_api.send(null, ctx.pid, msg_env, msg) == 0) {
        ctx.nif_api.free_env(msg_env);
    }

    ctx.buffer.clearRetainingCapacity();
    ctx.entry_count = 0;
}

/// Send scan completion signal
pub fn send_done(nif_api: *const api.WinNifApi, pid: *const beam.ErlNifPid) void {
    const msg_env = nif_api.alloc_env() orelse return;
    const tag = nif_api.make_atom(msg_env, "scanner_done");
    const val = nif_api.make_atom(msg_env, "ok");
    const msg = nif_api.make_tuple2(msg_env, tag, val);
    if (nif_api.send(null, pid, msg_env, msg) == 0) {
        nif_api.free_env(msg_env);
    }
}

/// Yieldable scan entry point (Level 5)
pub export fn zig_scan_yieldable(
    env: ?*api.ErlNifEnv,
    argc: c_int,
    argv: [*c]const api.ERL_NIF_TERM,
    nif_api: *const api.WinNifApi,
) api.ERL_NIF_TERM {
    if (argc != 3) return nif_api.make_badarg(env);

    // 1. Validate Context Resource
    var ctx_ptr: ?*anyopaque = undefined;
    if (nif_api.get_resource(env, argv[0], &ctx_ptr) == 0) return nif_api.make_badarg(env);
    const res_obj: *resource.ScannerResource = @ptrCast(@alignCast(ctx_ptr));

    // 2. Parse PID
    var pid: beam.ErlNifPid = undefined;
    if (nif_api.get_local_pid(env, argv[2], &pid) == 0) return nif_api.make_badarg(env);

    // 3. Handle Initial Path (if stack empty)
    const allocator = std.heap.c_allocator;
    if (res_obj.stack.items.len == 0) {
        var path_bin: api.ErlNifBinary = undefined;
        if (nif_api.inspect_binary(env, argv[1], &path_bin) == 0) return nif_api.make_badarg(env);
        const initial_path = allocator.dupe(u8, path_bin.data[0..path_bin.size]) catch return nif_api.make_badarg(env);
        res_obj.stack.append(allocator, initial_path) catch {
            allocator.free(initial_path);
            return nif_api.make_badarg(env);
        };
    }

    var local_buffer = std.ArrayListUnmanaged(u8){};
    defer local_buffer.deinit(allocator);

    var scan_ctx = ScanContext{
        .buffer = &local_buffer,
        .allocator = allocator,
        .env = env,
        .nif_api = nif_api,
        .pid = &pid,
        .entry_count = 0,
    };

    var iterations: usize = 0;
    while (res_obj.stack.items.len > 0) {
        iterations += 1;
        if (iterations % 50 == 0) {
            if (nif_api.consume_timeslice(env, 1) != 0) {
                flush_buffer(&scan_ctx);
                return nif_api.make_atom(env, "yield");
            }
        }

        const current_path = res_obj.stack.items[res_obj.stack.items.len - 1];
        res_obj.stack.items.len -= 1;
        defer allocator.free(current_path);

        const path_utf16 = sliceToHeapUTF16(allocator, current_path) catch continue;
        defer allocator.free(path_utf16);

        const attrs = kernel32.GetFileAttributesW(path_utf16.ptr);
        if (attrs == 0xFFFFFFFF) continue;

        if ((attrs & 0x10) != 0) { // Directory
            var search_pattern_u8 = std.ArrayListUnmanaged(u8){};
            defer search_pattern_u8.deinit(allocator);
            search_pattern_u8.appendSlice(allocator, current_path) catch continue;
            if (!std.mem.endsWith(u8, current_path, "\\") and !std.mem.endsWith(u8, current_path, "/")) {
                search_pattern_u8.appendSlice(allocator, "\\*") catch continue;
            } else {
                search_pattern_u8.append(allocator, '*') catch continue;
            }

            const pattern_utf16 = sliceToHeapUTF16(allocator, search_pattern_u8.items) catch continue;
            defer allocator.free(pattern_utf16);

            var find_data: w.WIN32_FIND_DATAW = undefined;
            const find_handle = kernel32.FindFirstFileW(pattern_utf16.ptr, &find_data);
            if (find_handle == w.INVALID_HANDLE_VALUE) continue;
            defer _ = kernel32.FindClose(find_handle);

            while (true) {
                const name_u16 = std.mem.sliceTo(&find_data.cFileName, 0);
                if (!std.mem.eql(u16, name_u16, &.{'.'}) and !std.mem.eql(u16, name_u16, &.{ '.', '.' })) {
                    const name_len = kernel32.WideCharToMultiByte(CP_UTF8, 0, name_u16.ptr, @intCast(name_u16.len), null, 0, null, null);
                    if (name_len > 0) {
                        const name_u8 = allocator.alloc(u8, @intCast(name_len)) catch continue;
                        defer allocator.free(name_u8);
                        _ = kernel32.WideCharToMultiByte(CP_UTF8, 0, name_u16.ptr, @intCast(name_u16.len), name_u8.ptr, name_len, null, null);

                        // Skip ignore patterns
                        if (!std.mem.eql(u8, name_u8, ".git") and
                            !std.mem.eql(u8, name_u8, "node_modules") and
                            !std.mem.eql(u8, name_u8, "_build") and
                            !std.mem.eql(u8, name_u8, "deps"))
                        {
                            const full_path = std.fs.path.join(allocator, &.{ current_path, name_u8 }) catch continue;

                            if ((find_data.dwFileAttributes & 0x10) != 0) {
                                res_obj.stack.append(allocator, full_path) catch {
                                    allocator.free(full_path);
                                };
                            } else {
                                // Add file entry to buffer
                                local_buffer.append(allocator, 1) catch continue; // type_file
                                const len: u16 = @intCast(full_path.len);
                                local_buffer.writer(allocator).writeInt(u16, len, .little) catch continue;
                                local_buffer.appendSlice(allocator, full_path) catch continue;
                                scan_ctx.entry_count += 1;
                                allocator.free(full_path);
                            }
                        }
                    }
                }
                if (!kernel32.FindNextFileW(find_handle, &find_data)) break;

                // Pre-emptive flush to avoid giant messages
                if (local_buffer.items.len > 1024 * 64) {
                    flush_buffer(&scan_ctx);
                }
            }
        }

        if (scan_ctx.entry_count >= CHUNK_SIZE) {
            flush_buffer(&scan_ctx);
        }
    }

    flush_buffer(&scan_ctx);
    send_done(nif_api, &pid);
    return nif_api.make_atom(env, "ok");
}
