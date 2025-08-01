const std = @import("std");

// Token types based on FHIRPath specification
pub const TokenType = enum {
    // Literals
    number,         // 42, 3.14
    string,         // 'hello', "world"
    boolean,        // true, false
    date_time,      // @2023-12-25, @2023-12-25T10:30:00
    quantity,       // 5 'kg', 10.5 'cm'
    
    // Identifiers and keywords
    identifier,     // name, Patient
    delimited_identifier, // `escaped identifier`
    
    // Operators
    plus,           // +
    minus,          // -
    star,           // *
    slash,          // /
    percent,        // mod
    div,            // div
    
    // Comparison
    equal,          // =
    not_equal,      // !=
    less,           // <
    less_equal,     // <=
    greater,        // >
    greater_equal,  // >=
    equivalent,     // ~
    not_equivalent, // !~
    
    // Logical
    and_op,         // and
    or_op,          // or
    xor_op,         // xor
    implies,        // implies
    not_op,         // not
    
    // Membership
    in_op,          // in
    contains,       // contains
    
    // Punctuation
    dot,            // .
    lparen,         // (
    rparen,         // )
    lbracket,       // [
    rbracket,       // ]
    comma,          // ,
    pipe,           // |
    ampersand,      // &
    
    // Special
    dollar,         // $ (for variables)
    at,             // @ (for context)
    question,       // ? (conditional)
    colon,          // : (conditional)
    lbrace,         // {
    rbrace,         // }
    percent_sign,   // % (for external constants)
    semicolon,      // ; (for statement separation)
    
    // Special variables
    this_kw,        // $this
    index_kw,       // $index
    total_kw,       // $total
    
    // Keywords
    is_op,          // is
    as_op,          // as
    where_kw,       // where (treated as keyword)
    select_kw,      // select (treated as keyword)
    
    // End of input
    eof,
    
    // Error token
    invalid,
};

pub const Token = struct {
    type: TokenType,
    lexeme: []const u8,
    line: u32,
    column: u32,
    start: u32,
    end: u32,
    
    pub fn init(token_type: TokenType, lexeme: []const u8, line: u32, column: u32, start: u32, end: u32) Token {
        return Token{
            .type = token_type,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .start = start,
            .end = end,
        };
    }
};

// Position tracking for error reporting
pub const Position = struct {
    offset: u32,
    line: u32,
    column: u32,
    
    pub fn init() Position {
        return Position{
            .offset = 0,
            .line = 1,
            .column = 1,
        };
    }
    
    pub fn advance(self: *Position, ch: u8) void {
        self.offset += 1;
        if (ch == '\n') {
            self.line += 1;
            self.column = 1;
        } else {
            self.column += 1;
        }
    }
};

