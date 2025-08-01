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

// convertsToInteger() - checks if value can be converted to integer
pub fn convertsToInteger(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .integer => types.Value{ .boolean = true },
        .decimal => |val| types.Value{ .boolean = val == @trunc(val) and val >= std.math.minInt(i64) and val <= std.math.maxInt(i64) },
        .string => |str| blk: {
            if (std.fmt.parseInt(i64, str, 10)) |_| {
                break :blk types.Value{ .boolean = true };
            } else |_| {
                break :blk types.Value{ .boolean = false };
            }
        },
        .boolean => types.Value{ .boolean = true }, // Booleans can convert to integers (true=1, false=0)
        else => types.Value{ .boolean = false },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// convertsToDecimal() - checks if value can be converted to decimal
pub fn convertsToDecimal(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .integer, .decimal => types.Value{ .boolean = true },
        .string => |str| blk: {
            if (std.fmt.parseFloat(f64, str)) |_| {
                break :blk types.Value{ .boolean = true };
            } else |_| {
                break :blk types.Value{ .boolean = false };
            }
        },
        .boolean => types.Value{ .boolean = true }, // Booleans can convert to decimals
        else => types.Value{ .boolean = false },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// convertsToBoolean() - checks if value can be converted to boolean
pub fn convertsToBoolean(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .boolean => types.Value{ .boolean = true },
        .integer, .decimal => types.Value{ .boolean = true },
        .string => |str| types.Value{ .boolean = std.mem.eql(u8, str, "true") or std.mem.eql(u8, str, "false") },
        else => types.Value{ .boolean = false },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// convertsToString() - checks if value can be converted to string
pub fn convertsToString(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    // Almost all values can be converted to string
    const result = switch (input) {
        .collection => |coll| types.Value{ .boolean = coll.len > 0 }, // Empty collection converts to false
        else => types.Value{ .boolean = true },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// convertsToQuantity() - checks if value can be converted to quantity
pub fn convertsToQuantity(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .quantity => types.Value{ .boolean = true },
        .integer, .decimal => types.Value{ .boolean = true }, // Numbers can be quantities without units
        .string => |str| blk: {
            // Basic check for quantity format (number followed by unit)
            // This is a simplified implementation
            var parts = std.mem.splitScalar(u8, str, ' ');
            const number_part = parts.next() orelse break :blk types.Value{ .boolean = false };
            _ = parts.next(); // Unit part (may be null)
            
            // Check if first part is a number
            if (std.fmt.parseFloat(f64, number_part)) |_| {
                // If there's a unit part, it's a quantity
                // If no unit part, it's still a valid quantity (unitless)
                break :blk types.Value{ .boolean = true };
            } else |_| {
                break :blk types.Value{ .boolean = false };
            }
        },
        else => types.Value{ .boolean = false },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// toInteger() - converts value to integer
pub fn toInteger(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .integer => input,
        .decimal => |val| types.Value{ .integer = @intFromFloat(val) },
        .string => |str| blk: {
            if (std.fmt.parseInt(i64, str, 10)) |int_val| {
                break :blk types.Value{ .integer = int_val };
            } else |_| {
                return types.Value{ .collection = &[_]types.Value{} }; // Empty collection for invalid conversion
            }
        },
        .boolean => |val| types.Value{ .integer = if (val) 1 else 0 },
        else => return types.Value{ .collection = &[_]types.Value{} },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// toDecimal() - converts value to decimal
pub fn toDecimal(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .decimal => input,
        .integer => |val| types.Value{ .decimal = @floatFromInt(val) },
        .string => |str| blk: {
            if (std.fmt.parseFloat(f64, str)) |float_val| {
                break :blk types.Value{ .decimal = float_val };
            } else |_| {
                return types.Value{ .collection = &[_]types.Value{} };
            }
        },
        .boolean => |val| types.Value{ .decimal = if (val) 1.0 else 0.0 },
        else => return types.Value{ .collection = &[_]types.Value{} },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// toBoolean() - converts value to boolean
pub fn toBoolean(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .boolean => input,
        .integer => |val| types.Value{ .boolean = val != 0 },
        .decimal => |val| types.Value{ .boolean = val != 0.0 },
        .string => |str| blk: {
            if (std.mem.eql(u8, str, "true")) {
                break :blk types.Value{ .boolean = true };
            } else if (std.mem.eql(u8, str, "false")) {
                break :blk types.Value{ .boolean = false };
            } else {
                return types.Value{ .collection = &[_]types.Value{} };
            }
        },
        else => return types.Value{ .collection = &[_]types.Value{} },
    };
    
    return try wrapInCollection(context.allocator, result);
}

// toString() - converts value to string
pub fn toString(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    
    const result = switch (input) {
        .string => input,
        .integer => |val| blk: {
            const str = try std.fmt.allocPrint(context.allocator, "{d}", .{val});
            break :blk types.Value{ .string = str };
        },
        .decimal => |val| blk: {
            const str = try std.fmt.allocPrint(context.allocator, "{d}", .{val});
            break :blk types.Value{ .string = str };
        },
        .boolean => |val| types.Value{ .string = if (val) "true" else "false" },
        else => return types.Value{ .collection = &[_]types.Value{} },
    };
    
    return try wrapInCollection(context.allocator, result);
}