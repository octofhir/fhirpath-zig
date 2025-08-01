const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const types = @import("types.zig");

// Operator precedence levels for Pratt parsing
pub const Precedence = enum(u8) {
    none = 0,
    or_prec = 10,        // or
    xor_prec = 15,       // xor
    and_prec = 20,       // and
    implies_prec = 25,   // implies
    equality = 30,       // =, !=, ~, !~
    union_prec = 35,     // |
    comparison = 40,     // <, >, <=, >=
    membership = 50,     // in, contains
    additive = 60,       // +, -, &
    multiplicative = 70, // *, /, div, mod
    unary = 80,          // not, -, +
    postfix = 90,        // ., [], ()
    primary = 100,
};

// Operator binding power (left, right associativity)
pub const BindingPower = struct {
    left: u8,
    right: u8,
    
    pub fn init(prec: Precedence, right_associative: bool) BindingPower {
        const precedence: u8 = @intFromEnum(prec);
        if (right_associative) {
            return BindingPower{ .left = precedence, .right = precedence - 1 };
        } else {
            return BindingPower{ .left = precedence, .right = precedence + 1 };
        }
    }
};

// Pratt parser implementation
pub const Parser = struct {
    allocator: std.mem.Allocator,
    lexer_instance: *lexer.Lexer,
    current_token: lexer.Token,
    errors: std.ArrayList(ParseError),
    panic_mode: bool,
    
    pub const ParseError = struct {
        message: []const u8,
        location: ast.SourceLocation,
        expected: ?[]const u8,
        actual: []const u8,
    };
    
    pub fn init(allocator: std.mem.Allocator, lex: *lexer.Lexer) Parser {
        var parser = Parser{
            .allocator = allocator,
            .lexer_instance = lex,
            .current_token = undefined,
            .errors = std.ArrayList(ParseError).init(allocator),
            .panic_mode = false,
        };
        parser.advance(); // Load first token
        return parser;
    }
    
    pub fn deinit(self: *Parser) void {
        for (self.errors.items) |err| {
            self.allocator.free(err.message);
            if (err.expected) |exp| self.allocator.free(exp);
            self.allocator.free(err.actual);
        }
        self.errors.deinit();
    }
    
    pub fn hasErrors(self: *const Parser) bool {
        return self.errors.items.len > 0;
    }
    
    pub fn getErrors(self: *const Parser) []const ParseError {
        return self.errors.items;
    }
    
    pub fn parseExpression(self: *Parser) anyerror!*ast.Node {
        const expr = self.parseExpressionWithPrecedence(0) catch |err| {
            if (self.panic_mode) {
                self.synchronize();
            }
            return err;
        };
        
        // If we have errors but managed to parse something, return it
        if (self.hasErrors()) {
            return expr;
        }
        
        return expr;
    }
    
    /// Parse with error recovery - returns partial AST even with errors
    pub fn parseWithRecovery(self: *Parser) !struct { 
        ast: ?*ast.Node,
        errors: []const ParseError 
    } {
        const expr = self.parseExpressionWithPrecedence(0) catch {
            self.synchronize();
            // Try to continue parsing after synchronization
            if (self.current_token.type != .eof) {
                // Make another attempt after recovery
                const recovered = self.parseExpressionWithPrecedence(0) catch {
                    return .{ .ast = null, .errors = self.getErrors() };
                };
                return .{ .ast = recovered, .errors = self.getErrors() };
            }
            return .{ .ast = null, .errors = self.getErrors() };
        };
        
        return .{ .ast = expr, .errors = self.getErrors() };
    }
    
    fn recordError(self: *Parser, message: []const u8, expected: ?[]const u8) !void {
        if (self.panic_mode) return; // Don't record cascading errors
        
        const err = ParseError{
            .message = try self.allocator.dupe(u8, message),
            .location = ast.SourceLocation.init(
                self.current_token.start,
                self.current_token.end,
                self.current_token.line,
                self.current_token.column
            ),
            .expected = if (expected) |exp| try self.allocator.dupe(u8, exp) else null,
            .actual = try self.allocator.dupe(u8, self.current_token.lexeme),
        };
        
        try self.errors.append(err);
        self.panic_mode = true;
    }
    
    fn synchronize(self: *Parser) void {
        self.panic_mode = false;
        
        // Skip tokens until we find a synchronization point
        while (self.current_token.type != .eof) {
            // Synchronize on statement boundaries or structural tokens
            switch (self.current_token.type) {
                .semicolon, .rparen, .rbracket => {
                    self.advance();
                    return;
                },
                // Synchronize on keywords that typically start new expressions
                .boolean, .string, .number, .identifier => {
                    return;
                },
                else => {},
            }
            self.advance();
        }
    }
    
    fn parseExpressionWithPrecedence(self: *Parser, min_bp: u8) anyerror!*ast.Node {
        var left = try self.parsePrimary();
        
        while (true) {
            const bp = self.getBindingPower(self.current_token.type) orelse break;
            if (bp.left < min_bp) break;
            
            const operator = self.current_token.type;
            
            // Handle postfix operators (like path navigation and function calls)
            if (operator == .dot) {
                self.advance(); // consume '.'
                if (self.current_token.type != .identifier) {
                    try self.recordError("Expected identifier after '.'", "identifier");
                    return error.ExpectedIdentifier;
                }
                const property_name = self.current_token.lexeme;
                self.advance(); // consume identifier
                
                left = try self.createMemberAccess(left, property_name);
            } else if (operator == .lparen) {
                // Function call - the left side should be an identifier
                left = try self.parseFunctionCall(left);
            } else if (operator == .lbracket) {
                // Indexer expression
                left = try self.parseIndexer(left);
            } else {
                self.advance();
                const right = try self.parseExpressionWithPrecedence(bp.right);
                left = try self.createBinaryOp(operator, left, right);
            }
        }
        
        return left;
    }
    
    fn parsePrimary(self: *Parser) anyerror!*ast.Node {
        const token = self.current_token;
        
        switch (token.type) {
            .boolean => {
                self.advance();
                const value = std.mem.eql(u8, token.lexeme, "true");
                const literal = try self.allocator.create(ast.LiteralNode);
                literal.* = ast.LiteralNode.init(
                    .{ .boolean = value },
                    ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                );
                return &literal.base;
            },
            .number => {
                self.advance();
                // Try to parse as integer first, then decimal
                if (std.mem.indexOf(u8, token.lexeme, ".") != null) {
                    const value = std.fmt.parseFloat(f64, token.lexeme) catch return error.InvalidNumber;
                    const literal = try self.allocator.create(ast.LiteralNode);
                    literal.* = ast.LiteralNode.init(
                        .{ .decimal = value },
                        ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                    );
                    return &literal.base;
                } else {
                    const value = std.fmt.parseInt(i64, token.lexeme, 10) catch return error.InvalidNumber;
                    const literal = try self.allocator.create(ast.LiteralNode);
                    literal.* = ast.LiteralNode.init(
                        .{ .integer = value },
                        ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                    );
                    return &literal.base;
                }
            },
            .string => {
                self.advance();
                // Remove quotes from the string
                const unquoted = token.lexeme[1..token.lexeme.len-1];
                const literal = try self.allocator.create(ast.LiteralNode);
                literal.* = ast.LiteralNode.init(
                    .{ .string = unquoted },
                    ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                );
                return &literal.base;
            },
            .date_time => {
                self.advance();
                // Parse the date/time string (skip the @ prefix)
                const date_str = token.lexeme[1..];
                const parsed_value = try self.parseDateTimeString(date_str);
                const literal = try self.allocator.create(ast.LiteralNode);
                literal.* = ast.LiteralNode.init(
                    parsed_value,
                    ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                );
                return &literal.base;
            },
            .quantity => {
                self.advance();
                const parsed_value = try self.parseQuantityString(token.lexeme);
                const literal = try self.allocator.create(ast.LiteralNode);
                literal.* = ast.LiteralNode.init(
                    parsed_value,
                    ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                );
                return &literal.base;
            },
            .identifier => {
                self.advance();
                const identifier = try self.allocator.create(ast.IdentifierNode);
                identifier.* = ast.IdentifierNode.init(
                    token.lexeme,
                    ast.SourceLocation.init(token.start, token.end, token.line, token.column)
                );
                return &identifier.base;
            },
            .lparen => {
                self.advance(); // consume '('
                const expr = try self.parseExpression();
                if (self.current_token.type != .rparen) {
                    try self.recordError("Expected ')' to match '('", ")");
                    // Try to recover by looking for the closing paren
                    var depth: i32 = 1;
                    while (self.current_token.type != .eof and depth > 0) {
                        if (self.current_token.type == .lparen) depth += 1;
                        if (self.current_token.type == .rparen) depth -= 1;
                        if (depth > 0) self.advance();
                    }
                    if (self.current_token.type == .rparen) {
                        self.advance(); // consume ')'
                        self.panic_mode = false; // Successfully recovered
                        return expr;
                    }
                    return error.ExpectedRightParen;
                }
                self.advance(); // consume ')'
                return expr;
            },
            .not_op => {
                self.advance();
                const operand = try self.parseExpressionWithPrecedence(@intFromEnum(Precedence.unary));
                const unary = try self.allocator.create(ast.UnaryOpNode);
                unary.* = ast.UnaryOpNode.init(
                    .not_op,
                    operand,
                    ast.SourceLocation.init(token.start, self.current_token.end, token.line, token.column)
                );
                return &unary.base;
            },
            .minus => {
                self.advance();
                const operand = try self.parseExpressionWithPrecedence(@intFromEnum(Precedence.unary));
                const unary = try self.allocator.create(ast.UnaryOpNode);
                unary.* = ast.UnaryOpNode.init(
                    .minus,
                    operand,
                    ast.SourceLocation.init(token.start, self.current_token.end, token.line, token.column)
                );
                return &unary.base;
            },
            .plus => {
                self.advance();
                const operand = try self.parseExpressionWithPrecedence(@intFromEnum(Precedence.unary));
                const unary = try self.allocator.create(ast.UnaryOpNode);
                unary.* = ast.UnaryOpNode.init(
                    .plus,
                    operand,
                    ast.SourceLocation.init(token.start, self.current_token.end, token.line, token.column)
                );
                return &unary.base;
            },
            .lbrace => {
                // Parse collection literal: { expr1, expr2, ... } or {}
                self.advance(); // consume '{'
                
                var elements = std.ArrayList(*ast.Node).init(self.allocator);
                defer elements.deinit();
                
                // Check for empty collection {}
                if (self.current_token.type == .rbrace) {
                    self.advance(); // consume '}'
                    // Create an empty collection literal
                    const collection = try self.allocator.create(ast.CollectionNode);
                    const elements_slice = try self.allocator.alloc(*ast.Node, 0);
                    collection.* = ast.CollectionNode.init(
                        elements_slice,
                        ast.SourceLocation.init(token.start, self.current_token.end, token.line, token.column)
                    );
                    return &collection.base;
                }
                
                // Parse collection elements
                while (true) {
                    const element = try self.parseExpression();
                    try elements.append(element);
                    
                    if (self.current_token.type == .comma) {
                        self.advance(); // consume ','
                        continue;
                    } else if (self.current_token.type == .rbrace) {
                        self.advance(); // consume '}'
                        break;
                    } else {
                        try self.recordError("Expected ',' or '}' in collection literal", ", or }");
                        return error.ExpectedCommaOrRightBrace;
                    }
                }
                
                // Create collection node
                const collection = try self.allocator.create(ast.CollectionNode);
                const elements_slice = try elements.toOwnedSlice();
                collection.* = ast.CollectionNode.init(
                    elements_slice,
                    ast.SourceLocation.init(token.start, self.current_token.end, token.line, token.column)
                );
                return &collection.base;
            },
            else => {
                try self.recordError("Unexpected token in expression", null);
                // Try to recover by advancing and creating an error node
                self.advance();
                return self.createErrorNode();
            },
        }
    }
    
    fn getBindingPower(self: *const Parser, token_type: lexer.TokenType) ?BindingPower {
        _ = self;
        
        return switch (token_type) {
            .or_op => BindingPower.init(.or_prec, false),
            .xor_op => BindingPower.init(.xor_prec, false),
            .and_op => BindingPower.init(.and_prec, false),
            .implies => BindingPower.init(.implies_prec, true), // right associative
            
            .equal, .not_equal, .equivalent, .not_equivalent => BindingPower.init(.equality, false),
            .pipe => BindingPower.init(.union_prec, false),
            .less, .greater, .less_equal, .greater_equal => BindingPower.init(.comparison, false),
            .in_op, .contains => BindingPower.init(.membership, false),
            
            .plus, .minus, .ampersand => BindingPower.init(.additive, false),
            .star, .slash, .div, .percent => BindingPower.init(.multiplicative, false),
            
            .dot, .lparen, .lbracket => BindingPower.init(.postfix, false),
            
            else => null,
        };
    }
    
    fn createErrorNode(self: *Parser) !*ast.Node {
        // Create a placeholder node for error recovery
        const literal = try self.allocator.create(ast.LiteralNode);
        literal.* = ast.LiteralNode.init(
            .null_value,
            ast.SourceLocation.init(
                self.current_token.start,
                self.current_token.end,
                self.current_token.line,
                self.current_token.column
            )
        );
        return &literal.base;
    }
    
    fn createBinaryOp(self: *Parser, operator: lexer.TokenType, left: *ast.Node, right: *ast.Node) !*ast.Node {
        const binary = try self.allocator.create(ast.BinaryOpNode);
        binary.* = ast.BinaryOpNode.init(
            operator,
            left,
            right,
            ast.SourceLocation.init(left.location.start, right.location.end, left.location.line, left.location.column)
        );
        return &binary.base;
    }
    
    fn createMemberAccess(self: *Parser, object: *ast.Node, property: []const u8) !*ast.Node {
        const member = try self.allocator.create(ast.MemberAccessNode);
        member.* = ast.MemberAccessNode.init(
            object,
            property,
            ast.SourceLocation.init(object.location.start, object.location.end, object.location.line, object.location.column)
        );
        return &member.base;
    }
    
    fn parseIndexer(self: *Parser, object: *ast.Node) !*ast.Node {
        self.advance(); // consume '['
        
        const index_expr = try self.parseExpressionWithPrecedence(0);
        
        if (self.current_token.type != .rbracket) {
            try self.recordError("Expected ']' after index expression", "]");
            return error.ExpectedRightBracket;
        }
        self.advance(); // consume ']'
        
        const indexer = try self.allocator.create(ast.IndexerNode);
        indexer.* = ast.IndexerNode.init(
            object,
            index_expr,
            ast.SourceLocation.init(object.location.start, self.current_token.end, object.location.line, object.location.column)
        );
        return &indexer.base;
    }

    fn parseFunctionCall(self: *Parser, function_name_node: *ast.Node) !*ast.Node {
        // We're at the opening '('
        if (self.current_token.type != .lparen) {
            try self.recordError("Expected '(' for function call", "(");
            return error.ExpectedLeftParen;
        }
        self.advance(); // consume '('
        
        // Get function name from the identifier node
        const function_name = if (function_name_node.node_type == .identifier) 
            function_name_node.cast(ast.IdentifierNode).?.name
        else {
            try self.recordError("Invalid function call target", null);
            return error.InvalidFunctionCall;
        };
        
        var arguments = std.ArrayList(*ast.Node).init(self.allocator);
        defer arguments.deinit();
        
        // Parse arguments
        if (self.current_token.type != .rparen) {
            while (true) {
                const arg = self.parseExpression() catch |err| {
                    // Try to recover to next comma or closing paren
                    while (self.current_token.type != .eof and 
                           self.current_token.type != .comma and 
                           self.current_token.type != .rparen) {
                        self.advance();
                    }
                    if (self.current_token.type == .eof) return err;
                    // Create a dummy error node and continue
                    const error_node = try self.createErrorNode();
                    try arguments.append(error_node);
                    if (self.current_token.type == .comma) {
                        self.advance();
                        continue;
                    }
                    break;
                };
                try arguments.append(arg);
                
                if (self.current_token.type == .comma) {
                    self.advance(); // consume ','
                    continue;
                } else if (self.current_token.type == .rparen) {
                    break;
                } else {
                    try self.recordError("Expected ',' or ')' in function arguments", ", or )");
                    // Try to recover
                    while (self.current_token.type != .eof and
                           self.current_token.type != .comma and
                           self.current_token.type != .rparen) {
                        self.advance();
                    }
                    if (self.current_token.type == .comma) {
                        self.advance();
                        continue;
                    }
                    if (self.current_token.type != .rparen) {
                        return error.ExpectedCommaOrRightParen;
                    }
                    break;
                }
            }
        }
        
        if (self.current_token.type != .rparen) {
            return error.ExpectedRightParen;
        }
        self.advance(); // consume ')'
        
        // Create argument array that the FunctionCallNode can own
        const args_slice = try self.allocator.alloc(*ast.Node, arguments.items.len);
        for (arguments.items, 0..) |arg, i| {
            args_slice[i] = arg;
        }
        
        const function_call = try self.allocator.create(ast.FunctionCallNode);
        function_call.* = ast.FunctionCallNode.init(
            function_name,
            args_slice,
            ast.SourceLocation.init(function_name_node.location.start, function_name_node.location.end, function_name_node.location.line, function_name_node.location.column)
        );
        
        // Free the original identifier node since we've extracted what we need from it
        ast.freeNode(self.allocator, function_name_node);
        
        return &function_call.base;
    }
    
    fn advance(self: *Parser) void {
        self.current_token = self.lexer_instance.nextToken();
    }
    
    fn match(self: *Parser, token_type: lexer.TokenType) bool {
        if (self.current_token.type == token_type) {
            self.advance();
            return true;
        }
        return false;
    }
    
    fn parseDateTimeString(self: *Parser, date_str: []const u8) !ast.LiteralNode.LiteralValue {
        
        // Parse different date/time formats
        if (date_str.len >= 1 and date_str[0] == 'T') {
            // Time only: THH:MM[:SS[.fff]]
            const time = try self.parseTimeString(date_str[1..]);
            return ast.LiteralNode.LiteralValue{ .time = time };
        } else if (std.mem.indexOf(u8, date_str, "T")) |t_pos| {
            // DateTime: YYYY-MM-DDTHH:MM:SS
            const date_part = date_str[0..t_pos];
            const time_part = date_str[t_pos + 1..];
            
            const date = try self.parseDateString(date_part);
            const time = try self.parseTimeString(time_part);
            
            return ast.LiteralNode.LiteralValue{ .date_time = types.DateTime{
                .date = date,
                .time = time,
            }};
        } else {
            // Date only: YYYY[-MM[-DD]]
            const date = try self.parseDateString(date_str);
            return ast.LiteralNode.LiteralValue{ .date = date };
        }
    }
    
    fn parseDateString(self: *Parser, date_str: []const u8) !types.Date {
        
        // Basic parsing - could be more robust
        var parts = std.mem.splitScalar(u8, date_str, '-');
        var part_array = std.ArrayList([]const u8).init(self.allocator);
        defer part_array.deinit();
        
        while (parts.next()) |part| {
            try part_array.append(part);
        }
        
        if (part_array.items.len < 1) return error.InvalidDate;
        
        const year = std.fmt.parseInt(i32, part_array.items[0], 10) catch return error.InvalidDate;
        const month: ?u8 = if (part_array.items.len > 1) 
            std.fmt.parseInt(u8, part_array.items[1], 10) catch return error.InvalidDate
        else null;
        const day: ?u8 = if (part_array.items.len > 2)
            std.fmt.parseInt(u8, part_array.items[2], 10) catch return error.InvalidDate
        else null;
        
        return types.Date{
            .year = year,
            .month = month,
            .day = day,
        };
    }
    
    fn parseTimeString(self: *Parser, time_str: []const u8) !types.Time {
        
        // Basic parsing for HH:MM[:SS[.fff]][Z|±HH:MM]
        // For now, just parse HH:MM:SS.fff part
        var working_str = time_str;
        
        // Remove timezone info for now
        if (std.mem.indexOf(u8, working_str, "Z")) |pos| {
            working_str = working_str[0..pos];
        } else if (std.mem.indexOf(u8, working_str, "+")) |pos| {
            working_str = working_str[0..pos];
        } else if (std.mem.lastIndexOf(u8, working_str, "-")) |pos| {
            if (pos > 2) { // Don't confuse with negative timezone
                working_str = working_str[0..pos];
            }
        }
        
        var parts = std.mem.splitScalar(u8, working_str, ':');
        var part_array = std.ArrayList([]const u8).init(self.allocator);
        defer part_array.deinit();
        
        while (parts.next()) |part| {
            try part_array.append(part);
        }
        
        if (part_array.items.len < 2) return error.InvalidTime;
        
        const hour = std.fmt.parseInt(u8, part_array.items[0], 10) catch return error.InvalidTime;
        const minute = std.fmt.parseInt(u8, part_array.items[1], 10) catch return error.InvalidTime;
        
        var second: ?u8 = null;
        var millisecond: ?u16 = null;
        
        if (part_array.items.len > 2) {
            const sec_part = part_array.items[2];
            if (std.mem.indexOf(u8, sec_part, ".")) |dot_pos| {
                second = std.fmt.parseInt(u8, sec_part[0..dot_pos], 10) catch return error.InvalidTime;
                const ms_str = sec_part[dot_pos + 1..];
                millisecond = std.fmt.parseInt(u16, ms_str, 10) catch return error.InvalidTime;
            } else {
                second = std.fmt.parseInt(u8, sec_part, 10) catch return error.InvalidTime;
            }
        }
        
        return types.Time{
            .hour = hour,
            .minute = minute,
            .second = second,
            .millisecond = millisecond,
        };
    }
    
    fn parseQuantityString(self: *Parser, quantity_str: []const u8) !ast.LiteralNode.LiteralValue {
        _ = self;
        // Parse quantity like "5 'kg'" or "10.5 'cm'"
        // Find the first quote to separate value from unit
        var space_pos: ?usize = null;
        for (quantity_str, 0..) |char, i| {
            if (char == ' ') {
                space_pos = i;
                break;
            }
        }
        
        if (space_pos) |pos| {
            // Parse value part
            const value_str = quantity_str[0..pos];
            const value = if (std.mem.indexOf(u8, value_str, ".") != null)
                std.fmt.parseFloat(f64, value_str) catch return error.InvalidQuantity
            else
                @as(f64, @floatFromInt(std.fmt.parseInt(i64, value_str, 10) catch return error.InvalidQuantity));
            
            // Parse unit part (remove quotes)
            const unit_part = std.mem.trim(u8, quantity_str[pos..], " ");
            if (unit_part.len >= 2 and unit_part[0] == '\'' and unit_part[unit_part.len - 1] == '\'') {
                const unit = unit_part[1..unit_part.len - 1];
                return ast.LiteralNode.LiteralValue{ .quantity = types.Quantity.init(value, unit) };
            } else {
                return error.InvalidQuantity;
            }
        } else {
            // No unit, just a number - this shouldn't happen with quantity token type
            return error.InvalidQuantity;
        }
    }
};