pub const Lexer = struct {
    source: []const u8,
    current: u32,
    position: Position,
    
    pub fn init(source: []const u8) Lexer {
        return Lexer{
            .source = source,
            .current = 0,
            .position = Position.init(),
        };
    }
    
    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();
        
        const start_pos = self.position;
        const start_offset = self.current;
        
        if (self.isAtEnd()) {
            return Token.init(.eof, "", start_pos.line, start_pos.column, start_offset, self.current);
        }
        
        const ch = self.advance();
        
        return switch (ch) {
            '+' => self.makeToken(.plus, start_pos, start_offset),
            '-' => self.makeToken(.minus, start_pos, start_offset),
            '*' => self.makeToken(.star, start_pos, start_offset),
            '/' => self.makeToken(.slash, start_pos, start_offset),
            // '%' => self.makeToken(.percent, start_pos, start_offset), // handled below
            '=' => self.makeToken(.equal, start_pos, start_offset),
            '<' => if (self.match('=')) 
                self.makeToken(.less_equal, start_pos, start_offset) 
                else self.makeToken(.less, start_pos, start_offset),
            '>' => if (self.match('=')) 
                self.makeToken(.greater_equal, start_pos, start_offset) 
                else self.makeToken(.greater, start_pos, start_offset),
            '!' => if (self.match('='))
                self.makeToken(.not_equal, start_pos, start_offset)
                else if (self.match('~'))
                self.makeToken(.not_equivalent, start_pos, start_offset)
                else self.makeToken(.invalid, start_pos, start_offset),
            '~' => self.makeToken(.equivalent, start_pos, start_offset),
            '.' => self.makeToken(.dot, start_pos, start_offset),
            '(' => self.makeToken(.lparen, start_pos, start_offset),
            ')' => self.makeToken(.rparen, start_pos, start_offset),
            '[' => self.makeToken(.lbracket, start_pos, start_offset),
            ']' => self.makeToken(.rbracket, start_pos, start_offset),
            ',' => self.makeToken(.comma, start_pos, start_offset),
            '|' => self.makeToken(.pipe, start_pos, start_offset),
            '&' => self.makeToken(.ampersand, start_pos, start_offset),
            '$' => self.scanDollarToken(start_pos, start_offset),
            '@' => self.scanDateTime(start_pos, start_offset),
            '?' => self.makeToken(.question, start_pos, start_offset),
            ':' => self.makeToken(.colon, start_pos, start_offset),
            '{' => self.makeToken(.lbrace, start_pos, start_offset),
            '}' => self.makeToken(.rbrace, start_pos, start_offset),
            '%' => self.makeToken(.percent_sign, start_pos, start_offset),
            ';' => self.makeToken(.semicolon, start_pos, start_offset),
            '`' => self.scanDelimitedIdentifier(start_pos, start_offset),
            '\'' => self.scanString('\'', start_pos, start_offset),
            '"' => self.scanString('"', start_pos, start_offset),
            else => {
                if (std.ascii.isDigit(ch)) {
                    return self.scanNumber(start_pos, start_offset);
                } else if (std.ascii.isAlphabetic(ch) or ch == '_') {
                    return self.scanIdentifier(start_pos, start_offset);
                } else {
                    return self.makeToken(.invalid, start_pos, start_offset);
                }
            },
        };
    }
    
    fn isAtEnd(self: *const Lexer) bool {
        return self.current >= self.source.len;
    }
    
    fn advance(self: *Lexer) u8 {
        if (self.isAtEnd()) return 0;
        
        const ch = self.source[self.current];
        self.position.advance(ch);
        self.current += 1;
        return ch;
    }
    
    fn peek(self: *const Lexer) u8 {
        if (self.isAtEnd()) return 0;
        return self.source[self.current];
    }
    
    fn peekNext(self: *const Lexer) u8 {
        if (self.current + 1 >= self.source.len) return 0;
        return self.source[self.current + 1];
    }
    
    fn match(self: *Lexer, expected: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.source[self.current] != expected) return false;
        
        _ = self.advance();
        return true;
    }
    
    fn skipWhitespace(self: *Lexer) void {
        while (!self.isAtEnd()) {
            const ch = self.peek();
            switch (ch) {
                ' ', '\r', '\t', '\n' => _ = self.advance(),
                else => break,
            }
        }
    }
    
    fn makeToken(self: *const Lexer, token_type: TokenType, start_pos: Position, start_offset: u32) Token {
        const lexeme = self.source[start_offset..self.current];
        return Token.init(token_type, lexeme, start_pos.line, start_pos.column, start_offset, self.current);
    }
    
    fn scanString(self: *Lexer, quote: u8, start_pos: Position, start_offset: u32) Token {
        while (!self.isAtEnd() and self.peek() != quote) {
            if (self.peek() == '\\') {
                _ = self.advance(); // Skip escape character
                if (!self.isAtEnd()) {
                    _ = self.advance(); // Skip escaped character
                }
            } else {
                _ = self.advance();
            }
        }
        
        if (self.isAtEnd()) {
            return Token.init(.invalid, self.source[start_offset..self.current], start_pos.line, start_pos.column, start_offset, self.current);
        }
        
        _ = self.advance(); // Closing quote
        return self.makeToken(.string, start_pos, start_offset);
    }
    
    fn scanNumber(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        while (!self.isAtEnd() and std.ascii.isDigit(self.peek())) {
            _ = self.advance();
        }
        
        // Look for decimal part
        if (!self.isAtEnd() and self.peek() == '.' and std.ascii.isDigit(self.peekNext())) {
            _ = self.advance(); // Consume '.'
            while (!self.isAtEnd() and std.ascii.isDigit(self.peek())) {
                _ = self.advance();
            }
        }
        
        // Check for quantity unit - skip whitespace and look for quoted string
        const after_number = self.current;
        self.skipWhitespace();
        
        if (!self.isAtEnd() and self.peek() == '\'') {
            // Found a unit, scan the quoted string
            _ = self.advance(); // consume opening quote
            while (!self.isAtEnd() and self.peek() != '\'') {
                if (self.peek() == '\\') {
                    _ = self.advance(); // skip escape
                    if (!self.isAtEnd()) {
                        _ = self.advance(); // skip escaped char
                    }
                } else {
                    _ = self.advance();
                }
            }
            
            if (!self.isAtEnd() and self.peek() == '\'') {
                _ = self.advance(); // consume closing quote
                return Token.init(.quantity, self.source[start_offset..self.current], start_pos.line, start_pos.column, start_offset, self.current);
            } else {
                // Invalid quantity literal - missing closing quote
                return self.makeToken(.invalid, start_pos, start_offset);
            }
        } else {
            // Reset position if no unit found
            self.current = after_number;
            // Restore position tracking
            self.position = start_pos;
            var i = start_offset;
            while (i < after_number) : (i += 1) {
                self.position.advance(self.source[i]);
            }
            return self.makeToken(.number, start_pos, start_offset);
        }
    }
    
    fn scanIdentifier(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        while (!self.isAtEnd() and (std.ascii.isAlphanumeric(self.peek()) or self.peek() == '_')) {
            _ = self.advance();
        }
        
        const lexeme = self.source[start_offset..self.current];
        const token_type = self.getKeywordType(lexeme);
        return Token.init(token_type, lexeme, start_pos.line, start_pos.column, start_offset, self.current);
    }
    
    fn scanDollarToken(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        // Look ahead to see if this is a special variable
        if (self.current + 4 <= self.source.len and std.mem.eql(u8, self.source[self.current..self.current + 4], "this")) {
            self.current += 4;
            self.position.offset += 4;
            self.position.column += 4;
            return self.makeToken(.this_kw, start_pos, start_offset);
        } else if (self.current + 5 <= self.source.len and std.mem.eql(u8, self.source[self.current..self.current + 5], "index")) {
            self.current += 5;
            self.position.offset += 5;
            self.position.column += 5;
            return self.makeToken(.index_kw, start_pos, start_offset);
        } else if (self.current + 5 <= self.source.len and std.mem.eql(u8, self.source[self.current..self.current + 5], "total")) {
            self.current += 5;
            self.position.offset += 5;
            self.position.column += 5;
            return self.makeToken(.total_kw, start_pos, start_offset);
        }
        
        // Just a regular dollar sign
        return self.makeToken(.dollar, start_pos, start_offset);
    }
    
    fn scanDelimitedIdentifier(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        // Scan until closing backtick, handling escape sequences
        while (!self.isAtEnd() and self.peek() != '`') {
            if (self.peek() == '\\') {
                _ = self.advance(); // consume backslash
                if (!self.isAtEnd()) {
                    _ = self.advance(); // consume escaped character
                }
            } else {
                _ = self.advance();
            }
        }
        
        if (self.isAtEnd()) {
            // Unterminated delimited identifier
            return self.makeToken(.invalid, start_pos, start_offset);
        }
        
        // Consume closing backtick
        _ = self.advance();
        
        return self.makeToken(.delimited_identifier, start_pos, start_offset);
    }
    
    fn scanDateTime(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        // DateTime format: @YYYY-MM-DD[THH:MM:SS[.fff][Z|±HH:MM]]
        // Date format: @YYYY[-MM[-DD]]
        // Time format: @THH:MM[:SS[.fff]]
        
        // First, check if it's just an @ token (not followed by a date)
        if (self.isAtEnd() or (!std.ascii.isDigit(self.peek()) and self.peek() != 'T')) {
            return self.makeToken(.at, start_pos, start_offset);
        }
        
        // Parse date or time
        if (self.peek() == 'T') {
            // Time only: @THH:MM:SS
            _ = self.advance(); // consume 'T'
            return self.scanTimeComponent(start_pos, start_offset);
        } else {
            // Date (possibly with time): @YYYY-MM-DD...
            return self.scanDateComponent(start_pos, start_offset);
        }
    }
    
    fn scanDateComponent(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        // Scan YYYY
        if (!self.scanDigits(4)) return self.makeToken(.invalid, start_pos, start_offset);
        
        // Optional -MM
        if (!self.isAtEnd() and self.peek() == '-') {
            _ = self.advance();
            if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
            
            // Optional -DD
            if (!self.isAtEnd() and self.peek() == '-') {
                _ = self.advance();
                if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
            }
        }
        
        // Optional time component
        if (!self.isAtEnd() and self.peek() == 'T') {
            _ = self.advance();
            return self.scanTimeComponent(start_pos, start_offset);
        }
        
        return self.makeToken(.date_time, start_pos, start_offset);
    }
    
    fn scanTimeComponent(self: *Lexer, start_pos: Position, start_offset: u32) Token {
        // HH:MM
        if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
        if (self.isAtEnd() or self.peek() != ':') return self.makeToken(.invalid, start_pos, start_offset);
        _ = self.advance(); // consume ':'
        if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
        
        // Optional :SS
        if (!self.isAtEnd() and self.peek() == ':') {
            _ = self.advance();
            if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
            
            // Optional .fff
            if (!self.isAtEnd() and self.peek() == '.') {
                _ = self.advance();
                if (!self.scanDigits(3)) return self.makeToken(.invalid, start_pos, start_offset);
            }
        }
        
        // Optional timezone: Z or ±HH:MM
        if (!self.isAtEnd()) {
            if (self.peek() == 'Z') {
                _ = self.advance();
            } else if (self.peek() == '+' or self.peek() == '-') {
                _ = self.advance();
                if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
                if (!self.isAtEnd() and self.peek() == ':') {
                    _ = self.advance();
                    if (!self.scanDigits(2)) return self.makeToken(.invalid, start_pos, start_offset);
                }
            }
        }
        
        return self.makeToken(.date_time, start_pos, start_offset);
    }
    
    fn scanDigits(self: *Lexer, count: u8) bool {
        var i: u8 = 0;
        while (i < count) : (i += 1) {
            if (self.isAtEnd() or !std.ascii.isDigit(self.peek())) {
                return false;
            }
            _ = self.advance();
        }
        return true;
    }
    
    fn getKeywordType(self: *const Lexer, lexeme: []const u8) TokenType {
        _ = self; // unused
        
        // Keywords and operators that look like identifiers
        if (std.mem.eql(u8, lexeme, "true") or std.mem.eql(u8, lexeme, "false")) {
            return .boolean;
        } else if (std.mem.eql(u8, lexeme, "and")) {
            return .and_op;
        } else if (std.mem.eql(u8, lexeme, "or")) {
            return .or_op;
        } else if (std.mem.eql(u8, lexeme, "xor")) {
            return .xor_op;
        } else if (std.mem.eql(u8, lexeme, "implies")) {
            return .implies;
        } else if (std.mem.eql(u8, lexeme, "not")) {
            return .not_op;
        } else if (std.mem.eql(u8, lexeme, "in")) {
            return .in_op;
        } else if (std.mem.eql(u8, lexeme, "contains")) {
            return .contains;
        } else if (std.mem.eql(u8, lexeme, "is")) {
            return .is_op;
        } else if (std.mem.eql(u8, lexeme, "as")) {
            return .as_op;
        } else if (std.mem.eql(u8, lexeme, "where")) {
            return .where_kw;
        } else if (std.mem.eql(u8, lexeme, "select")) {
            return .select_kw;
        } else if (std.mem.eql(u8, lexeme, "div")) {
            return .div;
        } else if (std.mem.eql(u8, lexeme, "mod")) {
            return .percent;
        } else {
            return .identifier;
        }
    }
};

