const std = @import("std");
const t = @import("token.zig");
const tt = @import("tokentype.zig");
const e = @import("main.zig");

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

    fn scanToken(self: *Scanner) void {
        const c = self.advance();
        switch (c) {
            '(' => self.addTokenNoLiteral(tt.TokenType.left_paren),
            ')' => self.addTokenNoLiteral(tt.TokenType.right_paren),
            '{' => self.addTokenNoLiteral(tt.TokenType.left_brace),
            '}' => self.addTokenNoLiteral(tt.TokenType.right_brace),
            ',' => self.addTokenNoLiteral(tt.TokenType.comma),
            '.' => self.addTokenNoLiteral(tt.TokenType.dot),
            '-' => self.addTokenNoLiteral(tt.TokenType.minus),
            '+' => self.addTokenNoLiteral(tt.TokenType.plus),
            ';' => self.addTokenNoLiteral(tt.TokenType.semicolon),
            '*' => self.addTokenNoLiteral(tt.TokenType.star),
            '!' => self.addTokenNoLiteral(if (match('=')) tt.TokenType.bang_equal else tt.TokenType.bang),
            '=' => self.addTokenNoLiteral(if (match('=')) tt.TokenType.equal_equal else tt.TokenType.equal),
            '<' => self.addTokenNoLiteral(if (match('=')) tt.TokenType.less_equal else tt.TokenType.less),
            '>' => self.addTokenNoLiteral(if (match('=')) tt.TokenType.greater_equal else tt.TokenType.greater),
            '/' => self.addTokenNoLiteral(if (self.match('/')) {
                if (self.peek() == '/') {
                    while (self.peek() != '\n' and !self.isAtEnd()) {
                        self.advance();
                    }
                } else {
                    addToken(tt.TokenType.slash);
                }
            }),
            ' ' => {},
            '\r' => {},
            '\t' => {},
            '\n' => self.line += 1,
            else => e.generateError(self.line, "Unexpected character."),
        }
    }

    fn advance(self: *Scanner) u8 {
        const char_at = self.source[self.current];
        self.current += 1;
        return char_at;
    }

    fn addTokenNoLiteral(t_type: tt.TokenType) void {
        addToken(t_type, t.LiteralValue{ .nil = {} });
    }

    fn addToken(self: *Scanner, t_type: tt.TokenType, literal: t.LiteralValue) void {
        const text = self.source[self.start..self.current];
        self.tokens.append(t.Token{
            .type = t_type,
            .lexeme = text,
            .literal = literal,
            .line = self.line,
        });
    }

    fn match(self: *Scanner, expected: u8) bool {
        if (isAtEnd()) return false;
        if (self.source[self.current] != expected) return false;

        self.current += 1;
        return true;
    }

    fn peek(self: *Scanner) u8 {
        if (isAtEnd()) return 0;
        return self.source[self.current];
    }
};
