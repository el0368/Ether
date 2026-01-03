const std = @import("std");

const erl = @cImport({
    // Fix for OTP 27 issue where memcpy is assumed 
    @cInclude("string.h");
    
    // Force Windows NIF definitions
    @cDefine("_WIN32", {});
    
    // Attempt to force correct macro expansion for TWinDynNifCallbacks
    @cDefine("ERL_NIF_API_FUNC_DECL(RET, NAME, ARGS)", "RET (*NAME) ARGS;");
    
    @cInclude("erl_nif.h");
});

// We must define the global callback structure storage because the macros 
// in erl_nif.h (like enif_alloc) refer to 'WinDynNifCallbacks'.
// The header usually declares it 'extern', so we provide the definition here.
export var WinDynNifCallbacks: erl.TWinDynNifCallbacks = undefined;

// Wrapper to allocate an Erlang binary from a Zig slice
fn make_binary(env:?*erl.ErlNifEnv, data:[]const u8) erl.ERL_NIF_TERM {
    var bin: erl.ErlNifBinary = undefined;
    if (erl.enif_alloc_binary(data.len, &bin) == 0) {
        // Allocation failed (OOM)
        return erl.enif_make_atom(env, "error");
    }
    @memcpy(bin.data[0..data.len], data);
    return erl.enif_make_binary(env, &bin);
}

// The NIF Function: scan/1
export fn scan(env:?*erl.ErlNifEnv, argc: c_int, argv: [*c]const erl.ERL_NIF_TERM) erl.ERL_NIF_TERM {
    // Suppress unused parameter warning
    _ = argc;

    // 1. Parse Argument (Root Path)
    var path_bin: erl.ErlNifBinary = undefined;
    if (erl.enif_inspect_binary(env, argv[0], &path_bin) == 0) {
        return erl.enif_make_badarg(env);
    }
    const root_path = path_bin.data[0..path_bin.size];

    // 2. Perform Scanning (Simplified for initial connectivity test)
    // We strictly use std.fs from Zig.
    
    // For now, return a success tuple with the path to prove we received it correctly
    // "Scan Completed via Zig Native: " + root_path
    
    const prefix = "Scan Completed via Zig Native: ";
    const result_len = prefix.len + root_path.len;
    
    var bin: erl.ErlNifBinary = undefined;
    if (erl.enif_alloc_binary(result_len, &bin) == 0) {
         return erl.enif_make_string(env, "oom", erl.ERL_NIF_LATIN1);
    }
    
    // Manual memcpy construction since we are in raw mode
    @memcpy(bin.data[0..prefix.len], prefix);
    @memcpy(bin.data[prefix.len..result_len], root_path);
    
    const msg = erl.enif_make_binary(env, &bin);

    return erl.enif_make_tuple2(env, 
        erl.enif_make_atom(env, "ok"),
        msg
    );
}

// Define the NIF function table
var funcs = [_]erl.ErlNifFunc{
   .{
       .name = "scan",
       .arity = 1,
       .fptr = scan,
        // Mark as Dirty IO to prevent scheduler blocking 
       .flags = erl.ERL_NIF_DIRTY_JOB_IO_BOUND, 
    },
};

// Define the Entry structure
var entry = erl.ErlNifEntry{
   .major = erl.ERL_NIF_MAJOR_VERSION,
   .minor = erl.ERL_NIF_MINOR_VERSION,
   .name = "Elixir.Aether.Native.Scanner", // Must match Elixir module
   .num_of_funcs = funcs.len,
   .funcs = &funcs,
   .load = null, 
   .reload = null,
   .upgrade = null,
   .unload = null,
   .vm_variant = "beam.vanilla",
   .options = 1, // ERL_NIF_ENTRY_OPTIONS_WIN_DYN_NIF (Critical!)
   .sizeof_ErlNifResourceTypeInit = @sizeOf(erl.ErlNifResourceTypeInit),
   .min_erts = "erts-15.0", // OTP 27 corresponds to ERTS 15.0
};

// Export the initialization function expected by the BEAM loader
export fn nif_init(callbacks:?*erl.TWinDynNifCallbacks) *erl.ErlNifEntry {
    if (callbacks) |cb| {
        // Copy the callbacks from the VM into our local global struct
        // This effectively "links" the API functions at runtime
        const dest = &WinDynNifCallbacks; // const pointer to var is fine
        const src = cb;
        const size = @sizeOf(erl.TWinDynNifCallbacks);
        @memcpy(@as([*]u8, @ptrCast(dest))[0..size], 
                @as([*]const u8, @ptrCast(src))[0..size]);
    }
    return &entry;
}
