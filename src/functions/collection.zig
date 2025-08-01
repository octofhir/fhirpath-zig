const std = @import("std");
const types = @import("../types.zig");

// Forward declaration for EvaluationContext
pub const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

// Helper functions
fn equalValues(left: types.Value, right: types.Value) bool {
    return switch (left) {
        .boolean => |l_val| switch (right) {
            .boolean => |r_val| l_val == r_val,
            else => false,
        },
        .integer => |l_val| switch (right) {
            .integer => |r_val| l_val == r_val,
            .decimal => |r_val| @as(f64, @floatFromInt(l_val)) == r_val,
            else => false,
        },
        .decimal => |l_val| switch (right) {
            .integer => |r_val| l_val == @as(f64, @floatFromInt(r_val)),
            .decimal => |r_val| l_val == r_val,
            else => false,
        },
        .string => |l_val| switch (right) {
            .string => |r_val| std.mem.eql(u8, l_val, r_val),
            else => false,
        },
        .date => |l_val| switch (right) {
            .date => |r_val| l_val.year == r_val.year and l_val.month == r_val.month and l_val.day == r_val.day,
            else => false,
        },
        .time => |l_val| switch (right) {
            .time => |r_val| l_val.hour == r_val.hour and l_val.minute == r_val.minute and l_val.second == r_val.second and l_val.millisecond == r_val.millisecond,
            else => false,
        },
        .date_time => |l_val| switch (right) {
            .date_time => |r_val| {
                const dates_equal = l_val.date.year == r_val.date.year and
                    l_val.date.month == r_val.date.month and
                    l_val.date.day == r_val.date.day;
                const times_equal = if (l_val.time != null and r_val.time != null)
                    l_val.time.?.hour == r_val.time.?.hour and
                        l_val.time.?.minute == r_val.time.?.minute and
                        l_val.time.?.second == r_val.time.?.second and
                        l_val.time.?.millisecond == r_val.time.?.millisecond
                else
                    l_val.time == null and r_val.time == null;
                return dates_equal and times_equal;
            },
            else => false,
        },
        .quantity => |l_val| switch (right) {
            .quantity => |r_val| {
                // For basic comparison, values and units must match exactly
                const values_equal = l_val.value == r_val.value;
                const units_equal = if (l_val.unit == null and r_val.unit == null)
                    true
                else if (l_val.unit != null and r_val.unit != null)
                    std.mem.eql(u8, l_val.unit.?, r_val.unit.?)
                else
                    false;
                return values_equal and units_equal;
            },
            else => false,
        },
        .null_value => switch (right) {
            .null_value => true,
            else => false,
        },
        .collection => |l_coll| switch (right) {
            .collection => |r_coll| {
                if (l_coll.len != r_coll.len) return false;
                for (l_coll, r_coll) |l_item, r_item| {
                    if (!equalValues(l_item, r_item)) return false;
                }
                return true;
            },
            else => false,
        },
        .json_object => false, // JSON objects are not directly comparable
    };
}

// Collection function implementations

/// empty() - returns true if collection is empty
pub fn empty(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len == 0) return types.Value{ .boolean = true };
    
    const arg = args[0];
    return types.Value{ .boolean = switch (arg) {
        .collection => |coll| coll.len == 0,
        .string => |str| str.len == 0,
        .null_value => true,
        else => false,
    }};
}

/// exists() - returns true if collection has items
pub fn exists(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len == 0) return types.Value{ .boolean = false };
    
    const arg = args[0];
    return types.Value{ .boolean = switch (arg) {
        .collection => |coll| coll.len > 0,
        .string => |str| str.len > 0,
        .null_value => false,
        else => true,
    }};
}

/// count() - returns the number of items in collection
pub fn count(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len == 0) return types.Value{ .integer = 0 };
    
    const arg = args[0];
    return types.Value{ .integer = switch (arg) {
        .collection => |coll| @intCast(coll.len),
        .null_value => 0,
        else => 1,
    }};
}

/// first() - returns the first item in collection
pub fn first(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len == 0) return types.Value{ .collection = &[_]types.Value{} };
    
    const arg = args[0];
    return switch (arg) {
        .collection => |coll| if (coll.len > 0) {
            const result = try context.allocator.alloc(types.Value, 1);
            result[0] = coll[0];
            return types.Value{ .collection = result };
        } else types.Value{ .collection = &[_]types.Value{} },
        else => {
            // Single value - wrap in collection
            const result = try context.allocator.alloc(types.Value, 1);
            result[0] = arg;
            return types.Value{ .collection = result };
        },
    };
}

