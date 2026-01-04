# Rust (Tauri) & Others Roadmap

## 🦀 Rust (Tauri 2.0)
- **Role:** The Shell. Handles Windowing, Menu, and System Tray.
- **Status:** Basic setup complete.
- [ ] **Window:** Implement Frameless Window (Acrylic/Mica transparency).
- [ ] **Menu:** Native System Menu integration.

## 🐘 PostgreSQL
- **Role:** Persistent State (Project history, User settings, AI Memory).
- **Status:** Temporarily Disabled to fix startup.
- [ ] **Re-enable:** Uncomment `Aether.Repo` in supervision tree.
- [ ] **Vector Search:** `pgvector` for AI embeddings.

## 🛠️ Tooling & Scripts
- **Role:** Developer Experience (DX).
- ✅ `start_dev.bat`: The golden path.
- ✅ `verify_setup.bat`: CI in a box.
- [ ] `install_deps.bat`: One-click setup for new devs.
