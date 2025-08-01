const std = @import("std");
const types = @import("../types.zig");
const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

// Helper function to convert single values from collections
fn extractSingleValue(value: types.Value) !types.Value {
    switch (value) {
        .collection => |coll| {
            if (coll.len == 0) return error.EmptyCollection;
            if (coll.len > 1) return error.MultipleValues;
            return coll[0];
        },
        else => return value,
    }
}

// Helper function to wrap results in collections
fn wrapInCollection(allocator: std.mem.Allocator, value: types.Value) !types.Value {
    switch (value) {
        .collection => return value,
        else => {
            const collection = try allocator.alloc(types.Value, 1);
            collection[0] = value;
            return types.Value{ .collection = collection };
        }
    }
}

// Helper to get numeric value as f64
fn getNumericValue(value: types.Value) !f64 {
    return switch (value) {
        .integer => |i| @floatFromInt(i),
        .decimal => |d| d,
        else => error.TypeMismatch,
    };
}

// abs() - absolute value
pub fn abs(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const result = switch (input) {
        .integer => |val| types.Value{ .integer = @intCast(@abs(val)) },
        .decimal => |val| types.Value{ .decimal = @abs(val) },
        else => return error.TypeMismatch,
    };
    
    return try wrapInCollection(context.allocator, result);
}

// ceiling() - ceiling function
pub fn ceiling(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    const result = types.Value{ .integer = @intFromFloat(@ceil(numeric_val)) };
    
    return try wrapInCollection(context.allocator, result);
}

// floor() - floor function
pub fn floor(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    const result = types.Value{ .integer = @intFromFloat(@floor(numeric_val)) };
    
    return try wrapInCollection(context.allocator, result);
}

// truncate() - truncate to integer
pub fn truncate(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    const result = types.Value{ .integer = @intFromFloat(@trunc(numeric_val)) };
    
    return try wrapInCollection(context.allocator, result);
}

// round() - round to nearest integer or specified precision
pub fn round(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len < 1 or args.len > 2) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    
    if (args.len == 1) {
        // Round to nearest integer
        const result = types.Value{ .integer = @intFromFloat(@round(numeric_val)) };
        return try wrapInCollection(context.allocator, result);
    } else {
        // Round to specified precision
        const precision_input = try extractSingleValue(args[1]);
        const precision = switch (precision_input) {
            .integer => |p| p,
            else => return error.TypeMismatch,
        };
        
        const multiplier = std.math.pow(f64, 10.0, @floatFromInt(precision));
        const rounded = @round(numeric_val * multiplier) / multiplier;
        const result = types.Value{ .decimal = rounded };
        
        return try wrapInCollection(context.allocator, result);
    }
}

// sqrt() - square root
pub fn sqrt(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    
    if (numeric_val < 0) {
        return error.InvalidValue; // Square root of negative number
    }
    
    const result = types.Value{ .decimal = @sqrt(numeric_val) };
    return try wrapInCollection(context.allocator, result);
}

// exp() - exponential function (e^x)
pub fn exp(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    const result = types.Value{ .decimal = @exp(numeric_val) };
    
    return try wrapInCollection(context.allocator, result);
}

// ln() - natural logarithm
pub fn ln(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const numeric_val = try getNumericValue(input);
    
    if (numeric_val <= 0) {
        return error.InvalidValue; // Logarithm of non-positive number
    }
    
    const result = types.Value{ .decimal = @log(numeric_val) };
    return try wrapInCollection(context.allocator, result);
}

// log() - logarithm with specified base
pub fn log(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const base_input = try extractSingleValue(args[1]);
    
    const numeric_val = try getNumericValue(input);
    const base_val = try getNumericValue(base_input);
    
    if (numeric_val <= 0 or base_val <= 0 or base_val == 1) {
        return error.InvalidValue;
    }
    
    const result = types.Value{ .decimal = @log(numeric_val) / @log(base_val) };
    return try wrapInCollection(context.allocator, result);
}

// power() - raise to power
pub fn power(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArgumentCount;
    
    const base_input = try extractSingleValue(args[0]);
    const exponent_input = try extractSingleValue(args[1]);
    
    const base_val = try getNumericValue(base_input);
    const exponent_val = try getNumericValue(exponent_input);
    
    const result = types.Value{ .decimal = std.math.pow(f64, base_val, exponent_val) };
    return try wrapInCollection(context.allocator, result);
}