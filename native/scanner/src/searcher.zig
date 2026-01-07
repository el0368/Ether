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

const w = std.os.windows;
const CP_UTF8 = 65001;

const kernel32 = struct {
    extern "kernel32" fn MultiByteToWideChar(CodePage: u32, dwFlags: u32, lpMultiByteStr: [*]const u8, cbMultiByte: c_int, lpWideCharStr: ?[*]u16, cchWideChar: c_int) callconv(.winapi) c_int;
    extern "kernel32" fn CreateFileW(lpFileName: [*]const u16, dwDesiredAccess: u32, dwShareMode: u32, lpSecurityAttributes: ?*anyopaque, dwCreationDisposition: u32, dwFlagsAndAttributes: u32, hTemplateFile: ?*anyopaque) callconv(.winapi) w.HANDLE;
    extern "kernel32" fn CloseHandle(hObject: w.HANDLE) callconv(.winapi) bool;
    extern "kernel32" fn ReadFile(hFile: w.HANDLE, lpBuffer: [*]u8, nNumberOfBytesToRead: u32, lpNumberOfBytesRead: ?*u32, lpOverlapped: ?*anyopaque) callconv(.winapi) bool;
    extern "kernel32" fn GetFileSizeEx(hFile: w.HANDLE, lpFileSize: *i64) callconv(.winapi) bool;
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

fn process_path(ctx: *SearchContext, path_u8: []const u8) !void {
    const path_utf16 = try sliceToHeapUTF16(ctx.alloc, path_u8);
    defer ctx.alloc.free(path_utf16);

    const attrs = kernel32.GetFileAttributesW(path_utf16.ptr);
    if (attrs == 0xFFFFFFFF) return error.NotFound;

    if ((attrs & 0x10) != 0) { // FILE_ATTRIBUTE_DIRECTORY
        // Iterate directory using FindFirstFileW
        var search_pattern_u8 = std.ArrayListUnmanaged(u8){};
        defer search_pattern_u8.deinit(ctx.alloc);
        try search_pattern_u8.appendSlice(ctx.alloc, path_u8);
        if (!std.mem.endsWith(u8, path_u8, "\\") and !std.mem.endsWith(u8, path_u8, "/")) {
            try search_pattern_u8.appendSlice(ctx.alloc, "\\*");
        } else {
            try search_pattern_u8.append(ctx.alloc, '*');
        }

        const pattern_utf16 = try sliceToHeapUTF16(ctx.alloc, search_pattern_u8.items);
        defer ctx.alloc.free(pattern_utf16);

        var find_data: w.WIN32_FIND_DATAW = undefined;
        const find_handle = kernel32.FindFirstFileW(pattern_utf16.ptr, &find_data);
        if (find_handle == w.INVALID_HANDLE_VALUE) return;
        defer _ = kernel32.FindClose(find_handle);

        while (true) {
            const name_u16 = std.mem.sliceTo(&find_data.cFileName, 0);
            if (!std.mem.eql(u16, name_u16, &.{'.'}) and !std.mem.eql(u16, name_u16, &.{ '.', '.' })) {
                // Convert name back to UTF-8
                const name_len = kernel32.WideCharToMultiByte(CP_UTF8, 0, name_u16.ptr, @intCast(name_u16.len), null, 0, null, null);
                if (name_len > 0) {
                    const name_u8 = try ctx.alloc.alloc(u8, @intCast(name_len));
                    defer ctx.alloc.free(name_u8);
                    _ = kernel32.WideCharToMultiByte(CP_UTF8, 0, name_u16.ptr, @intCast(name_u16.len), name_u8.ptr, name_len, null, null);

                    // Skip ignore patterns
                    if (!std.mem.eql(u8, name_u8, ".git") and !std.mem.eql(u8, name_u8, "node_modules")) {
                        const full_path = try std.fs.path.join(ctx.alloc, &.{ path_u8, name_u8 });
                        defer ctx.alloc.free(full_path);

                        if ((find_data.dwFileAttributes & 0x10) != 0) {
                            try process_path(ctx, full_path);
                        } else {
                            const path_dupe = try ctx.alloc.dupe(u8, full_path);
                            ctx.wg.start();
                            try ctx.pool.spawn(search_file_task, .{ ctx, path_dupe });
                        }
                    }
                }
            }

            if (!kernel32.FindNextFileW(find_handle, &find_data)) break;
        }
    } else {
        // It's a file
        const path_dupe = try ctx.alloc.dupe(u8, path_u8);
        ctx.wg.start();
        try ctx.pool.spawn(search_file_task, .{ ctx, path_dupe });
    }
}

fn search_file_task(ctx: *SearchContext, path_u8: []u8) void {
    defer ctx.wg.finish();

    // 1. Convert path to UTF-16 on the heap
    const path_utf16 = sliceToHeapUTF16(ctx.alloc, path_u8) catch {
        ctx.alloc.free(path_u8);
        return;
    };
    defer ctx.alloc.free(path_utf16);

    // 2. Open File using raw Win32
    const handle = kernel32.CreateFileW(
        path_utf16.ptr,
        w.GENERIC_READ,
        w.FILE_SHARE_READ,
        null,
        w.OPEN_EXISTING,
        w.FILE_ATTRIBUTE_NORMAL,
        null,
    );

    if (handle == w.INVALID_HANDLE_VALUE) {
        ctx.alloc.free(path_u8);
        return;
    }
    defer _ = kernel32.CloseHandle(handle);

    // 3. Get File Size and Read
    var file_size: i64 = 0;
    if (!kernel32.GetFileSizeEx(handle, &file_size)) {
        ctx.alloc.free(path_u8);
        return;
    }

    // Limit read size to 1MB for search
    const max_size: u32 = 1024 * 1024;
    const read_size: u32 = if (file_size > max_size) max_size else @intCast(file_size);

    const buffer = ctx.alloc.alloc(u8, read_size) catch {
        ctx.alloc.free(path_u8);
        return;
    };
    defer ctx.alloc.free(buffer);

    var bytes_read: u32 = 0;
    if (!kernel32.ReadFile(handle, buffer.ptr, read_size, &bytes_read, null)) {
        ctx.alloc.free(path_u8);
        return;
    }

    const content = buffer[0..bytes_read];

    // 4. Search and Add Result
    if (std.mem.indexOf(u8, content, ctx.query) != null) {
        ctx.addResult(path_u8) catch {
            ctx.alloc.free(path_u8);
        };
    } else {
        ctx.alloc.free(path_u8);
    }
}
