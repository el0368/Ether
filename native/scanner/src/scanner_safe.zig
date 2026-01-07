//! Scanner Safe: Main entry point for native scanner NIF
//! This file re-exports symbols from modular components
//!
//! Module Structure:
//!   api.zig       - WinNifApi struct and type exports
//!   allocator.zig - BeamAllocator implementation
//!   resource.zig  - ScannerResource lifecycle (ADR-017)
//!   crawler.zig   - File system scanning logic

const std = @import("std");
const api = @import("api.zig");
const resource = @import("resource.zig");
const crawler = @import("crawler.zig");
const searcher = @import("searcher.zig");

// Re-export types for entry.c compatibility
pub const ErlNifEnv = api.ErlNifEnv;
pub const ERL_NIF_TERM = api.ERL_NIF_TERM;

// Force linker to include exported symbols from modules
// This is required because Zig only exports symbols from the root source file
comptime {
    _ = &crawler.zig_scan_yieldable;
    _ = &resource.zig_create_context;
    _ = &resource.zig_close_context;
    _ = &resource.zig_resource_destructor;
    _ = &searcher.zig_search;
}
