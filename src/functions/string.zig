const std = @import("std");
const types = @import("../types.zig");

// Forward declaration for EvaluationContext
pub const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

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

/// length() - returns the length of a string or collection
pub fn length(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const result = switch (input) {
        .string => |str| types.Value{ .integer = @intCast(str.len) },
        .collection => |coll| {
            // If input is empty collection, return empty collection (FHIRPath has no null)
            if (coll.len == 0) return types.Value{ .collection = &[_]types.Value{} };
            // If collection has items, return the count
            return types.Value{ .integer = @intCast(coll.len) };
        },
        else => return types.Value{ .collection = &[_]types.Value{} }, // Invalid input returns empty collection
    };
    
    return try wrapInCollection(context.allocator, result);
}

/// substring(start, length?) - returns substring from start index
pub fn substring(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len < 2 or args.len > 3) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const start_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const start_index = switch (start_input) {
        .integer => |idx| if (idx < 0) 0 else @as(usize, @intCast(idx)),
        else => return error.TypeMismatch,
    };
    
    if (start_index >= string_val.len) {
        const empty_result = try context.allocator.dupe(u8, "");
        return try wrapInCollection(context.allocator, types.Value{ .string = empty_result });
    }
    
    const end_index = if (args.len == 3) blk: {
        const length_input = try extractSingleValue(args[2]);
        const length_val = switch (length_input) {
            .integer => |len| if (len < 0) 0 else @as(usize, @intCast(len)),
            else => return error.TypeMismatch,
        };
        break :blk @min(start_index + length_val, string_val.len);
    } else string_val.len;
    
    const result_str = try context.allocator.dupe(u8, string_val[start_index..end_index]);
    const result = types.Value{ .string = result_str };
    return try wrapInCollection(context.allocator, result);
}

/// contains(substring) - returns true if string contains substring
pub fn contains(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const substring_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const substring_val = switch (substring_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result = types.Value{ .boolean = std.mem.indexOf(u8, string_val, substring_val) != null };
    return try wrapInCollection(context.allocator, result);
}

/// startsWith(prefix) - returns true if string starts with prefix
pub fn startsWith(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const prefix_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const prefix_val = switch (prefix_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result = types.Value{ .boolean = std.mem.startsWith(u8, string_val, prefix_val) };
    return try wrapInCollection(context.allocator, result);
}

/// endsWith(suffix) - returns true if string ends with suffix
pub fn endsWith(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const suffix_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const suffix_val = switch (suffix_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result = types.Value{ .boolean = std.mem.endsWith(u8, string_val, suffix_val) };
    return try wrapInCollection(context.allocator, result);
}

/// indexOf(substring) - returns index of first occurrence of substring
pub fn indexOf(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const substring_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const substring_val = switch (substring_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result = if (std.mem.indexOf(u8, string_val, substring_val)) |index|
        types.Value{ .integer = @intCast(index) }
    else
        types.Value{ .integer = -1 };
    
    return try wrapInCollection(context.allocator, result);
}

/// upper() - converts string to uppercase
pub fn upper(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result_str = try context.allocator.alloc(u8, string_val.len);
    for (string_val, 0..) |char, i| {
        result_str[i] = std.ascii.toUpper(char);
    }
    
    const result = types.Value{ .string = result_str };
    return try wrapInCollection(context.allocator, result);
}

/// lower() - converts string to lowercase
pub fn lower(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result_str = try context.allocator.alloc(u8, string_val.len);
    for (string_val, 0..) |char, i| {
        result_str[i] = std.ascii.toLower(char);
    }
    
    const result = types.Value{ .string = result_str };
    return try wrapInCollection(context.allocator, result);
}

/// replace(pattern, substitution) - replaces all occurrences of pattern with substitution
pub fn replace(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 3) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const pattern_input = try extractSingleValue(args[1]);
    const substitution_input = try extractSingleValue(args[2]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const pattern_val = switch (pattern_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const substitution_val = switch (substitution_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    // Simple replace implementation - could be optimized
    const result_str = try std.mem.replaceOwned(u8, context.allocator, string_val, pattern_val, substitution_val);
    const result = types.Value{ .string = result_str };
    return try wrapInCollection(context.allocator, result);
}

/// matches(regex) - basic pattern matching (simplified implementation)
pub fn matches(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArguments;
    
    const string_input = try extractSingleValue(args[0]);
    const pattern_input = try extractSingleValue(args[1]);
    
    const string_val = switch (string_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const pattern_val = switch (pattern_input) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    // Very simplified regex matching - just check if pattern is contained
    // In a full implementation, this would use proper regex engine
    const result = types.Value{ .boolean = std.mem.indexOf(u8, string_val, pattern_val) != null };
    return try wrapInCollection(context.allocator, result);
}