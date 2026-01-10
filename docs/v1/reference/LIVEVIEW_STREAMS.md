# LiveView Streams Architecture

This document explains why Ether uses Phoenix LiveView Streams for rendering large data sets like the File Explorer, even though it's an offline desktop IDE.

## The "Stream" Naming Confusion

> [!NOTE]
> **LiveView Streams have nothing to do with network streaming or online connectivity.**
> The word "stream" refers to a client-side DOM management technique, not data transfer.

## The Problem: Large List Rendering

The Ether IDE's File Explorer can display **10,000+ files** from a single project. Without optimization, every UI update would require:

1.  **Serializing** the entire file list to JSON on the server.
2.  **Transmitting** that payload over the local WebSocket.
3.  **Diffing** the entire list in the browser.
4.  **Re-rendering** the full DOM tree.

This is slow, even on `localhost`, because the bottleneck is browser DOM manipulation, not network latency.

## The Solution: Streams

LiveView's `stream/3` function provides **incremental DOM updates**. Instead of sending the whole list, it sends only the *changes* (adds, removes, updates).

### Comparison Table

| Approach | Server Behavior | Client Behavior | Performance |
|----------|-----------------|-----------------|-------------|
| **Regular Assign** | Sends entire list on every render | Re-diffs entire list | O(n) per update |
| **Stream** | Sends only deltas | Patches specific DOM nodes | O(1) per update |

### Code Example

```elixir
# Bad: Sends all 10,000 items on every re-render
socket |> assign(:files, all_files)

# Good: Sends only newly scanned items
socket |> stream(:files, new_items)
```

## Why This Matters for Ether

Even though Ether is an "offline" IDE, the frontend (Tauri WebView) and backend (Phoenix) still communicate via a local WebSocket (`ws://localhost:4000`).

### Without Streams
- Opening a folder with 5,000 files → 5,000 items serialized and sent.
- Switching from "Explorer" to "Search" sidebar → Sidebar unmounts, data lost.
- Switching back to "Explorer" → 5,000 items re-sent.

### With Streams
- Opening a folder with 5,000 files → 5,000 items sent *once*.
- Switching sidebars → No data transfer (DOM stays in memory).
- Switching back → Instant (data already present).

## Architectural Rules

To maintain stream efficiency, follow these rules:

1.  **Stable DOM IDs**: The `phx-update="stream"` container must have a stable `id` attribute.
2.  **Direct Rendering**: Never pass streams through intermediate function components. Render them directly.
3.  **Persistent Components**: Use CSS (`hidden` class) to toggle views, not conditional rendering (`if @visible`).

### Anti-Pattern (Causes Re-Push)

```elixir
# In WorkbenchLive
<%= if @sidebar_visible do %>
  <.sidebar files={@streams.files} />  # Stream passed as prop!
<% end %>
```

### Correct Pattern (Stable Identity)

```elixir
# In SidebarComponent (LiveComponent)
<div id="file-tree" phx-update="stream">
  <div :for={{id, file} <- @files} id={id}>
    ...
  </div>
</div>
```

## Alternatives Considered

| Alternative | Why We Rejected It |
|-------------|--------------------|
| **Virtual Scrolling (JS)** | Requires complex JS hook, breaks LiveView reactivity. |
| **Pagination** | Poor UX for file trees; users expect to see all files. |
| **No Optimization** | Unacceptable performance with large projects. |

## Summary

LiveView Streams are a **memory and DOM optimization**, not a networking feature. They ensure the Ether IDE remains snappy even when displaying massive directory trees, making the "local-first" experience feel native.

---
*Last Updated: 2026-01-09*
