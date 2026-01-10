This is a sophisticated design choice often seen in high-performance platforms like **Discord** and **VS Code**. By choosing this hybrid model, we are balancing **raw speed** for critical functions with **extreme resilience** for untrusted or third-party code.

Here is a detailed elaboration of **ADR-002: Port-Isolated Extensions with NIF Core** in English.

---

### 🏛️ ADR-002: The Hybrid Native Strategy (NIF Core vs. Port Extensions)

#### 1. The Core Strategy: NIF for "Reflex" Tasks

We implement the **Aether Core** (specifically the File Scanner and Indexer) as a **NIF (Native Implemented Function)** using Zig.

* **Why NIF?** * **Zero-Copy Latency:** NIFs run inside the same memory address space as the Erlang VM (BEAM). This allows us to share memory buffers directly, achieving sub-millisecond response times for scanning 100k+ files.
* **Direct BEAM Integration:** By using the `beam.allocator`, the core engine's memory usage is tracked by Elixir's garbage collector, preventing "hidden" memory leaks.
* **The "Reflex" Concept:** These are tasks the IDE must perform instantly. Any overhead from Inter-Process Communication (IPC) would make the UI feel "floaty."



#### 2. The Extension Host: Ports for "Third-Party" Tasks

User-created extensions or optional plugins are executed as **OS Ports** (Standalone Sidecar processes).

* **Why Ports?**
* **The Fault Isolation Wall:** The single greatest danger of a NIF is that a **Segmentation Fault** in the native code will kill the entire Elixir application. We trust our core Zig code (the NIF), but we cannot trust third-party plugins.
* **Process Sovereignty:** If an extension written in Python or Rust crashes, only that specific process dies. The Elixir Supervisor catches the exit signal and can restart only that extension without the user ever losing their work in the main editor.
* **Language Agnosticism:** Because Ports communicate via standard pipes (stdin/stdout), extensions can be written in **any language** (Go, Rust, Node.js, Python). This mirrors the VS Code "Extension Host" model.



#### 3. Comparing the Failure Domains

| Feature | Core Engine (NIF) | Extensions (Port) |
| --- | --- | --- |
| **Execution** | Inside the BEAM | Separate OS Process |
| **Communication** | Direct Memory Access | Pipe (JSON-RPC / Binary) |
| **Risk Level** | High (Crash = App Death) | Low (Crash = Plugin Restart) |
| **Optimization** | Raw Throughput (1800 ops/s) | Flexibility & Safety |
| **Role in Aether** | "The Reflexes" | "The Skillset" |

#### 4. The "Strict" Engineering Result

By implementing this split, Aether achieves **Industrial-Grade Stability**:

1. The user gets **instant file navigation** because the core engine is a NIF.
2. The user enjoys an **unbreakable experience** because a buggy plugin cannot crash the IDE.
3. We maintain **Traceability** because we can monitor the health of the NIF through Telemetry and the health of Ports through OS process IDs.

---

### 🏁 Why is this the "Elite" Way?

Most IDEs choose one or the other:

* **Electron apps (VS Code/Cursor):** Everything is a separate process. It's safe, but it consumes massive RAM due to JSON serialization between processes.
* **Native IDEs (old C++ editors):** Everything is in one memory space. It's fast, but one bad plugin can crash the whole program.

**Aether's Hybrid Approach** takes the best of both worlds: **NIF Speed** where we need to be fast, and **Port Safety** where we need to be flexible. This is exactly how the **Erlang VM** was intended to be used in high-reliability systems.

**Would you like me to generate a specific technical guide on how the "Port Manager" in Elixir should supervise these external extensions?** This would be the first step in building your plugin ecosystem!