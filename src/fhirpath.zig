const std = @import("std");

// Core modules
pub const lexer = @import("lexer.zig");
pub const parser = @import("parser.zig");
pub const ast = @import("ast.zig");
pub const types = @import("types.zig");
pub const evaluator = @import("evaluator.zig");

// Error types with detailed context
pub const FHIRPathError = error{
    // Lexer errors
    InvalidToken,
    UnterminatedString,
    InvalidNumber,
    InvalidDate,
    InvalidTime,
    InvalidQuantity,
    InvalidEscapeSequence,

    // Parser errors
    UnexpectedToken,
    InvalidExpression,
    MissingOperand,
    ExpectedRightParen,
    ExpectedLeftParen,
    ExpectedRightBracket,
    ExpectedIdentifier,
    ExpectedCommaOrRightParen,
    InvalidFunctionCall,

    // Evaluation errors
    TypeMismatch,
    InvalidOperation,
    DivisionByZero,
    UnsupportedOperation,

    // Runtime errors
    OutOfMemory,
    StackOverflow,
    NotImplemented,
};

// Error context for detailed error reporting
pub const ErrorContext = struct {
    error_type: FHIRPathError,
    message: []const u8,
    location: ?ast.SourceLocation,
    expression: ?[]const u8,

    pub fn init(error_type: FHIRPathError, message: []const u8, location: ?ast.SourceLocation, expression: ?[]const u8) ErrorContext {
        return ErrorContext{
            .error_type = error_type,
            .message = message,
            .location = location,
            .expression = expression,
        };
    }

    pub fn format(self: *const ErrorContext, allocator: std.mem.Allocator) ![]const u8 {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        const writer = buffer.writer();

        // Error type and message
        try writer.print("FHIRPath Error: {s}\n", .{self.message});

        // Location information
        if (self.location) |loc| {
            try writer.print("  at line {d}, column {d}\n", .{ loc.line, loc.column });
        }

        // Expression context
        if (self.expression) |expr| {
            try writer.print("  in expression: {s}\n", .{expr});

            // Add visual indicator if we have location
            if (self.location) |loc| {
                try writer.print("  ");
                for (0..loc.column - 1) |_| {
                    try writer.print(" ");
                }
                try writer.print("^\n");
            }
        }

        return buffer.toOwnedSlice();
    }
};

// Convenience function for simple parsing without caching
pub fn parse(expression: []const u8, allocator: std.mem.Allocator) !*ast.Node {
    var lex = lexer.Lexer.init(expression);
    var par = parser.Parser.init(allocator, &lex);
    defer par.deinit();
    return par.parseExpression();
}

// Main FHIRPath interface
pub const FHIRPath = struct {
    allocator: std.mem.Allocator,
    cache: ExpressionCache,

    const ExpressionCache = std.HashMap([]const u8, *ast.Node, std.hash_map.StringContext, std.hash_map.default_max_load_percentage);

    pub fn init(allocator: std.mem.Allocator) FHIRPath {
        return FHIRPath{
            .allocator = allocator,
            .cache = ExpressionCache.init(allocator),
        };
    }

    pub fn deinit(self: *FHIRPath) void {
        // Free cached expressions and AST nodes
        var iterator = self.cache.iterator();
        while (iterator.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            ast.freeNode(self.allocator, entry.value_ptr.*);
        }
        self.cache.deinit();
    }

    pub fn compile(self: *FHIRPath, expression: []const u8) !*ast.Node {
        // Check cache first
        if (self.cache.get(expression)) |cached| {
            return cached;
        }

        // Parse expression
        var lex = lexer.Lexer.init(expression);
        var par = parser.Parser.init(self.allocator, &lex);
        defer par.deinit();
        const node = try par.parseExpression();

        // Cache the result (copy the expression string to owned memory)
        const owned_expr = try self.allocator.dupe(u8, expression);
        try self.cache.put(owned_expr, node);

        return node;
    }

    pub fn evaluate(self: *FHIRPath, node: *ast.Node, context: *evaluator.EvaluationContext) !types.Value {
        var eval = evaluator.Evaluator.init(self.allocator);
        return eval.evaluate(node, context);
    }

    pub fn evaluateString(self: *FHIRPath, expression: []const u8, context: *evaluator.EvaluationContext) !types.Value {
        const node = try self.compile(expression);
        return self.evaluate(node, context);
    }

    pub fn evaluateSimple(self: *FHIRPath, expression: []const u8) !types.Value {
        var context = evaluator.EvaluationContext.init(self.allocator);
        defer context.deinit();
        const result = try self.evaluateString(expression, &context);
        defer result.deinit(self.allocator); // Clean up the original result
        
        // Extract single value from collection for simple API
        switch (result) {
            .collection => |coll| {
                if (coll.len == 1) {
                    // Create a copy of the value since we're freeing the original collection
                    return coll[0];
                } else if (coll.len == 0) {
                    return types.Value{ .null_value = {} }; // Return null for empty collections in simple API
                } else {
                    return error.MultipleValues; // Can't simplify multiple values
                }
            },
            else => return result, // Already a single value
        }
    }
};

// Tests
test "FHIRPath basic functionality" {
    var fhirpath = FHIRPath.init(std.testing.allocator);
    defer fhirpath.deinit();

    // Test boolean literal
    {
        const result = try fhirpath.evaluateSimple("true");
        try std.testing.expect(result == .boolean and result.boolean == true);
    }

    // Test arithmetic
    {
        const result = try fhirpath.evaluateSimple("1 + 2");
        try std.testing.expect(result == .integer and result.integer == 3);
    }

    // Test logical operation
    {
        const result = try fhirpath.evaluateSimple("true and false");
        try std.testing.expect(result == .boolean and result.boolean == false);
    }
}
