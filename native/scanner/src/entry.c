#include <erl_nif.h>

// Windows DLL export macro
#ifdef _WIN32
    #define DLL_EXPORT __declspec(dllexport)
#else
    #define DLL_EXPORT
#endif

// =============================================================================
// Global Resource Type (initialized in nif_load)
// =============================================================================
static ErlNifResourceType* SCANNER_RESOURCE_TYPE = NULL;

// Forward declaration of Zig destructor
extern void zig_resource_destructor(ErlNifEnv* env, void* obj);

// Resource destructor callback (called by BEAM GC)
static void resource_dtor(ErlNifEnv* env, void* obj) {
    zig_resource_destructor(env, obj);
}

// NIF load callback - register resource type
static int nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    (void)priv_data;
    (void)load_info;
    
    SCANNER_RESOURCE_TYPE = enif_open_resource_type(
        env,
        NULL,
        "scanner_resource",
        resource_dtor,
        ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER,
        NULL
    );
    
    if (SCANNER_RESOURCE_TYPE == NULL) {
        return -1;
    }
    return 0;
}

// =============================================================================
// Wrappers to handle macros/variadics
// =============================================================================
static ERL_NIF_TERM wrap_make_empty_list(ErlNifEnv* env) {
    return enif_make_list(env, 0);
}

static ERL_NIF_TERM wrap_make_tuple2(ErlNifEnv* env, ERL_NIF_TERM e1, ERL_NIF_TERM e2) {
    return enif_make_tuple(env, 2, e1, e2);
}

static int wrap_get_local_pid(ErlNifEnv* env, ERL_NIF_TERM term, void* pid) {
    return enif_get_local_pid(env, term, (ErlNifPid*)pid);
}

static int wrap_send(ErlNifEnv* env, const void* to_pid, ErlNifEnv* msg_env, ERL_NIF_TERM msg) {
    return enif_send(env, (const ErlNifPid*)to_pid, msg_env, msg);
}

// =============================================================================
// Resource Management Wrappers
// =============================================================================
static void* wrap_alloc_resource(size_t size) {
    return enif_alloc_resource(SCANNER_RESOURCE_TYPE, size);
}

static void wrap_release_resource(void* obj) {
    enif_release_resource(obj);
}

static ERL_NIF_TERM wrap_make_resource(ErlNifEnv* env, void* obj) {
    return enif_make_resource(env, obj);
}

static int wrap_get_resource(ErlNifEnv* env, ERL_NIF_TERM term, void** objp) {
    return enif_get_resource(env, term, SCANNER_RESOURCE_TYPE, objp);
}

// =============================================================================
// Phase 3-4: Type Validation Wrappers (Defensive API)
// =============================================================================
static int wrap_is_binary(ErlNifEnv* env, ERL_NIF_TERM term) {
    return enif_is_binary(env, term);
}

static int wrap_is_pid(ErlNifEnv* env, ERL_NIF_TERM term) {
    return enif_is_pid(env, term);
}

static int wrap_is_list(ErlNifEnv* env, ERL_NIF_TERM term) {
    return enif_is_list(env, term);
}

// =============================================================================
// Phase 3-4: Binary Realloc (Memory Optimization)
// =============================================================================
static void* wrap_realloc(void* ptr, size_t size) {
    return enif_realloc(ptr, size);
}

static int wrap_realloc_binary(ErlNifBinary* bin, size_t size) {
    return enif_realloc_binary(bin, size);
}

