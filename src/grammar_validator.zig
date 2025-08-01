const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const ast = @import("ast.zig");

/// Grammar validation test case
pub const GrammarTest = struct {
    name: []const u8,
    expression: []const u8,
    rule: []const u8,
    should_parse: bool,
    expected_node_type: ?ast.Node.NodeType = null,
};

/// Validates parser against ANTLR grammar rules
pub const GrammarValidator = struct {
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) GrammarValidator {
        return .{ .allocator = allocator };
    }
    
    /// Run all grammar validation tests
    pub fn validateGrammar(self: *GrammarValidator) !ValidationResult {
        const tests = try self.createGrammarTests();
        defer self.allocator.free(tests);
        
        var passed: usize = 0;
        var failed: usize = 0;
        var failures = std.ArrayList(TestFailure).init(self.allocator);
        defer failures.deinit();
        
        for (tests) |test_case| {
            const result = try self.runTest(test_case);
            if (result.passed) {
                passed += 1;
            } else {
                failed += 1;
                try failures.append(result.failure.?);
            }
        }
        
        return ValidationResult{
            .total = tests.len,
            .passed = passed,
            .failed = failed,
            .failures = try failures.toOwnedSlice(),
        };
    }
    
    fn runTest(self: *GrammarValidator, test_case: GrammarTest) !TestResult {
        var lex = lexer.Lexer.init(test_case.expression);
        var par = parser.Parser.init(self.allocator, &lex);
        defer par.deinit();
        
        const result = par.parseExpression() catch |err| {
            if (!test_case.should_parse) {
                // Expected to fail
                return TestResult{ .passed = true, .failure = null };
            }
            
            const error_msg = try std.fmt.allocPrint(self.allocator, "Parse error: {}", .{err});
            return TestResult{
                .passed = false,
                .failure = TestFailure{
                    .test_name = test_case.name,
                    .expression = test_case.expression,
                    .rule = test_case.rule,
                    .error_msg = error_msg,
                    .expected = "Should parse successfully",
                    .actual = "Failed to parse",
                },
            };
        };
        
        if (!test_case.should_parse) {
            // Expected to fail but parsed successfully
            return TestResult{
                .passed = false,
                .failure = TestFailure{
                    .test_name = test_case.name,
                    .expression = test_case.expression,
                    .rule = test_case.rule,
                    .error_msg = null,
                    .expected = "Should fail to parse",
                    .actual = "Parsed successfully",
                },
            };
        }
        
        // Check node type if specified
        if (test_case.expected_node_type) |expected_type| {
            if (result.node_type != expected_type) {
                const expected_str = try std.fmt.allocPrint(self.allocator, "Node type: {s}", .{@tagName(expected_type)});
                const actual_str = try std.fmt.allocPrint(self.allocator, "Node type: {s}", .{@tagName(result.node_type)});
                return TestResult{
                    .passed = false,
                    .failure = TestFailure{
                        .test_name = test_case.name,
                        .expression = test_case.expression,
                        .rule = test_case.rule,
                        .error_msg = null,
                        .expected = expected_str,
                        .actual = actual_str,
                    },
                };
            }
        }
        
        return TestResult{ .passed = true, .failure = null };
    }
    
    fn createGrammarTests(self: *GrammarValidator) ![]GrammarTest {
        var tests = std.ArrayList(GrammarTest).init(self.allocator);
        defer tests.deinit();
        
        // Test term expressions (#termExpression)
        try tests.append(.{
            .name = "Boolean literal term",
            .expression = "true",
            .rule = "termExpression",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        try tests.append(.{
            .name = "Number literal term",
            .expression = "42",
            .rule = "termExpression",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        try tests.append(.{
            .name = "String literal term",
            .expression = "'hello'",
            .rule = "termExpression",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        // Test invocation expressions (#invocationExpression)
        try tests.append(.{
            .name = "Member access",
            .expression = "Patient.name",
            .rule = "invocationExpression",
            .should_parse = true,
            .expected_node_type = .member_access,
        });
        
        try tests.append(.{
            .name = "Chained member access",
            .expression = "Patient.name.given",
            .rule = "invocationExpression",
            .should_parse = true,
            .expected_node_type = .member_access,
        });
        
        // Test indexer expressions (#indexerExpression)
        try tests.append(.{
            .name = "Indexer with number",
            .expression = "items[0]",
            .rule = "indexerExpression",
            .should_parse = true,
            .expected_node_type = .indexer,
        });
        
        try tests.append(.{
            .name = "Indexer with expression",
            .expression = "items[index + 1]",
            .rule = "indexerExpression",
            .should_parse = true,
            .expected_node_type = .indexer,
        });
        
        // Test polarity expressions (#polarityExpression)
        try tests.append(.{
            .name = "Negative number",
            .expression = "-42",
            .rule = "polarityExpression",
            .should_parse = true,
            .expected_node_type = .unary_op,
        });
        
        try tests.append(.{
            .name = "Positive number",
            .expression = "+42",
            .rule = "polarityExpression",
            .should_parse = true,
            .expected_node_type = .unary_op,
        });
        
        // Test multiplicative expressions (#multiplicativeExpression)
        try tests.append(.{
            .name = "Multiplication",
            .expression = "2 * 3",
            .rule = "multiplicativeExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Division",
            .expression = "10 / 2",
            .rule = "multiplicativeExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Div operator",
            .expression = "10 div 3",
            .rule = "multiplicativeExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Mod operator",
            .expression = "10 mod 3",
            .rule = "multiplicativeExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test additive expressions (#additiveExpression)
        try tests.append(.{
            .name = "Addition",
            .expression = "1 + 2",
            .rule = "additiveExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Subtraction",
            .expression = "5 - 3",
            .rule = "additiveExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "String concatenation",
            .expression = "'hello' & ' world'",
            .rule = "additiveExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test union expressions (#unionExpression)
        try tests.append(.{
            .name = "Union operator",
            .expression = "a | b",
            .rule = "unionExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test inequality expressions (#inequalityExpression)
        try tests.append(.{
            .name = "Less than",
            .expression = "a < b",
            .rule = "inequalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Greater than",
            .expression = "a > b",
            .rule = "inequalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Less than or equal",
            .expression = "a <= b",
            .rule = "inequalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Greater than or equal",
            .expression = "a >= b",
            .rule = "inequalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test equality expressions (#equalityExpression)
        try tests.append(.{
            .name = "Equality",
            .expression = "a = b",
            .rule = "equalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Inequality",
            .expression = "a != b",
            .rule = "equalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Equivalence",
            .expression = "a ~ b",
            .rule = "equalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Non-equivalence",
            .expression = "a !~ b",
            .rule = "equalityExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test membership expressions (#membershipExpression)
        try tests.append(.{
            .name = "In operator",
            .expression = "a in b",
            .rule = "membershipExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Contains operator",
            .expression = "a contains b",
            .rule = "membershipExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test logical expressions
        try tests.append(.{
            .name = "And expression",
            .expression = "a and b",
            .rule = "andExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Or expression",
            .expression = "a or b",
            .rule = "orExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Xor expression",
            .expression = "a xor b",
            .rule = "orExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        try tests.append(.{
            .name = "Implies expression",
            .expression = "a implies b",
            .rule = "impliesExpression",
            .should_parse = true,
            .expected_node_type = .binary_op,
        });
        
        // Test parenthesized expressions
        try tests.append(.{
            .name = "Parenthesized expression",
            .expression = "(1 + 2)",
            .rule = "parenthesizedTerm",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "Nested parentheses",
            .expression = "((1 + 2) * 3)",
            .rule = "parenthesizedTerm",
            .should_parse = true,
        });
        
        // Test function calls
        try tests.append(.{
            .name = "Function call no args",
            .expression = "empty()",
            .rule = "functionInvocation",
            .should_parse = true,
            .expected_node_type = .function_call,
        });
        
        try tests.append(.{
            .name = "Function call with args",
            .expression = "substring(0, 5)",
            .rule = "functionInvocation",
            .should_parse = true,
            .expected_node_type = .function_call,
        });
        
        // Test quantity literals
        try tests.append(.{
            .name = "Quantity with unit",
            .expression = "5 'kg'",
            .rule = "quantityLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        try tests.append(.{
            .name = "Quantity with UCUM unit",
            .expression = "10.5 'mg/dL'",
            .rule = "quantityLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        // Test date/time literals
        try tests.append(.{
            .name = "Date literal",
            .expression = "@2023-12-25",
            .rule = "dateTimeLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        try tests.append(.{
            .name = "Time literal",
            .expression = "@T14:30:00",
            .rule = "timeLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        try tests.append(.{
            .name = "DateTime literal",
            .expression = "@2023-12-25T14:30:00",
            .rule = "dateTimeLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        // Test null literal
        try tests.append(.{
            .name = "Null literal",
            .expression = "{}",
            .rule = "nullLiteral",
            .should_parse = true,
            .expected_node_type = .literal,
        });
        
        // Test external constants
        try tests.append(.{
            .name = "External constant identifier",
            .expression = "%context",
            .rule = "externalConstant",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "External constant string",
            .expression = "%'vs-administrative-gender'",
            .rule = "externalConstant",
            .should_parse = true,
        });
        
        // Test special invocations
        try tests.append(.{
            .name = "$this invocation",
            .expression = "$this",
            .rule = "thisInvocation",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "$index invocation",
            .expression = "$index",
            .rule = "indexInvocation",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "$total invocation",
            .expression = "$total",
            .rule = "totalInvocation",
            .should_parse = true,
        });
        
        // Test operator precedence
        try tests.append(.{
            .name = "Precedence: multiplication before addition",
            .expression = "1 + 2 * 3",
            .rule = "expression",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "Precedence: comparison before logical",
            .expression = "a > 5 and b < 10",
            .rule = "expression",
            .should_parse = true,
        });
        
        try tests.append(.{
            .name = "Complex precedence",
            .expression = "a + b * c > d and e or f implies g",
            .rule = "expression",
            .should_parse = true,
        });
        
        return try tests.toOwnedSlice();
    }
};

pub const ValidationResult = struct {
    total: usize,
    passed: usize,
    failed: usize,
    failures: []TestFailure,
    
    pub fn format(self: ValidationResult, writer: anytype) !void {
        try writer.print("\nGrammar Validation Results\n", .{});
        try writer.print("==========================\n", .{});
        try writer.print("Total tests: {}\n", .{self.total});
        try writer.print("Passed: {} ({d:.1}%)\n", .{ 
            self.passed, 
            if (self.total > 0) @as(f64, @floatFromInt(self.passed)) / @as(f64, @floatFromInt(self.total)) * 100.0 else 0.0 
        });
        try writer.print("Failed: {}\n\n", .{self.failed});
        
        if (self.failures.len > 0) {
            try writer.print("Failures:\n", .{});
            try writer.print("---------\n", .{});
            for (self.failures) |failure| {
                try failure.format(writer);
                try writer.print("\n", .{});
            }
        }
    }
    
    pub fn deinit(self: *ValidationResult, allocator: std.mem.Allocator) void {
        for (self.failures) |*failure| {
            failure.deinit(allocator);
        }
        allocator.free(self.failures);
    }
};

pub const TestResult = struct {
    passed: bool,
    failure: ?TestFailure,
};

pub const TestFailure = struct {
    test_name: []const u8,
    expression: []const u8,
    rule: []const u8,
    error_msg: ?[]const u8,
    expected: []const u8,
    actual: []const u8,
    
    pub fn format(self: TestFailure, writer: anytype) !void {
        try writer.print("❌ {s}\n", .{self.test_name});
        try writer.print("   Expression: {s}\n", .{self.expression});
        try writer.print("   Rule: {s}\n", .{self.rule});
        if (self.error_msg) |err| {
            try writer.print("   Error: {s}\n", .{err});
        }
        try writer.print("   Expected: {s}\n", .{self.expected});
        try writer.print("   Actual: {s}\n", .{self.actual});
    }
    
    pub fn deinit(self: *TestFailure, allocator: std.mem.Allocator) void {
        if (self.error_msg) |err| allocator.free(err);
        allocator.free(self.expected);
        allocator.free(self.actual);
    }
};