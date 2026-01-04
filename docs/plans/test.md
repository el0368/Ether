# Testing Roadmap

## 🧪 Core Strategy
- **Pyramid:** Fast Unit Tests (Elixir) > Native Safety Tests (Zig) > End-to-End (Setup Scripts).
- **No Flakiness:** Tests must be deterministic.
- **CI/CD:** Local scripts must match CI environment.

## ✅ Existing Suites
- **Unit (Elixir):** `mix test`
  - Covers Agents, Channels, and core Logic.
- **Native (Zig):** `scripts/build_nif.bat`
  - Verifies NIF compilation and binary safety.
- **Integration (Batches):** `verify_setup.bat`
  - Full environment check (Elixir + Bun + Zig + Rust).

## 🚧 Roadmap
- [ ] **Phase 1: Property-Based Testing**
  - Use `StreamData` to fuzz the NIF with random binary inputs.
  - Goal: Crash the NIF locally so it never crashes in prod.

- [ ] **Phase 2: UI Testing (E2E)**
  - Integrate `Playwright` or `Wallaby`?
  - Hard due to WebSockets/Canvas.
  - *Current Strategy:* Manual verification via `start_dev.bat`.

- [ ] **Phase 3: Performance Regression**
  - `benchmark_fcp.exs`: Ensure "time-to-file-list" stays under 5ms.