/// last() - returns the last item in collection
pub fn last(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len == 0) return types.Value{ .collection = &[_]types.Value{} };
    
    const arg = args[0];
    return switch (arg) {
        .collection => |coll| if (coll.len > 0) {
            const result = try context.allocator.alloc(types.Value, 1);
            result[0] = coll[coll.len - 1];
            return types.Value{ .collection = result };
        } else types.Value{ .collection = &[_]types.Value{} },
        else => {
            // Single value - wrap in collection
            const result = try context.allocator.alloc(types.Value, 1);
            result[0] = arg;
            return types.Value{ .collection = result };
        },
    };
}

/// single() - returns the item if collection has exactly one item
pub fn single(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len == 0) return types.Value{ .collection = &[_]types.Value{} };
    
    const arg = args[0];
    return switch (arg) {
        .collection => |coll| {
            if (coll.len == 1) {
                const result = try context.allocator.alloc(types.Value, 1);
                result[0] = coll[0];
                return types.Value{ .collection = result };
            }
            if (coll.len == 0) return types.Value{ .collection = &[_]types.Value{} };
            return error.InvalidOperation; // More than one item
        },
        else => {
            // Single value - wrap in collection
            const result = try context.allocator.alloc(types.Value, 1);
            result[0] = arg;
            return types.Value{ .collection = result };
        },
    };
}

