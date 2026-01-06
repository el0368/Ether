//! Allocator Module: BEAM-aware memory management
//! All allocations are visible in Erlang's :observer

const std = @import("std");
const api = @import("api.zig");

/// BeamAllocator: Wraps enif_alloc/enif_free for BEAM visibility
pub const BeamAllocator = struct {
    nif_api: *const api.WinNifApi,
    env: ?*api.ErlNifEnv,

    pub fn init(nif_api: *const api.WinNifApi, env: ?*api.ErlNifEnv) BeamAllocator {
        return .{ .nif_api = nif_api, .env = env };
    }

    pub fn allocator(self: *BeamAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            },
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, ptr_align: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        _ = ptr_align;
        _ = ret_addr;
        const self: *BeamAllocator = @ptrCast(@alignCast(ctx));
        const ptr = self.nif_api.alloc(len) orelse return null;
        return @as([*]u8, @ptrCast(ptr));
    }

    fn resize(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        _ = buf_align;
        _ = ret_addr;
        const self: *BeamAllocator = @ptrCast(@alignCast(ctx));
        // Phase 3-4: Use enif_realloc for in-place resize
        const new_ptr = self.nif_api.realloc(buf.ptr, new_len);
        // If realloc returns same pointer, resize succeeded in-place
        if (new_ptr) |ptr| {
            return @intFromPtr(ptr) == @intFromPtr(buf.ptr);
        }
        return false;
    }

    fn remap(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        _ = ctx;
        _ = buf;
        _ = buf_align;
        _ = new_len;
        _ = ret_addr;
        return null;
    }

    fn free(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, ret_addr: usize) void {
        _ = buf_align;
        _ = ret_addr;
        const self: *BeamAllocator = @ptrCast(@alignCast(ctx));
        self.nif_api.free(buf.ptr);
    }
};
