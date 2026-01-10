const std = @import("std");

pub const ErlNifEnv = anyopaque;
pub const ERL_NIF_TERM = usize;

pub const ErlNifBinary = struct {
    size: usize,
    data: [*]u8,
    ref_bin: ?*anyopaque,
};

pub const WinNifApi = struct {
    make_badarg: *const fn (env: ?*ErlNifEnv) ERL_NIF_TERM,
    inspect_binary: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, bin: *ErlNifBinary) c_int,
    make_empty_list: *const fn (env: ?*ErlNifEnv) ERL_NIF_TERM,
    make_list_cell: *const fn (env: ?*ErlNifEnv, head: ERL_NIF_TERM, tail: ERL_NIF_TERM) ERL_NIF_TERM,
    make_tuple2: *const fn (env: ?*ErlNifEnv, e1: ERL_NIF_TERM, e2: ERL_NIF_TERM) ERL_NIF_TERM,
    make_atom: *const fn (env: ?*ErlNifEnv, name: [*:0]const u8) ERL_NIF_TERM,
    make_binary: *const fn (env: ?*ErlNifEnv, bin: *ErlNifBinary) ERL_NIF_TERM,
    alloc_binary: *const fn (size: usize, bin: *ErlNifBinary) c_int,
    release_binary: *const fn (bin: *ErlNifBinary) void,
    consume_timeslice: *const fn (env: ?*ErlNifEnv, percent: c_int) c_int,
    alloc: *const fn (size: usize) ?*anyopaque,
    free: *const fn (ptr: ?*anyopaque) void,
    get_local_pid: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, pid: *anyopaque) c_int,
    send: *const fn (env: ?*ErlNifEnv, to_pid: *const anyopaque, msg_env: ?*ErlNifEnv, msg: ERL_NIF_TERM) c_int,
    alloc_resource: *const fn (size: usize) ?*anyopaque,
    release_resource: *const fn (obj: ?*anyopaque) void,
    make_resource: *const fn (env: ?*ErlNifEnv, obj: ?*anyopaque) ERL_NIF_TERM,
    get_resource: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, objp: *?*anyopaque) c_int,
    alloc_env: *const fn () ?*ErlNifEnv,
    free_env: *const fn (env: ?*ErlNifEnv) void,
    make_uint64: *const fn (env: ?*ErlNifEnv, val: u64) ERL_NIF_TERM,
    get_int: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, ip: *c_int) c_int,
};