/// distinct() - returns collection with duplicates removed
pub fn distinct(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len == 0) return types.Value{ .collection = &[_]types.Value{} };
    
    const arg = args[0];
    const collection = switch (arg) {
        .collection => |coll| coll,
        else => return arg, // Single item is already distinct
    };
    
    // For now, simple implementation - could be optimized with hash sets
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    for (collection) |item| {
        var found = false;
        for (result.items) |existing| {
            if (equalValues(item, existing)) {
                found = true;
                break;
            }
        }
        if (!found) {
            try result.append(item);
        }
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// where(criteria) - filters collection based on criteria expression
pub fn where(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const collection_arg = args[0];
    const criteria_value = args[1];
    
    // For now, treat criteria as a boolean value
    // In full implementation, this would be an expression to evaluate for each item
    const include_all = switch (criteria_value) {
        .boolean => |b| b,
        else => return error.TypeMismatch, // TODO: Support expression evaluation per item
    };
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Handle different collection types
    switch (collection_arg) {
        .collection => |coll| {
            if (include_all) {
                try result.appendSlice(coll);
            }
        },
        .null_value => {
            // Empty collection - nothing to filter
        },
        else => {
            // Single item - apply filter to it
            if (include_all) {
                try result.append(collection_arg);
            }
        },
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// select(projection) - transforms each item in collection using projection expression
pub fn select(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const collection_arg = args[0];
    const projection_value = args[1];
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Handle different collection types
    switch (collection_arg) {
        .collection => |coll| {
            // For now, simple projection - just return the projection value for each item
            // In full implementation, this would evaluate the projection expression for each item
            for (coll) |_| {
                try result.append(projection_value);
            }
        },
        .null_value => {
            // Empty collection - nothing to transform
        },
        else => {
            // Single item - apply projection to it
            try result.append(projection_value);
        },
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// tail() - returns all items except the first
pub fn tail(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len == 0) return types.Value{ .collection = &[_]types.Value{} };
    
    const arg = args[0];
    const collection = switch (arg) {
        .collection => |coll| coll,
        else => return types.Value{ .collection = &[_]types.Value{} }, // Single item has no tail
    };
    
    if (collection.len <= 1) {
        return types.Value{ .collection = &[_]types.Value{} };
    }
    
    const tail_slice = try context.allocator.dupe(types.Value, collection[1..]);
    return types.Value{ .collection = tail_slice };
}

/// skip(count) - skips the first 'count' items
pub fn skip(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const collection_arg = args[0];
    const count_arg = args[1];
    
    const skip_count = switch (count_arg) {
        .integer => |n| if (n < 0) 0 else @as(usize, @intCast(n)),
        else => return error.TypeMismatch,
    };
    
    switch (collection_arg) {
        .collection => |coll| {
            if (skip_count >= coll.len) {
                return types.Value{ .collection = &[_]types.Value{} };
            }
            const result_slice = try context.allocator.dupe(types.Value, coll[skip_count..]);
            return types.Value{ .collection = result_slice };
        },
        .null_value => {
            return types.Value{ .collection = &[_]types.Value{} };
        },
        else => {
            // Single item - skip it if count > 0
            if (skip_count > 0) {
                return types.Value{ .collection = &[_]types.Value{} };
            } else {
                var result = try context.allocator.alloc(types.Value, 1);
                result[0] = collection_arg;
                return types.Value{ .collection = result };
            }
        },
    }
}

/// take(count) - takes the first 'count' items
pub fn take(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const collection_arg = args[0];
    const count_arg = args[1];
    
    const take_count = switch (count_arg) {
        .integer => |n| if (n < 0) 0 else @as(usize, @intCast(n)),
        else => return error.TypeMismatch,
    };
    
    switch (collection_arg) {
        .collection => |coll| {
            const actual_count = @min(take_count, coll.len);
            const result_slice = try context.allocator.dupe(types.Value, coll[0..actual_count]);
            return types.Value{ .collection = result_slice };
        },
        .null_value => {
            return types.Value{ .collection = &[_]types.Value{} };
        },
        else => {
            // Single item - take it if count > 0
            if (take_count > 0) {
                var result = try context.allocator.alloc(types.Value, 1);
                result[0] = collection_arg;
                return types.Value{ .collection = result };
            } else {
                return types.Value{ .collection = &[_]types.Value{} };
            }
        },
    }
}

/// union(other) - combines two collections removing duplicates
pub fn unionFn(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const left_arg = args[0];
    const right_arg = args[1];
    
    // Get left collection
    var left_single_storage: [1]types.Value = undefined;
    const left_collection = switch (left_arg) {
        .collection => |coll| coll,
        .null_value => &[_]types.Value{},
        else => blk: {
            left_single_storage[0] = left_arg;
            break :blk left_single_storage[0..1];
        },
    };
    
    // Get right collection
    var right_single_storage: [1]types.Value = undefined;  
    const right_collection = switch (right_arg) {
        .collection => |coll| coll,
        .null_value => &[_]types.Value{},
        else => blk: {
            right_single_storage[0] = right_arg;
            break :blk right_single_storage[0..1];
        },
    };
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Add all items from left collection
    try result.appendSlice(left_collection);
    
    // Add items from right collection that aren't already present
    for (right_collection) |right_item| {
        var found = false;
        for (result.items) |existing| {
            if (equalValues(right_item, existing)) {
                found = true;
                break;
            }
        }
        if (!found) {
            try result.append(right_item);
        }
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// intersect(other) - returns items that appear in both collections
pub fn intersect(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const left_arg = args[0];
    const right_arg = args[1];
    
    // Get left collection
    var left_single_storage: [1]types.Value = undefined;
    const left_collection = switch (left_arg) {
        .collection => |coll| coll,
        .null_value => return types.Value{ .collection = &[_]types.Value{} },
        else => blk: {
            left_single_storage[0] = left_arg;
            break :blk left_single_storage[0..1];
        },
    };
    
    // Get right collection
    var right_single_storage: [1]types.Value = undefined;
    const right_collection = switch (right_arg) {
        .collection => |coll| coll,
        .null_value => return types.Value{ .collection = &[_]types.Value{} },
        else => blk: {
            right_single_storage[0] = right_arg;
            break :blk right_single_storage[0..1];
        },
    };
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Find items that exist in both collections
    for (left_collection) |left_item| {
        var found_in_right = false;
        for (right_collection) |right_item| {
            if (equalValues(left_item, right_item)) {
                found_in_right = true;
                break;
            }
        }
        
        if (found_in_right) {
            // Check if we already added this item to avoid duplicates
            var found_in_result = false;
            for (result.items) |existing| {
                if (equalValues(left_item, existing)) {
                    found_in_result = true;
                    break;
                }
            }
            if (!found_in_result) {
                try result.append(left_item);
            }
        }
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// exclude(other) - returns items from left collection that are not in right collection
pub fn exclude(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const left_arg = args[0];
    const right_arg = args[1];
    
    // Get left collection
    var left_single_storage: [1]types.Value = undefined;
    const left_collection = switch (left_arg) {
        .collection => |coll| coll,
        .null_value => return types.Value{ .collection = &[_]types.Value{} },
        else => blk: {
            left_single_storage[0] = left_arg;
            break :blk left_single_storage[0..1];
        },
    };
    
    // Get right collection
    var right_single_storage: [1]types.Value = undefined;  
    const right_collection = switch (right_arg) {
        .collection => |coll| coll,
        .null_value => {
            // If right is empty, return all of left
            const result_slice = try context.allocator.dupe(types.Value, left_collection);
            return types.Value{ .collection = result_slice };
        },
        else => blk: {
            right_single_storage[0] = right_arg;
            break :blk right_single_storage[0..1];
        },
    };
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Add items from left that are not in right
    for (left_collection) |left_item| {
        var found_in_right = false;
        for (right_collection) |right_item| {
            if (equalValues(left_item, right_item)) {
                found_in_right = true;
                break;
            }
        }
        
        if (!found_in_right) {
            try result.append(left_item);
        }
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}

/// isDistinct() - returns true if all items in collection are distinct
pub fn isDistinct(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len == 0) return types.Value{ .boolean = true };
    
    const arg = args[0];
    const collection = switch (arg) {
        .collection => |coll| coll,
        .null_value => return types.Value{ .boolean = true }, // Empty collection is distinct
        else => return types.Value{ .boolean = true }, // Single item is always distinct
    };
    
    // Check for duplicates
    for (collection, 0..) |item, i| {
        for (collection[i+1..]) |other_item| {
            if (equalValues(item, other_item)) {
                return types.Value{ .boolean = false };
            }
        }
    }
    
    return types.Value{ .boolean = true };
}

/// combine(other) - combines two collections preserving duplicates
pub fn combine(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const left_arg = args[0];
    const right_arg = args[1];
    
    // Get left collection
    var left_single_storage: [1]types.Value = undefined;
    const left_collection = switch (left_arg) {
        .collection => |coll| coll,
        .null_value => &[_]types.Value{},
        else => blk: {
            left_single_storage[0] = left_arg;
            break :blk left_single_storage[0..1];
        },
    };
    
    // Get right collection
    var right_single_storage: [1]types.Value = undefined;  
    const right_collection = switch (right_arg) {
        .collection => |coll| coll,
        .null_value => &[_]types.Value{},
        else => blk: {
            right_single_storage[0] = right_arg;
            break :blk right_single_storage[0..1];
        },
    };
    
    // Combine both collections
    const total_len = left_collection.len + right_collection.len;
    const result_slice = try context.allocator.alloc(types.Value, total_len);
    
    // Copy left collection
    @memcpy(result_slice[0..left_collection.len], left_collection);
    // Copy right collection
    @memcpy(result_slice[left_collection.len..], right_collection);
    
    return types.Value{ .collection = result_slice };
}

/// subsetOf(other) - returns true if this collection is a subset of other
pub fn subsetOf(context: *EvaluationContext, args: []types.Value) !types.Value {
    _ = context;
    if (args.len != 2) return error.InvalidArguments;
    
    const left_arg = args[0];
    const right_arg = args[1];
    
    // Get left collection (this collection)
    var left_single_storage: [1]types.Value = undefined;
    const left_collection = switch (left_arg) {
        .collection => |coll| coll,
        .null_value => &[_]types.Value{}, // Empty collection is subset of any collection
        else => blk: {
            left_single_storage[0] = left_arg;
            break :blk left_single_storage[0..1];
        },
    };
    
    // Get right collection (other collection)
    var right_single_storage: [1]types.Value = undefined;
    const right_collection = switch (right_arg) {
        .collection => |coll| coll,
        .null_value => {
            // Only empty collection is subset of empty collection
            return types.Value{ .boolean = left_collection.len == 0 };
        },
        else => blk: {
            right_single_storage[0] = right_arg;
            break :blk right_single_storage[0..1];
        },
    };
    
    // Check if every item in left exists in right
    for (left_collection) |left_item| {
        var found = false;
        for (right_collection) |right_item| {
            if (equalValues(left_item, right_item)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return types.Value{ .boolean = false };
        }
    }
    
    return types.Value{ .boolean = true };
}

/// supersetOf(other) - returns true if this collection is a superset of other
pub fn supersetOf(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    // Superset is the inverse of subset - swap the arguments
    var swapped_args = [_]types.Value{ args[1], args[0] };
    return try subsetOf(context, swapped_args[0..]);
}

/// distinctBy(expression) - returns distinct items based on projection expression
pub fn distinctBy(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    // This function requires expression evaluation to apply the projection
    // For now, we'll return a simplified implementation that treats the second
    // argument as a property name string and does basic property-based distinctness
    
    const collection_arg = args[0];
    const projection_arg = args[1];
    
    // Get collection
    var single_storage: [1]types.Value = undefined;
    const collection = switch (collection_arg) {
        .collection => |coll| coll,
        .null_value => return types.Value{ .collection = &[_]types.Value{} },
        else => blk: {
            single_storage[0] = collection_arg;
            break :blk single_storage[0..1];
        },
    };
    
    // For this simplified implementation, we'll just return the distinct items
    // without applying the projection expression
    // In a full implementation, this would:
    // 1. Apply the projection expression to each item
    // 2. Keep track of seen projection values
    // 3. Only include items with unique projection values
    
    _ = projection_arg; // Not used in simplified implementation
    
    var result = std.ArrayList(types.Value).init(context.allocator);
    defer result.deinit();
    
    // Simple distinct implementation (same as distinct() function)
    for (collection) |item| {
        var found = false;
        for (result.items) |existing| {
            if (equalValues(item, existing)) {
                found = true;
                break;
            }
        }
        if (!found) {
            try result.append(item);
        }
    }
    
    return types.Value{ .collection = try result.toOwnedSlice() };
}