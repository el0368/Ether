const std = @import("std");

pub const BufferType = enum {
    original,
    add,
};

pub const Piece = struct {
    buffer_type: BufferType,
    start: usize,
    length: usize,
};

pub const PieceTable = struct {
    allocator: std.mem.Allocator,
    original_buffer: []const u8,
    add_buffer: std.ArrayListUnmanaged(u8),
    pieces: std.ArrayListUnmanaged(Piece),

    pub fn init(allocator: std.mem.Allocator, original: []const u8) !PieceTable {
        var pt = PieceTable{
            .allocator = allocator,
            .original_buffer = original,
            .add_buffer = .{},
            .pieces = .{},
        };

        // Initial piece covers the whole original buffer
        if (original.len > 0) {
            try pt.pieces.append(allocator, Piece{
                .buffer_type = .original,
                .start = 0,
                .length = original.len,
            });
        }

        return pt;
    }

    pub fn deinit(self: *PieceTable) void {
        self.add_buffer.deinit(self.allocator);
        self.pieces.deinit(self.allocator);
    }

    /// Find which piece contains the given logical offset
    fn findPieceAtOffset(self: *const PieceTable, offset: usize) !struct { index: usize, relative_offset: usize } {
        var current_offset: usize = 0;
        for (self.pieces.items, 0..) |piece, i| {
            if (offset >= current_offset and offset < current_offset + piece.length) {
                return .{ .index = i, .relative_offset = offset - current_offset };
            }
            current_offset += piece.length;
        }

        // If at the very end
        if (offset == current_offset) {
            return .{ .index = self.pieces.items.len, .relative_offset = 0 };
        }

        return error.OutOfBounds;
    }

    pub fn insert(self: *PieceTable, offset: usize, text: []const u8) !void {
        if (text.len == 0) return;

        const add_start = self.add_buffer.items.len;
        try self.add_buffer.appendSlice(self.allocator, text);

        const new_piece = Piece{
            .buffer_type = .add,
            .start = add_start,
            .length = text.len,
        };

        if (self.pieces.items.len == 0) {
            if (offset != 0) return error.OutOfBounds;
            try self.pieces.append(self.allocator, new_piece);
            return;
        }

        const target = try self.findPieceAtOffset(offset);

        if (target.index == self.pieces.items.len) {
            // Check if we can append to the last piece
            var last_piece = &self.pieces.items[self.pieces.items.len - 1];
            if (last_piece.buffer_type == .add and (last_piece.start + last_piece.length == add_start)) {
                last_piece.length += text.len;
            } else {
                try self.pieces.append(self.allocator, new_piece);
            }
            return;
        }

        const original_piece = self.pieces.items[target.index];

        if (target.relative_offset == 0) {
            try self.piecesInsertAt(target.index, new_piece);
        } else {
            // Split piece
            const left = Piece{
                .buffer_type = original_piece.buffer_type,
                .start = original_piece.start,
                .length = target.relative_offset,
            };
            const right = Piece{
                .buffer_type = original_piece.buffer_type,
                .start = original_piece.start + target.relative_offset,
                .length = original_piece.length - target.relative_offset,
            };

            self.pieces.items[target.index] = left;
            try self.piecesInsertAt(target.index + 1, new_piece);
            try self.piecesInsertAt(target.index + 2, right);
        }
    }

    fn piecesInsertAt(self: *PieceTable, index: usize, piece: Piece) !void {
        try self.pieces.ensureUnusedCapacity(self.allocator, 1);
        const old_len = self.pieces.items.len;
        self.pieces.items.len += 1;
        if (index < old_len) {
            std.mem.copyBackwards(Piece, self.pieces.items[index + 1 ..], self.pieces.items[index..old_len]);
        }
        self.pieces.items[index] = piece;
    }

    pub fn delete(self: *PieceTable, offset: usize, length: usize) !void {
        if (length == 0) return;

        const start_target = try self.findPieceAtOffset(offset);
        const end_target = try self.findPieceAtOffset(offset + length);

        if (start_target.index == end_target.index) {
            // Deletion within a single piece
            const piece = self.pieces.items[start_target.index];
            const left_len = start_target.relative_offset;
            const middle_len = length;
            const right_len = piece.length - left_len - middle_len;

            if (left_len == 0 and right_len == 0) {
                _ = self.pieces.orderedRemove(start_target.index);
            } else if (left_len == 0) {
                self.pieces.items[start_target.index].start += middle_len;
                self.pieces.items[start_target.index].length -= middle_len;
            } else if (right_len == 0) {
                self.pieces.items[start_target.index].length = left_len;
            } else {
                // Split into two
                self.pieces.items[start_target.index].length = left_len;
                const right = Piece{
                    .buffer_type = piece.buffer_type,
                    .start = piece.start + left_len + middle_len,
                    .length = right_len,
                };
                try self.piecesInsertAt(start_target.index + 1, right);
            }
        } else {
            // Spans multiple pieces
            // 1. Handle last piece (do this first because removing items before it shifts indices)
            if (end_target.index < self.pieces.items.len) {
                const last_piece = &self.pieces.items[end_target.index];
                const consumed_in_last = end_target.relative_offset;
                last_piece.start += consumed_in_last;
                last_piece.length -= consumed_in_last;
                if (last_piece.length == 0) {
                    _ = self.pieces.orderedRemove(end_target.index);
                }
            }

            // 2. Remove middle pieces
            // Remove pieces between start_target.index and end_target.index (exclusive of both)
            var i: usize = end_target.index - 1;
            while (i > start_target.index) : (i -= 1) {
                _ = self.pieces.orderedRemove(i);
            }

            // 3. Handle first piece
            const first_piece = &self.pieces.items[start_target.index];
            first_piece.length = start_target.relative_offset;
            if (first_piece.length == 0) {
                _ = self.pieces.orderedRemove(start_target.index);
            }
        }
    }

    pub fn totalLength(self: *const PieceTable) usize {
        var len: usize = 0;
        for (self.pieces.items) |piece| {
            len += piece.length;
        }
        return len;
    }

    pub fn exportToBuffer(self: *const PieceTable, buffer: []u8) void {
        var cursor: usize = 0;
        for (self.pieces.items) |piece| {
            const src = switch (piece.buffer_type) {
                .original => self.original_buffer[piece.start .. piece.start + piece.length],
                .add => self.add_buffer.items[piece.start .. piece.start + piece.length],
            };
            @memcpy(buffer[cursor .. cursor + piece.length], src);
            cursor += piece.length;
        }
    }
};

