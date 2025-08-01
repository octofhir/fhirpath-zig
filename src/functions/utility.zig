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

// trace() - debugging/logging function that outputs values and passes them through
pub fn trace(_: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len < 1 or args.len > 2) return error.InvalidArgumentCount;
    
    const input = args[0];
    const name_arg = if (args.len > 1) args[1] else null;
    
    // Extract trace name if provided
    const trace_name = if (name_arg) |name| blk: {
        const name_val = try extractSingleValue(name);
        break :blk switch (name_val) {
            .string => |str| str,
            else => "trace",
        };
    } else "trace";
    
    // For now, just print to stderr (in a real implementation, this might log to a proper system)
    const stderr = std.io.getStdErr().writer();
    
    // Print trace information
    stderr.print("[{s}] ", .{trace_name}) catch {};
    
    switch (input) {
        .collection => |coll| {
            stderr.print("Collection({d} items): [", .{coll.len}) catch {};
            for (coll, 0..) |item, i| {
                if (i > 0) stderr.print(", ", .{}) catch {};
                printValue(stderr, item) catch {};
                if (i >= 4 and coll.len > 5) { // Limit output for large collections
                    stderr.print(", ... and {d} more", .{coll.len - 5}) catch {};
                    break;
                }
            }
            stderr.print("]\n", .{}) catch {};
        },
        else => {
            printValue(stderr, input) catch {};
            stderr.print("\n", .{}) catch {};
        }
    }
    
    // Return the input unchanged (trace is pass-through)
    return input;
}

// Helper to print a single value
fn printValue(writer: anytype, value: types.Value) !void {
    switch (value) {
        .boolean => |b| try writer.print("{}", .{b}),
        .integer => |i| try writer.print("{d}", .{i}),
        .decimal => |d| try writer.print("{d}", .{d}),
        .string => |s| try writer.print("'{s}'", .{s}),
        .date => |d| try writer.print("@{d}-{d:0>2}-{d:0>2}", .{ d.year, d.month orelse 1, d.day orelse 1 }),
        .time => |t| try writer.print("@T{d:0>2}:{d:0>2}:{d:0>2}", .{ t.hour, t.minute, t.second orelse 0 }),
        .date_time => |dt| {
            try writer.print("@{d}-{d:0>2}-{d:0>2}", .{ dt.date.year, dt.date.month orelse 1, dt.date.day orelse 1 });
            if (dt.time) |t| {
                try writer.print("T{d:0>2}:{d:0>2}:{d:0>2}", .{ t.hour, t.minute, t.second orelse 0 });
            }
        },
        .quantity => |q| {
            try writer.print("{d}", .{q.value});
            if (q.unit) |u| try writer.print(" '{s}'", .{u});
        },
        .json_object => try writer.print("[JSON Object]", .{}),
        .null_value => try writer.print("null", .{}),
        .collection => |coll| try writer.print("[Collection of {d}]", .{coll.len}),
    }
}

// repeat() - repeatedly applies a projection until no new items are found
pub fn repeat(_: *EvaluationContext, _: []types.Value) !types.Value {
    // This is a complex function that requires expression evaluation
    // For now, we'll return a simplified implementation
    // In a full implementation, this would:
    // 1. Take the input collection
    // 2. Apply the projection expression to each item
    // 3. Collect all results
    // 4. Repeat until no new items are found
    // 5. Return the union of all iterations
    
    return error.NotImplemented;
}

// iif() - conditional function (if-then-else)
pub fn iif(_: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 3) return error.InvalidArgumentCount;
    
    const condition_input = try extractSingleValue(args[0]);
    const then_value = args[1];
    const else_value = args[2];
    
    const condition = switch (condition_input) {
        .boolean => |b| b,
        .integer => |i| i != 0,
        .decimal => |d| d != 0.0,
        .string => |s| s.len > 0,
        .collection => |c| c.len > 0,
        .null_value => false,
        else => true,
    };
    
    return if (condition) then_value else else_value;
}

// toBoolean() conversion specifically for collections (different from conversion.zig version)
pub fn toBooleanCollection(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 1) return error.InvalidArgumentCount;
    
    const input = args[0];
    const result = switch (input) {
        .collection => |coll| types.Value{ .boolean = coll.len > 0 },
        .boolean => |b| types.Value{ .boolean = b },
        .integer => |i| types.Value{ .boolean = i != 0 },
        .decimal => |d| types.Value{ .boolean = d != 0.0 },
        .string => |s| types.Value{ .boolean = s.len > 0 },
        .null_value => types.Value{ .boolean = false },
        else => types.Value{ .boolean = true },
    };
    
    return try wrapInCollection(context.allocator, result);
}