# Infrastructure & Tooling Roadmap

## 🛠️ Developer Experience (DX)
- **Goal:** "Zero Friction" startup for new developers.
- **Scripts:** Batch scripts for Windows (Primary OS).

## ✅ Completed
- [x] **`start_dev.bat` (Resilient Startup):** 
  - **Zombie Cleanup:** Automatically detects and kills orphaned BEAM processes on Port 4000.
  - **Dependency Auto-Audit:** Prompts for `mix deps.get` and `bun install` before launch.
  - **Sequential Ignition:** Waits for the Phoenix backend to be ready via `curl` health-check before opening the Tauri window.
- [x] **`verify_setup.bat`:** End-to-End environment verification (Elixir + Bun + Zig + Rust).
- [x] **`check_env.bat`:** Version checking for all dependencies.

## 🚧 Roadmap
- [ ] **`install_deps.bat`:** One-click setups:
  - Install Scoop?
  - Install Elixir/Erlang/Bun via Scoop.
- [ ] **CI Pipeline:** GitHub Actions workflow.
  - Matrix testing (Windows/Linux/Mac).

## 📦 Distribution
- **Goal:** One-click installers.
- [ ] **MSI Installer:** Wix Toolset integration via Tauri.
- [ ] **Auto-Updater:** Tauri Updater implementation.
- [ ] **Signing:** obtaining Windows Code Signing certificates.
