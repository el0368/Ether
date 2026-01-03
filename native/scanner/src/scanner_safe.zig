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
    
    var list = api.make_empty_list(env);

    while (iterator.next() catch { return make_error_tuple(env, api, "iter_error"); }) |entry| {
        // 1. Create Name Binary
        var name_bin: ErlNifBinary = undefined;
        if (api.alloc_binary(entry.name.len, &name_bin) == 0) {
             return make_error_tuple(env, api, "oom");
        }
        std.mem.copyForwards(u8, name_bin.data[0..entry.name.len], entry.name);
        const name_term = api.make_binary(env, &name_bin);

        // 2. Create Type Atom
        const type_str = switch (entry.kind) {
            .file => "file",
            .directory => "directory",
            .sym_link => "symlink",
            else => "other",
        };
        const type_atom = api.make_atom(env, type_str);

        // 3. Create Tuple {name, type}
        const file_tuple = api.make_tuple2(env, name_term, type_atom);

        // 4. Prepend
        list = api.make_list_cell(env, file_tuple, list);
    }

    return api.make_tuple2(env, api.make_atom(env, "ok"), list);
}

fn make_error_tuple(env: ?*ErlNifEnv, api: *const WinNifApi, msg: [*c]const u8) ERL_NIF_TERM {
    return api.make_tuple2(env, api.make_atom(env, "error"), api.make_atom(env, msg));
}
