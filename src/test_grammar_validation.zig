const std = @import("std");
const grammar_validator = @import("grammar_validator.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("Running FHIRPath Grammar Validation\n", .{});
    try stdout.print("===================================\n\n", .{});
    
    var validator = grammar_validator.GrammarValidator.init(allocator);
    var result = try validator.validateGrammar();
    defer result.deinit(allocator);
    
    try result.format(stdout);
    
    // Exit with error code if any tests failed
    if (result.failed > 0) {
        std.process.exit(1);
    }
}

test "Grammar validation" {
    var validator = grammar_validator.GrammarValidator.init(std.testing.allocator);
    var result = try validator.validateGrammar();
    defer result.deinit(std.testing.allocator);
    
    if (result.failed > 0) {
        std.log.err("Grammar validation failed: {} tests failed", .{result.failed});
        for (result.failures) |failure| {
            std.log.err("  - {s}: {s}", .{ failure.test_name, failure.expression });
        }
    }
    
    try std.testing.expect(result.failed == 0);
}