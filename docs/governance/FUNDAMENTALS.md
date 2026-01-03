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

---

> "We respect The Past, monitor The Present, and build for The Future."
