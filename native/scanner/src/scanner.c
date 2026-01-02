#include <erl_nif.h>
#include <string.h>
#include <stdio.h>

// Simple Scan NIF implementation in C
// This allows us to use standard C parsing for erl_nif.h macros on Windows.

static ERL_NIF_TERM scan(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    ErlNifBinary path_bin;
    
    if (argc != 1 || !enif_inspect_binary(env, argv[0], &path_bin)) {
        return enif_make_badarg(env);
    }
    
    // Create a return string
    const char* prefix = "Native C Scanner: ";
    size_t prefix_len = strlen(prefix);
    size_t total_len = prefix_len + path_bin.size;
    
    ErlNifBinary result_bin;
    if (!enif_alloc_binary(total_len, &result_bin)) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "oom"));
    }
    
    memcpy(result_bin.data, prefix, prefix_len);
    memcpy(result_bin.data + prefix_len, path_bin.data, path_bin.size);
    
    return enif_make_tuple2(env, 
        enif_make_atom(env, "ok"), 
        enif_make_binary(env, &result_bin));
}

static ErlNifFunc nif_funcs[] = {
    {"scan", 1, scan, ERL_NIF_DIRTY_JOB_IO_BOUND}
};

// Initialize the NIF.
ERL_NIF_INIT(Elixir.Aether.Native.Scanner, nif_funcs, NULL, NULL, NULL, NULL)