// Tests
test "lexer basic tokens" {
    const source = "+ - * / = < > ( ) [ ] . ,";
    var lexer = Lexer.init(source);
    
    const expected_types = [_]TokenType{
        .plus, .minus, .star, .slash, .equal, .less, .greater,
        .lparen, .rparen, .lbracket, .rbracket, .dot, .comma, .eof
    };
    
    for (expected_types) |expected| {
        const token = lexer.nextToken();
        try std.testing.expectEqual(expected, token.type);
    }
}

test "lexer numbers" {
    const source = "42 3.14 0 123.456";
    var lexer = Lexer.init(source);
    
    var token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.number, token.type);
    try std.testing.expectEqualStrings("42", token.lexeme);
    
    token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.number, token.type);
    try std.testing.expectEqualStrings("3.14", token.lexeme);
    
    token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.number, token.type);
    try std.testing.expectEqualStrings("0", token.lexeme);
    
    token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.number, token.type);
    try std.testing.expectEqualStrings("123.456", token.lexeme);
}

test "lexer strings" {
    const source = "'hello' \"world\" 'don\\'t'";
    var lexer = Lexer.init(source);
    
    var token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.string, token.type);
    try std.testing.expectEqualStrings("'hello'", token.lexeme);
    
    token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.string, token.type);
    try std.testing.expectEqualStrings("\"world\"", token.lexeme);
    
    token = lexer.nextToken();
    try std.testing.expectEqual(TokenType.string, token.type);
    try std.testing.expectEqualStrings("'don\\'t'", token.lexeme);
}

test "lexer keywords" {
    const source = "true false and or not where select";
    var lexer = Lexer.init(source);
    
    const expected_types = [_]TokenType{
        .boolean, .boolean, .and_op, .or_op, .not_op, .where_kw, .select_kw, .eof
    };
    
    for (expected_types) |expected| {
        const token = lexer.nextToken();
        try std.testing.expectEqual(expected, token.type);
    }
}

test "lexer identifiers" {
    const source = "Patient name given_name _private";
    var lexer = Lexer.init(source);
    
    for (0..4) |_| {
        const token = lexer.nextToken();
        try std.testing.expectEqual(TokenType.identifier, token.type);
    }
}