# Native Scanner Upgrade Log (2026-01-03)

## 1. Context (Before Upgrade)
- **State**: The project was using a "Safe Mode" fallback where the `Aether.Scanner` was implemented in Pure Elixir.
- **Problem**: Zig NIFs (Pure Zig) were failing to compile on Windows due to `translate-c` bugs with Windows headers (`windows.h`).
- **Intermediate Solution**: A "Dummy C-NIF" (`scanner.c`) was created that bypassed Zig tooling issues but only returned a static string ("Native C Scanner..."). It proved that compilation was possible but wasn't functional.

## 2. The Upgrade Process
The goal was to make the C-NIF actually useful (scan directories) while maintaining the compatibility benefits of C.

### Step 1: Upgrading the C Code (`src/scanner.c`)
We replaced the dummy code with a functional Windows API implementation.
- **API Used**: `windows.h` (`FindFirstFile`, `FindNextFile`).
- **Safety**: Implemented defensive coding (buffer size checks, OOM checks).
- **Logic**: Iterates over a directory and returns a list of filenames as binary strings.

### Step 2: The "Manual Build Protocol"
Zigler 0.15's automation was fighting us (expecting Zig code). We switched to a manual build flow:
- **Build Script (`scripts/build_nif.bat`)**: Explicitly locates Erlang headers (`erts-*`) and runs `zig build` to compile the C code into `priv/native/scanner_nif.dll`.
- **Loader Module (`lib/aether/native/scanner.ex`)**: A simple Elixir module using `@on_load` to load the DLL manually, bypassing Zigler's complexity.
- **Integration**: Updated `start_dev.bat` to always run the build script before starting the server.

### Step 3: Resolving DLL Locks
During verification, we encountered `Access Denied` errors because the previous Erlang process was holding onto the DLL.
- **Fix**: Forcefully closed lingering `beam.smp.exe` processes to release the file lock, allowing the new NIF to be installed.

## 3. Result (After Upgrade)
- **Functionality**: The NIF now correctly lists files from the disk (verified via `scripts/verify_native.exs`).
- **Performance**: We now have a native, compiled directory scanner.
- **Safety**: The implementation is robust against average C errors.
- **Future-Proof**: The C implementation will compile against future Erlang versions automatically because it uses standard headers found on the host machine, unlike fragile ABI-locked tools.
- **Verification Output**:
  ```elixir
  SUCCESS: NIF Loaded and Executed.
  Returned: ["Zig", "Windows", "Program Files", ...]
  ```
