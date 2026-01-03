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
    make_badarg: *const fn(env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    inspect_binary: *const fn(env: ?*ErlNifEnv, term: ERL_NIF_TERM, bin: *ErlNifBinary) callconv(.c) c_int,
    make_empty_list: *const fn(env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    make_list_cell: *const fn(env: ?*ErlNifEnv, head: ERL_NIF_TERM, tail: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_tuple2: *const fn(env: ?*ErlNifEnv, e1: ERL_NIF_TERM, e2: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_atom: *const fn(env: ?*ErlNifEnv, name: [*c]const u8) callconv(.c) ERL_NIF_TERM,
    make_binary: *const fn(env: ?*ErlNifEnv, bin: *ErlNifBinary) callconv(.c) ERL_NIF_TERM,
    alloc_binary: *const fn(size: usize, bin: *ErlNifBinary) callconv(.c) c_int,
    release_binary: *const fn(bin: *ErlNifBinary) callconv(.c) void,
};

export fn zig_scan(env: ?*ErlNifEnv, argc: c_int, argv: [*c]const ERL_NIF_TERM, api: *const WinNifApi) ERL_NIF_TERM {
    if (argc != 1) return api.make_badarg(env);

    var path_bin: ErlNifBinary = undefined;
    if (api.inspect_binary(env, argv[0], &path_bin) == 0) {
        return api.make_badarg(env);
    }

    const path_slice = path_bin.data[0..path_bin.size];
    
    var dir = std.fs.cwd().openDir(path_slice, .{ .iterate = true }) catch {
        return make_error_tuple(env, api, "path_msg_failure"); 
    };
    defer dir.close();

    var iterator = dir.iterate();
    
    var buffer = std.ArrayListUnmanaged(u8){};
    const allocator = std.heap.page_allocator;
    defer buffer.deinit(allocator);

    while (iterator.next() catch { return make_error_tuple(env, api, "iter_error"); }) |entry| {
        // 1. Type (1 byte)
        const type_byte: u8 = switch (entry.kind) {
            .file => 1,
            .directory => 2,
            .sym_link => 3,
            else => 0,
        };
        buffer.append(allocator, type_byte) catch return make_error_tuple(env, api, "oom");

        // 2. Length (2 bytes, LE)
        const len: u16 = @intCast(entry.name.len);
        buffer.writer(allocator).writeInt(u16, len, .little) catch return make_error_tuple(env, api, "oom");

        // 3. Name (Bytes)
        buffer.appendSlice(allocator, entry.name) catch return make_error_tuple(env, api, "oom");
    }

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