// Tests
test "parser literals" {
    // Boolean
    {
        const source = "true";
        var lex = lexer.Lexer.init(source);
        var parser = Parser.init(std.testing.allocator, &lex);
        defer parser.deinit();
        
        const result = try parser.parseExpression();
        defer ast.freeNode(std.testing.allocator, result);
        try std.testing.expectEqual(ast.Node.NodeType.literal, result.node_type);
        
        const literal = result.cast(ast.LiteralNode).?;
        try std.testing.expectEqual(true, literal.value.boolean);
    }
    
    // Number
    {
        const source = "42";
        var lex = lexer.Lexer.init(source);
        var parser = Parser.init(std.testing.allocator, &lex);
        defer parser.deinit();
        
        const result = try parser.parseExpression();
        defer ast.freeNode(std.testing.allocator, result);
        try std.testing.expectEqual(ast.Node.NodeType.literal, result.node_type);
        
        const literal = result.cast(ast.LiteralNode).?;
        try std.testing.expectEqual(@as(i64, 42), literal.value.integer);
    }
}

test "parser binary operations" {
    const source = "1 + 2";
    var lex = lexer.Lexer.init(source);
    var parser = Parser.init(std.testing.allocator, &lex);
    defer parser.deinit();
    
    const result = try parser.parseExpression();
    defer ast.freeNode(std.testing.allocator, result);
    try std.testing.expectEqual(ast.Node.NodeType.binary_op, result.node_type);
    
    const binary = result.cast(ast.BinaryOpNode).?;
    try std.testing.expectEqual(lexer.TokenType.plus, binary.operator);
    
    const left = binary.left.cast(ast.LiteralNode).?;
    try std.testing.expectEqual(@as(i64, 1), left.value.integer);
    
    const right = binary.right.cast(ast.LiteralNode).?;
    try std.testing.expectEqual(@as(i64, 2), right.value.integer);
}