test "piece table basic" {
    const allocator = std.testing.allocator;
    var pt = try PieceTable.init(allocator, "Hello World");
    defer pt.deinit();

    try pt.insert(6, "Beautiful ");

    const buf = try allocator.alloc(u8, pt.totalLength());
    defer allocator.free(buf);
    pt.exportToBuffer(buf);

    try std.testing.expectEqualStrings("Hello Beautiful World", buf);
}

test "piece table delete" {
    const allocator = std.testing.allocator;
    var pt = try PieceTable.init(allocator, "Hello Beautiful World");
    defer pt.deinit();

    try pt.delete(6, 10); // Remove "Beautiful "

    const buf = try allocator.alloc(u8, pt.totalLength());
    defer allocator.free(buf);
    pt.exportToBuffer(buf);

    try std.testing.expectEqualStrings("Hello World", buf);
}

test "piece table complex" {
    const allocator = std.testing.allocator;
    var pt = try PieceTable.init(allocator, "ABCDEF");
    defer pt.deinit();

    try pt.insert(3, "123"); // ABC 123 DEF
    try pt.insert(0, "!"); // ! ABC 123 DEF
    try pt.delete(3, 5); // ! AB (C123D) EF -> !ABEF

    const buf = try allocator.alloc(u8, pt.totalLength());
    defer allocator.free(buf);
    pt.exportToBuffer(buf);

    try std.testing.expectEqualStrings("!ABEF", buf);
}
