# ADR-020: Hybrid Serialization (The "Fluid Logic" Bridge)

## Status
Proposed

## Context
High-performance IDEs face a trade-off between **Data Density** and **Data Flexibility**.
1.  **Raw Binary (Level 6)**: Used for File Explorer. Maximum speed, zero overhead, but extremely rigid (schema is hardcoded in Zig and JS).
2.  **JSON (Current)**: Used for everything else. Very flexible, but slow parsing in JS and high memory overhead for large agent responses or complex configurations.

The user requested a way to "send with binary but open with JSON."

## Decision
Implement a **Hybrid Serialization Strategy** using **MessagePack** (Binary JSON) as the middle-tier for structured data.

### 1. The Tri-Layer Protocol
*   **Layer 1: Raw Slabs (Zig-Native)**
    *   *Usage*: 100k+ file trees, search results.
    *   *Format*: Custom tightly-packed bytes.
    *   *Speed*: Absolute Maximum.
*   **Layer 2: MessagePack (Structured Binary)**
    *   *Usage*: Agent reasoning, recursive refactor plans, large configurations.
    *   *Format*: MessagePack (Zero-schema binary).
    *   *Flexibility*: High (acts like JSON).
*   **Layer 3: JSON (Control Logic)**
    *   *Usage*: Phoenix heartbeats, simple state toggles, low-frequency events.

### 2. The Implementation Stack
*   **Zig**: Integrate a lightweight MessagePack encoder (e.g., `zig-msgpack`).
*   **Elixir**: Use `msgpax` for encoding/decoding in GenServers.
*   **Frontend**: Use `@msgpack/msgpack` for instant decoding into JS objects.

## Rationale
MessagePack allows us to send complex maps and lists with:
1.  **Less Payload**: No quotes, no escaping, no whitespace.
2.  **Faster Parsing**: JS can decode MessagePack into objects faster than it can parse strings via `JSON.parse`.
3.  **No Schema Barrier**: Unlike Protobuf, we don't need to recompile Zig every time we add a field to a record. It "opens like JSON."

## Consequences
*   **Positive**: Significant reduction in "Event Loop Starvation" in the browser for heavy agent responses.
*   **Positive**: Native Zig agents can easily construct complex responses without string interpolation.
*   **Requirement**: All GenServers must be updated to support the `{:msgpack, binary}` message type.
