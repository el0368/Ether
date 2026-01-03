#include <erl_nif.h>
#include <windows.h>
#include <stdio.h>

// Definitive Robust Scanner
// 1. Uses Wide APIs (FindFirstFileW) for full Unicode support (🚀, 📁, etc.)
// 2. Uses dynamic allocation for paths to support Long Paths (> 260 chars)
// 3. Handles UTF-8 <-> UTF-16 conversion internally

static ERL_NIF_TERM scan(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    ErlNifBinary path_bin;
    
    // 1. Validate Input (UTF-8 Binary)
    if (argc != 1 || !enif_inspect_binary(env, argv[0], &path_bin)) {
        return enif_make_badarg(env);
    }

    // 2. Convert UTF-8 to UTF-16 (Wide Char)
    // First, ask Windows how much space we need
    int wide_len = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)path_bin.data, path_bin.size, NULL, 0);
    if (wide_len == 0) {
        return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "invalid_utf8"));
    }

    // Allocate buffer for Wide String (plus extra for "\\*" and null terminator)
    // We add 4 extra WCHARs for possible prefixing or suffixing logic safely
    WCHAR* search_path = (WCHAR*)enif_alloc((wide_len + 5) * sizeof(WCHAR));
    if (!search_path) return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "oom"));

    // Perform the conversion
    MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)path_bin.data, path_bin.size, search_path, wide_len);
    search_path[wide_len] = L'\0'; // Null terminate basic path

    // 3. Prepare Path (Handle Suffixes)
    // Check if it ends in slash
    if (wide_len > 0 && search_path[wide_len - 1] != L'\\' && search_path[wide_len - 1] != L'/') {
        wcscat(search_path, L"\\*");
    } else {
        wcscat(search_path, L"*");
    }

    // 4. Start Scanning (Wide API)
    WIN32_FIND_DATAW find_data;
    HANDLE hFind = FindFirstFileW(search_path, &find_data);
    
    // Free the search path string immediately as we don't need it anymore
    enif_free(search_path); 

    if (hFind == INVALID_HANDLE_VALUE) {
        // Distinguish errors? For now, just path_not_found or permission
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "path_not_found"));
    }

    ERL_NIF_TERM file_list = enif_make_list(env, 0); // Start with empty list

    do {
        // Skip "." and ".."
        if (wcscmp(find_data.cFileName, L".") == 0 || wcscmp(find_data.cFileName, L"..") == 0) {
            continue;
        }

        // 5. Convert Result Back to UTF-8
        int utf8_len = WideCharToMultiByte(CP_UTF8, 0, find_data.cFileName, -1, NULL, 0, NULL, NULL);
        if (utf8_len <= 1) continue; // Should not happen

        ErlNifBinary name_bin;
        // utf8_len includes the null terminator, but we want binary size without it
        if (!enif_alloc_binary(utf8_len - 1, &name_bin)) {
            FindClose(hFind);
            return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "oom"));
        }

        WideCharToMultiByte(CP_UTF8, 0, find_data.cFileName, -1, (LPSTR)name_bin.data, utf8_len, NULL, NULL);
        
        ERL_NIF_TERM name_term = enif_make_binary(env, &name_bin);
        file_list = enif_make_list_cell(env, name_term, file_list);

    } while (FindNextFileW(hFind, &find_data) != 0);

    FindClose(hFind);

    return enif_make_tuple2(env, 
        enif_make_atom(env, "ok"), 
        file_list);
}

static ErlNifFunc nif_funcs[] = {
    {"scan", 1, scan, ERL_NIF_DIRTY_JOB_IO_BOUND}
};

ERL_NIF_INIT(Elixir.Aether.Native.Scanner, nif_funcs, NULL, NULL, NULL, NULL)
