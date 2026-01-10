const std = @import("std");

pub const StackEntry = struct {
    path: []const u8,
    depth: u8,
};

pub const ActiveIterator = struct {
    handle: ?*anyopaque,
    path: []const u8,
    depth: u8,
};

pub const ScannerResource = struct {
    created_at: i64,
    is_active: bool,
    total_count: u64,
    stack: std.ArrayListUnmanaged(StackEntry),
    active_iter: ?ActiveIterator = null,
    ignore_patterns: std.ArrayListUnmanaged([]const u8),

    pub fn deinit(self: *ScannerResource, allocator: std.mem.Allocator) void {
        for (self.stack.items) |entry| {
            allocator.free(entry.path);
        }
        self.stack.deinit(allocator);

        if (self.active_iter) |iter| {
            allocator.free(iter.path);
            // Handle closing is done by zig_close_context or dtor
        }

        for (self.ignore_patterns.items) |pattern| {
            allocator.free(pattern);
        }
        self.ignore_patterns.deinit(allocator);
    }
};
