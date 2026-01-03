# Aether: Engineering Fundamentals

This document outlines the **Mental Models** used by world-class software engineers to build complex systems like Aether.

## 1. 🧠 The Actor Model Thinking (Manager vs. Athlete)
In our Elixir + Zig system, view the roles as:
-   **Elixir (The Manager)**: Does not need to scan files itself. Its job is resilience—knowing how to restart the scanner if it crashes and how to manage the UI (Svelte).
-   **Zig (The Athlete)**: Runs as fast as possible. Single responsibility: "Receive Job -> Work -> Return Clean Result (Binary Slab)".
-   **Fundamental**: **Separation of Concerns** is what makes the application immortal.

## 2. 📉 Data Marshalling & The "Zero-JSON" Philosophy
-   **Problem**: Converting data across languages (JS <-> Elixir <-> Zig) via JSON incurs massive CPU cost ("Marshalling Tax").
-   **Solution**: Send data in "Raw Binary" format whenever possible. "Glass Pipe" architecture.
-   **Fundamental**: Performance isn't just about language speed; it's about **I/O Efficiency** (frictionless data travel).

## 3. 🛡️ Design by Contract (Design for Failure)
-   **Concept**: Don't just write Defensive Programming; write **Fail-Fast** code.
-   **Action**: If Zig crashes, Elixir detects it immediately (Sentinel) and recovers.
-   **Fundamental**: Stability comes from a **Resilient System** that can recover, not code that never bugs.

## 4. 📊 Observability: If you don't measure it, it doesn't exist
-   **Concept**: Benchmarks are not for vanity; they are for "Truth-Telling".
-   **Fundamental**: In engineering, we trust **Data** (history.json), not **Feelings**.

## 5. 📂 The Aether Knowledge Base (6-Pillar Architecture)
We organize our "Source of Truth" using a **Time-Based Model**:

### ⏳ THE PAST (History)
-   **Path**: `/docs/logs/`
-   **Purpose**: Record of what happened. ship logs, bug fixes, decisions made.
-   **Use when**: Debugging regressions or understanding context.

### ⚡ THE PRESENT (Status)
-   **Path**: `/bench/` (Vitals), `/docs/governance/` (Law), `/docs/adr/` (Reason)
-   **Purpose**: The current health, rules, and architectural logic of the system.
-   **Use when**: Checking performance, onboarding, or verifying design compliance.

### 🔭 THE FUTURE (Strategy)
-   **Path**: `/task.md`
-   **Purpose**: The Roadmap. High-level goals and feature backlog.
-   **Use when**: Deciding "What do we build next?".

### 🗺️ THE PLAN (Tactics)
-   **Path**: `/implementation_plan.md`
-   **Purpose**: Immediate execution details for the current task.
-   **Use when**: Reviewing code changes before they happen.

### 🧪 THE PROOF (Evidence)
-   **Path**: `/test/`
-   **Purpose**: Automated verification that the system actually works.
-   **Use when**: Validating code correctness (Integrity Checks).

## 6. 🤝 BEAM Citizenship (NIF Best Practices)
When writing Zig NIFs, we are doing "brain surgery" on the Erlang VM. Three laws govern our conduct:

### Law 1: Time-Slicing (Politeness)
> "Share CPU time with others."
-   Use `enif_consume_timeslice` to yield during long loops.
-   Goal: Keep the app responsive even during heavy background work.

### Law 2: Resource Reaping (Responsibility)
> "Clean up after yourself."
-   Use `defer` for file handles.
-   Register NIF Resource Destructors for external resources.

### Law 3: Binary Awareness (Memory Ownership)
> "Understand who owns the data."
-   Large Binary Slabs may be held in RAM by small references.
-   Use `enif_realloc_binary` to compact when extracting small data.

---

> "We respect The Past, monitor The Present, and build for The Future."
