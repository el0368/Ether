#include <erl_nif.h>

static ErlNifResourceType* SCANNER_RESOURCE_TYPE = NULL;

extern void zig_resource_destructor(ErlNifEnv* env, void* obj);

static void resource_dtor(ErlNifEnv* env, void* obj) {
    zig_resource_destructor(env, obj);
}

static int nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    SCANNER_RESOURCE_TYPE = enif_open_resource_type(env, NULL, "scanner_resource", resource_dtor, ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER, NULL);
    return (SCANNER_RESOURCE_TYPE == NULL) ? -1 : 0;
}

// Wrapper for Zig NIFs
extern ERL_NIF_TERM zig_scan_yieldable(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], void* api);

static ERL_NIF_TERM scan_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    // API building logic goes here (simplified for initiation)
    // In V1 we passed a pointer to a struct of function pointers
    return enif_make_int(env, 0); 
}

static ErlNifFunc nif_funcs[] = {
    {"scan_yield_nif", 4, scan_wrapper, ERL_NIF_DIRTY_JOB_IO_BOUND}
};

ERL_NIF_INIT(Elixir.Ether.Native.Scanner, nif_funcs, nif_load, NULL, NULL, NULL)
