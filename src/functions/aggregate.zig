const std = @import("std");
const types = @import("../types.zig");
const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

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

// Helper to collect numeric values from a collection
fn collectNumericValues(collection: []types.Value, allocator: std.mem.Allocator) ![]f64 {
    var numbers = std.ArrayList(f64).init(allocator);
    defer numbers.deinit();
    
    for (collection) |value| {
        const numeric = getNumericValue(value) catch continue; // Skip non-numeric values
        try numbers.append(numeric);
    }
    
    return try numbers.toOwnedSlice();
}

// sum() - sum of numeric values in collection
pub fn sum(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => {
            // Single value - create temporary collection
            const temp = try context.allocator.alloc(types.Value, 1);
            temp[0] = input;
            defer context.allocator.free(temp);
            const temp_collection = types.Value{ .collection = temp };
            var temp_args = [_]types.Value{temp_collection};
            return try sum(context, temp_args[0..]);
        }
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} }; // Empty result for empty collection
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} }; // No numeric values
    }
    
    var total: f64 = 0;
    for (numbers) |num| {
        total += num;
    }
    
    // Return integer if all inputs were integers and result is whole
    const all_integers = blk: {
        for (collection) |value| {
            switch (value) {
                .integer => continue,
                .decimal => break :blk false,
                else => continue,
            }
        }
        break :blk true;
    };
    
    const result = if (all_integers and total == @trunc(total))
        types.Value{ .integer = @intFromFloat(total) }
    else
        types.Value{ .decimal = total };
    
    return try wrapInCollection(context.allocator, result);
}

// min() - minimum value in collection
pub fn min(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => return try wrapInCollection(context.allocator, input), // Single value is its own min
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    var minimum = numbers[0];
    for (numbers[1..]) |num| {
        if (num < minimum) {
            minimum = num;
        }
    }
    
    // Find original value to preserve type
    var result_value: ?types.Value = null;
    for (collection) |value| {
        const num_val = getNumericValue(value) catch continue;
        if (num_val == minimum) {
            result_value = value;
            break;
        }
    }
    
    return try wrapInCollection(context.allocator, result_value orelse types.Value{ .decimal = minimum });
}

// max() - maximum value in collection
pub fn max(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => return try wrapInCollection(context.allocator, input), // Single value is its own max
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    var maximum = numbers[0];
    for (numbers[1..]) |num| {
        if (num > maximum) {
            maximum = num;
        }
    }
    
    // Find original value to preserve type
    var result_value: ?types.Value = null;
    for (collection) |value| {
        const num_val = getNumericValue(value) catch continue;
        if (num_val == maximum) {
            result_value = value;
            break;
        }
    }
    
    return try wrapInCollection(context.allocator, result_value orelse types.Value{ .decimal = maximum });
}

// avg() - average of numeric values in collection
pub fn avg(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => return try wrapInCollection(context.allocator, input), // Single value average is itself
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    var total: f64 = 0;
    for (numbers) |num| {
        total += num;
    }
    
    const average = total / @as(f64, @floatFromInt(numbers.len));
    const result = types.Value{ .decimal = average };
    
    return try wrapInCollection(context.allocator, result);
}

// stdDev() - standard deviation (sample)
pub fn stdDev(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => {
            // Single value has standard deviation of 0
            return try wrapInCollection(context.allocator, types.Value{ .decimal = 0.0 });
        }
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len <= 1) {
        return try wrapInCollection(context.allocator, types.Value{ .decimal = 0.0 });
    }
    
    // Calculate mean
    var total: f64 = 0;
    for (numbers) |num| {
        total += num;
    }
    const mean = total / @as(f64, @floatFromInt(numbers.len));
    
    // Calculate variance (sample variance: divide by n-1)
    var variance_sum: f64 = 0;
    for (numbers) |num| {
        const diff = num - mean;
        variance_sum += diff * diff;
    }
    const var_result = variance_sum / @as(f64, @floatFromInt(numbers.len - 1));
    
    const std_deviation = @sqrt(var_result);
    const result = types.Value{ .decimal = std_deviation };
    
    return try wrapInCollection(context.allocator, result);
}

// variance() - variance (sample)
pub fn variance(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const collection = switch (input) {
        .collection => |coll| coll,
        else => {
            // Single value has variance of 0
            return try wrapInCollection(context.allocator, types.Value{ .decimal = 0.0 });
        }
    };
    
    if (collection.len == 0) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const numbers = try collectNumericValues(collection, context.allocator);
    defer context.allocator.free(numbers);
    
    if (numbers.len <= 1) {
        return try wrapInCollection(context.allocator, types.Value{ .decimal = 0.0 });
    }
    
    // Calculate mean
    var total: f64 = 0;
    for (numbers) |num| {
        total += num;
    }
    const mean = total / @as(f64, @floatFromInt(numbers.len));
    
    // Calculate variance (sample variance: divide by n-1)
    var variance_sum: f64 = 0;
    for (numbers) |num| {
        const diff = num - mean;
        variance_sum += diff * diff;
    }
    const variance_result = variance_sum / @as(f64, @floatFromInt(numbers.len - 1));
    
    const result = types.Value{ .decimal = variance_result };
    return try wrapInCollection(context.allocator, result);
}

// aggregate() - generic aggregation function with accumulator
pub fn aggregate(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len < 2 or args.len > 3) return error.InvalidArgumentCount;
    
    // This is a simplified implementation - in full FHIRPath this would evaluate expressions
    // For now, we'll return an error as this requires expression evaluation
    _ = context;
    return error.NotImplemented;
}