const std = @import("std");
const types = @import("../types.zig");

// Forward declaration for EvaluationContext
pub const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

// Helper function to convert values to boolean
fn toBoolValue(value: types.Value) bool {
    return switch (value) {
        .boolean => |val| val,
        .integer => |val| val != 0,
        .decimal => |val| val != 0.0,
        .string => |val| val.len > 0,
        .date, .time, .date_time => true,
        .quantity => |val| val.value != 0.0,
        .collection => |coll| coll.len > 0,
        .json_object => true, // JSON objects are considered truthy
        .null_value => false,
    };
}

/// not() - logical negation
pub fn not(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len != 1) return error.InvalidArguments;
    
    const arg = args[0];
    return types.Value{ .boolean = !toBoolValue(arg) };
}