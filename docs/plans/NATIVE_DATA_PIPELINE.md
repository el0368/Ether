# Plan: Native Data Pipeline (Unified)

## 🎯 Goal
Consolidate the "Zero-Copy", "Binary Protocol", and "Sync Loop" efforts into a single authoritative strategy for high-performance data flow across Zig, Elixir, and Svelte.

## 🔗 The Three-Layer Loop

### 1. Source (Zig Engine)
- **Format:** Use `AetherProtocol` (binary slabs).
- **Mechanism:** `enif_send` asynchronously fires binary blobs to the Elixir caller.
- **Optimization:** Use **Zero-Copy** (pass binary pointer directly) to Elixir.

### 2. Brain (Elixir Orchestrator)
- **Role:** Receive binary blobs in `Ether.Native.Scanner`.
- **Logic:** Do NOT decode the binary in Elixir.
- **Transport:** Pass raw binary frames over Phoenix Channels (Standardizing on `{:binary, data}`).

### 3. Face (Svelte UI)
- **Decoding:** Use `nif_decoder.ts` to transform binary slabs directly into the Svelte store.
- **Delta Merging:** Efficiently update the UI tree with small binary delta fragments instead of full list replacement.

## 🚀 Impact on Existing Plans
- **Zig Plan:** This document fulfills "Phase 3: Pipeline Squeeze".
- **Elixir Plan:** Replaces "Zero-Copy Receiver" refactor.
- **Sync Plan:** Replaces "Phase 1: Binary Standard".

## 🛠️ Verification
- Benchmark: Verify <50ms "Disk-to-UI" latency for 10k file updates.
- Integrity: Zero memory growth in the Elixir heap when passing 100MB+ binary streams.
