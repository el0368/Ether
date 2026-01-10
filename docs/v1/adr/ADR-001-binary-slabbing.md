# ADR 0001: Binary Slabbing (Zero-JSON Protocol)

## Status
Accepted

## Context
The Aether IDE needs to display file trees containing 100,000+ items.
Creating Elixir Terms (Lists/Maps) or JSON strings for this amount of data creates massive Garbage Collection pressure and CPU overhead ("Marshalling Tax").

## Decision
We utilize a **Zero-Copy Binary Protocol** ("Slabbing") for the Scanner -> Frontend pipeline.

### Protocol Specification
`[Type:u8][Len:u16][Path:Bytes]...`

1.  **Zig (NIF)**: Allocates a single contiguous byte array (`std.ArrayList`). It packs file entries back-to-back.
2.  **Elixir (Backend)**: Receives this binary blob. It does **NOT** decode it into a List of Maps. It simply wraps it in Base64 and shoots it to the WebSocket.
3.  **Svelte (Frontend)**: Receives the blob, decodes it `just-in-time` or renders eagerly.

## Consequences
### Positive
-   **Speed**: Scanning is 10x-100x faster for large trees because we skip the JSON Serialization step.
-   **Memory**: Elixir GC is not stressed because the data is a single large binary (ref-counted) rather than millions of small objects.

### Negative
-   **Debuggability**: The data is opaque binary, not human-readable JSON. Requires `NifDecoder.ts` to inspect.

## Compliance
-   Verified by `bench/scanner_bench.exs`.
-   Implemented in `Aether.Native.Scanner`.
