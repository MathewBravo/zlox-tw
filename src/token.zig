const std = @import("std");
const tt = @import("tokentype.zig");

pub const LiteralValue = union {
    int: i64,
    float: f64,
    str: []const u8,
    boolean: bool,
    nil: void,

    pub fn format(self: LiteralValue, comptime _: []const u8, writer: anytype) !void {
        switch (self) {
            .int => |i| try writer.print("{}", .{i}),
            .float => |f| try writer.print("{}", .{f}),
            .str => |s| try writer.print("\"{s}\"", .{s}),
            .boolean => |b| try writer.print("{}", .{b}),
            .nil => try writer.writeAll("nil"),
        }
    }
};

pub const Token = struct {
    type: tt.TokenType,
    lexeme: []const u8,
    literal: LiteralValue,
    line: i32,

    fn init(token_type: tt.TokenType, lexeme: []u8, literal: LiteralValue, line: i32) Token {
        return Token{
            .type = token_type,
            .lexeme = lexeme,
            .literal = literal,
            .line = line,
        };
    }

    fn toString(self: Token, allocator: std.mem.Allocator) ![]u8 {
        var literal_buffer: [64]u8 = undefined;
        const literal_str = try std.fmt.bufPrint(&literal_buffer, "{}", .{self.literal});

        return try std.fmt.allocPrint(allocator, "{} {s} {s}", .{ self.type, self.lexeme, literal_str });
    }
};
