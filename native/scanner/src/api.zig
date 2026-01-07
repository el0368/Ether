//! API Module: WinNifApi struct and type exports
//! The Linker Shield - Bridges C and Zig

const e = @import("beam/erl_nif.zig");

// Re-export for entry.c compatibility
pub const ErlNifEnv = e.ErlNifEnv;
pub const ERL_NIF_TERM = e.ERL_NIF_TERM;
pub const ErlNifBinary = e.ErlNifBinary;

/// WinNifApi: Function pointer struct matching C definition
/// This is the bridge that allows Zig to call BEAM functions safely
pub const WinNifApi = extern struct {
    make_badarg: *const fn (env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    inspect_binary: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, bin: *ErlNifBinary) callconv(.c) c_int,
    make_empty_list: *const fn (env: ?*ErlNifEnv) callconv(.c) ERL_NIF_TERM,
    make_list_cell: *const fn (env: ?*ErlNifEnv, head: ERL_NIF_TERM, tail: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_tuple2: *const fn (env: ?*ErlNifEnv, e1: ERL_NIF_TERM, e2: ERL_NIF_TERM) callconv(.c) ERL_NIF_TERM,
    make_atom: *const fn (env: ?*ErlNifEnv, name: [*c]const u8) callconv(.c) ERL_NIF_TERM,
    make_binary: *const fn (env: ?*ErlNifEnv, bin: *ErlNifBinary) callconv(.c) ERL_NIF_TERM,
    alloc_binary: *const fn (size: usize, bin: *ErlNifBinary) callconv(.c) c_int,
    release_binary: *const fn (bin: *ErlNifBinary) callconv(.c) void,
    consume_timeslice: *const fn (env: ?*ErlNifEnv, percent: c_int) callconv(.c) c_int,
    alloc: *const fn (size: usize) callconv(.c) ?*anyopaque,
    free: *const fn (ptr: ?*anyopaque) callconv(.c) void,
    get_local_pid: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, pid: *anyopaque) callconv(.c) c_int,
    send: *const fn (env: ?*ErlNifEnv, to_pid: *const anyopaque, msg_env: ?*ErlNifEnv, msg: ERL_NIF_TERM) callconv(.c) c_int,
    // Resource Management (ADR-017)
    alloc_resource: *const fn (size: usize) callconv(.c) ?*anyopaque,
    release_resource: *const fn (obj: ?*anyopaque) callconv(.c) void,
    make_resource: *const fn (env: ?*ErlNifEnv, obj: ?*anyopaque) callconv(.c) ERL_NIF_TERM,
    get_resource: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM, objp: *?*anyopaque) callconv(.c) c_int,
    // Phase 3-4: Type Validation (Defensive API)
    is_binary: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM) callconv(.c) c_int,
    is_pid: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM) callconv(.c) c_int,
    is_list: *const fn (env: ?*ErlNifEnv, term: ERL_NIF_TERM) callconv(.c) c_int,
    // Phase 3-4: Memory Optimization
    realloc: *const fn (ptr: ?*anyopaque, size: usize) callconv(.c) ?*anyopaque,
    realloc_binary: *const fn (bin: *ErlNifBinary, size: usize) callconv(.c) c_int,
    // Phase 5: Thread-Safe Messaging
    alloc_env: *const fn () callconv(.c) ?*ErlNifEnv,
    free_env: *const fn (env: ?*ErlNifEnv) callconv(.c) void,
    make_uint64: *const fn (env: ?*ErlNifEnv, val: u64) callconv(.c) ERL_NIF_TERM,
};

/// Helper to create {:error, reason} tuple
pub fn make_error_tuple(env: ?*ErlNifEnv, api: *const WinNifApi, msg: [*c]const u8) ERL_NIF_TERM {
    return api.make_tuple2(env, api.make_atom(env, "error"), api.make_atom(env, msg));
}
