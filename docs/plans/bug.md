# Bug Tracking & Stability Plan

## 🐛 Known Issues (Backlog)

### Critical
- [ ] **Database Disabled:** `Aether.Repo` is commented out. Need to restore it safely.
- [ ] **Symlinks:** Zig Scanner currently reports symlinks but might not follow them correctly on Windows.

### Major
- [ ] **Large Dir Freeze:** Scanning `C:/` still causes UI hiccups (need better chunking/backpressure).
- [ ] **Double Decoding:** Elixir decodes NIF binary, then re-encodes for Phoenix. CPU waste.

### Minor
- [ ] **Icons:** File Explorer has no icons.
- [ ] **Styling:** DaisyUI artifacts remain (buttons looking generic).

## 🛡️ Stability Initiatives
- **"Crash Only" Software:** If the backend gets into a bad state, it should crash and restart clean (Erlang philosophy).
- **Zombie Killer:** `start_dev.bat` now aggressively hunts down port hogs.
