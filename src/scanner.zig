const std = @import("std");
const t = @import("token.zig");

const Scanner = struct {
    source: []const u8,
    tokens: std.ArrayList(t.Token),
    start: i32,
    current: i32,
    line: i32,

    pub fn init(allocator: std.mem.Allocator, source: []u8) Scanner {
        return Scanner{
            .source = source,
            .tokens = std.ArrayList(t.Token).init(allocator),
        };
    }

    pub fn deinit(self: *Scanner) void {
        self.tokens.deinit();
    }

    pub fn scanTokens(self: *Scanner) !std.ArrayList(t.Token) {
        while (!self.isAtEnd()) {
            self.start = self.current;
            // !TODO finish scan tokens
            scanToken();
        }

        self.tokens.append(t.Token{
            .type = .eof,
            .lexeme = "",
            .literal = .nil,
            .line = self.line,
        });

        return self.tokens;
    }

    fn isAtEnd(self: *Scanner) bool {
        return self.current >= self.source.len;
    }
};
