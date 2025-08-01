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

// Get type name for a value
fn getTypeName(value: types.Value) []const u8 {
    return switch (value) {
        .boolean => "Boolean",
        .integer => "Integer", 
        .decimal => "Decimal",
        .string => "String",
        .date => "Date",
        .time => "Time", 
        .date_time => "DateTime",
        .quantity => "Quantity",
        .collection => "Collection",
        .json_object => "Object", // FHIR objects
        .null_value => "Null",
    };
}

// Check if value matches type
fn matchesType(value: types.Value, type_name: []const u8) bool {
    const value_type = getTypeName(value);
    
    // Direct type match
    if (std.mem.eql(u8, value_type, type_name)) {
        return true;
    }
    
    // Handle type hierarchy and aliases
    return switch (value) {
        .integer => std.mem.eql(u8, type_name, "Number") or std.mem.eql(u8, type_name, "Integer"),
        .decimal => std.mem.eql(u8, type_name, "Number") or std.mem.eql(u8, type_name, "Decimal"),
        .date, .time, .date_time => std.mem.eql(u8, type_name, "Temporal"),
        else => false,
    };
}

// is() function - checks if value is of specified type
pub fn isFn(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const type_arg = try extractSingleValue(args[1]);
    
    const type_name = switch (type_arg) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    const result = types.Value{ .boolean = matchesType(input, type_name) };
    return try wrapInCollection(context.allocator, result);
}

// as() function - treats value as specified type if possible
pub fn asFn(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const type_arg = try extractSingleValue(args[1]);
    
    const type_name = switch (type_arg) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    // If the value matches the type, return it; otherwise return empty collection
    if (matchesType(input, type_name)) {
        return try wrapInCollection(context.allocator, input);
    } else {
        return types.Value{ .collection = &[_]types.Value{} };
    }
}

// ofType() function - filters collection to values of specified type
pub fn ofType(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 2) return error.InvalidArgumentCount;
    
    const input = args[0]; // Can be a collection
    const type_arg = try extractSingleValue(args[1]);
    
    const type_name = switch (type_arg) {
        .string => |str| str,
        else => return error.TypeMismatch,
    };
    
    var results = std.ArrayList(types.Value).init(context.allocator);
    defer results.deinit();
    
    switch (input) {
        .collection => |coll| {
            for (coll) |item| {
                if (matchesType(item, type_name)) {
                    try results.append(item);
                }
            }
        },
        else => {
            // Single value - check if it matches
            if (matchesType(input, type_name)) {
                try results.append(input);
            }
        }
    }
    
    return types.Value{ .collection = try results.toOwnedSlice() };
}

// type() function - returns the type name of a value
pub fn typeFn(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = try extractSingleValue(args[0]);
    const type_name = getTypeName(input);
    
    const result = types.Value{ .string = type_name };
    return try wrapInCollection(context.allocator, result);
}