// =============================================================================
// API Struct definition matching Zig
// =============================================================================
typedef struct {
    ERL_NIF_TERM (*make_badarg)(ErlNifEnv* env);
    int (*inspect_binary)(ErlNifEnv* env, ERL_NIF_TERM term, ErlNifBinary* bin);
    ERL_NIF_TERM (*make_empty_list)(ErlNifEnv* env);
    ERL_NIF_TERM (*make_list_cell)(ErlNifEnv* env, ERL_NIF_TERM head, ERL_NIF_TERM tail);
    ERL_NIF_TERM (*make_tuple2)(ErlNifEnv* env, ERL_NIF_TERM e1, ERL_NIF_TERM e2);
    ERL_NIF_TERM (*make_atom)(ErlNifEnv* env, const char* name);
    ERL_NIF_TERM (*make_binary)(ErlNifEnv* env, ErlNifBinary* bin);
    int (*alloc_binary)(size_t size, ErlNifBinary* bin);
    void (*release_binary)(ErlNifBinary* bin);
    int (*consume_timeslice)(ErlNifEnv* env, int percent);
    void* (*alloc)(size_t size);
    void (*free)(void* ptr);
    int (*get_local_pid)(ErlNifEnv* env, ERL_NIF_TERM term, void* pid);
    int (*send)(ErlNifEnv* env, const void* to_pid, ErlNifEnv* msg_env, ERL_NIF_TERM msg);
    
    // Resource Management (ADR-017)
    void* (*alloc_resource)(size_t size);
    void (*release_resource)(void* obj);
    ERL_NIF_TERM (*make_resource)(ErlNifEnv* env, void* obj);
    int (*get_resource)(ErlNifEnv* env, ERL_NIF_TERM term, void** objp);
    
    // Phase 3-4: Type Validation (Defensive API)
    int (*is_binary)(ErlNifEnv* env, ERL_NIF_TERM term);
    int (*is_pid)(ErlNifEnv* env, ERL_NIF_TERM term);
    int (*is_list)(ErlNifEnv* env, ERL_NIF_TERM term);
    
    // Phase 3-4: Memory Optimization
    void* (*realloc)(void* ptr, size_t size);
    int (*realloc_binary)(ErlNifBinary* bin, size_t size);
    
    // Phase 5: Thread-Safe Messaging
    ErlNifEnv* (*alloc_env)(void);
    void (*free_env)(ErlNifEnv* env);
    ERL_NIF_TERM (*make_uint64)(ErlNifEnv* env, ErlNifUInt64 val);
} WinNifApi;

// =============================================================================
// Declare Zig functions
// =============================================================================
extern ERL_NIF_TERM zig_scan(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);
extern ERL_NIF_TERM zig_scan_yieldable(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);
extern ERL_NIF_TERM zig_create_context(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);
extern ERL_NIF_TERM zig_close_context(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);
extern ERL_NIF_TERM zig_search(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[], const WinNifApi* api);

// =============================================================================
// API Builder (shared across all NIF wrappers)
// =============================================================================
static WinNifApi build_api(void) {
    WinNifApi api;
    api.make_badarg = enif_make_badarg;
    api.inspect_binary = enif_inspect_binary;
    api.make_empty_list = wrap_make_empty_list;
    api.make_list_cell = enif_make_list_cell;
    api.make_tuple2 = wrap_make_tuple2;
    api.make_atom = enif_make_atom;
    api.make_binary = enif_make_binary;
    api.alloc_binary = enif_alloc_binary;
    api.release_binary = enif_release_binary;
    api.consume_timeslice = enif_consume_timeslice;
    api.alloc = enif_alloc;
    api.free = enif_free;
    api.get_local_pid = wrap_get_local_pid;
    api.send = wrap_send;
    // Resource Management
    api.alloc_resource = wrap_alloc_resource;
    api.release_resource = wrap_release_resource;
    api.make_resource = wrap_make_resource;
    api.get_resource = wrap_get_resource;
    // Phase 3-4: Type Validation
    api.is_binary = wrap_is_binary;
    api.is_pid = wrap_is_pid;
    api.is_list = wrap_is_list;
    // Phase 3-4: Memory Optimization
    api.realloc = wrap_realloc;
    api.realloc_binary = wrap_realloc_binary;

    // Phase 5: Thread-Safe Messaging
    api.alloc_env = enif_alloc_env;
    api.free_env = enif_free_env;
    api.make_uint64 = enif_make_uint64;

    return api;
}

// =============================================================================
// NIF Wrappers (with Windows DLL export)
// =============================================================================

ERL_NIF_TERM scan_yield_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    WinNifApi api = build_api();
    return zig_scan_yieldable(env, argc, argv, &api);
}

ERL_NIF_TERM create_context_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    WinNifApi api = build_api();
    return zig_create_context(env, argc, argv, &api);
}

ERL_NIF_TERM close_context_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    WinNifApi api = build_api();
    return zig_close_context(env, argc, argv, &api);
}

ERL_NIF_TERM search_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    WinNifApi api = build_api();
    return zig_search(env, argc, argv, &api);
}

// =============================================================================
// NIF Registration
// =============================================================================
static ErlNifFunc nif_funcs[] = {
    {"scan_yield_nif", 3, scan_yield_wrapper, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"create_context_nif", 0, create_context_wrapper, 0},
    {"close_context_nif", 1, close_context_wrapper, 0},
    {"search_nif", 3, search_wrapper, ERL_NIF_DIRTY_JOB_IO_BOUND}
};

ERL_NIF_INIT(Elixir.Ether.Native.Scanner, nif_funcs, nif_load, NULL, NULL, NULL)
