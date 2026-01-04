#include <erl_nif.h>

// Wrappers to handle macros/variadics
static ERL_NIF_TERM wrap_make_empty_list(ErlNifEnv* env) {
    return enif_make_list(env, 0);
}

static ERL_NIF_TERM wrap_make_tuple2(ErlNifEnv* env, ERL_NIF_TERM e1, ERL_NIF_TERM e2) {
    return enif_make_tuple(env, 2, e1, e2);
}

// Struct definition matching Zig
typedef struct {
    ERL_NIF_TERM (*make_badarg)(ErlNifEnv* env);
    int (*inspect_binary)(ErlNifEnv* env, ERL_NIF_TERM term, ErlNifBinary* bin);
    ERL_NIF_TERM (*make_empty_list)(ErlNifEnv* env); // Changed from generic make_list
    ERL_NIF_TERM (*make_list_cell)(ErlNifEnv* env, ERL_NIF_TERM head, ERL_NIF_TERM tail);
    ERL_NIF_TERM (*make_tuple2)(ErlNifEnv* env, ERL_NIF_TERM e1, ERL_NIF_TERM e2);
    ERL_NIF_TERM (*make_atom)(ErlNifEnv* env, const char* name);
    ERL_NIF_TERM (*make_binary)(ErlNifEnv* env, ErlNifBinary* bin);
    int (*alloc_binary)(size_t size, ErlNifBinary* bin);
    void (*release_binary)(ErlNifBinary* bin);
    // BEAM Citizenship: Time-slice consumption for polite NIFs
    int (*consume_timeslice)(ErlNifEnv* env, int percent);
    // Raw Memory Management (for Zig Allocator)
    void* (*alloc)(size_t size);
    void (*free)(void* ptr);

    // Messaging
    int (*get_local_pid)(ErlNifEnv* env, ERL_NIF_TERM term, void* pid);
    int (*send)(ErlNifEnv* env, const void* to_pid, ErlNifEnv* msg_env, ERL_NIF_TERM msg);
} WinNifApi;

// Declare Zig function
extern ERL_NIF_TERM zig_scan(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);

static int wrap_get_local_pid(ErlNifEnv* env, ERL_NIF_TERM term, void* pid) {
    return enif_get_local_pid(env, term, (ErlNifPid*)pid);
}

static int wrap_send(ErlNifEnv* env, const void* to_pid, ErlNifEnv* msg_env, ERL_NIF_TERM msg) {
    return enif_send(env, (const ErlNifPid*)to_pid, msg_env, msg);
}

static ERL_NIF_TERM scan_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    WinNifApi api;
    api.make_badarg = enif_make_badarg;
    api.inspect_binary = enif_inspect_binary;
    api.make_empty_list = wrap_make_empty_list; // Wrapper
    api.make_list_cell = enif_make_list_cell;
    api.make_tuple2 = wrap_make_tuple2;         // Wrapper
    api.make_atom = enif_make_atom;
    api.make_binary = enif_make_binary;
    api.alloc_binary = enif_alloc_binary;
    api.release_binary = enif_release_binary;
    api.consume_timeslice = enif_consume_timeslice; // BEAM Citizenship
    api.alloc = enif_alloc;
    api.free = enif_free;
    api.get_local_pid = wrap_get_local_pid;
    api.send = wrap_send;

    return zig_scan(env, argc, argv, &api);
}

static ErlNifFunc nif_funcs[] = {
    {"scan_nif", 2, scan_wrapper, ERL_NIF_DIRTY_JOB_IO_BOUND}
};

ERL_NIF_INIT(Elixir.Aether.Native.Scanner, nif_funcs, NULL, NULL, NULL, NULL)
