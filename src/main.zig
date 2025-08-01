const std = @import("std");
const fhirpath = @import("fhirpath");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <expression> [context.json]\n", .{args[0]});
        return;
    }

    const expression = args[1];

    var fp = fhirpath.FHIRPath.init(allocator);
    defer fp.deinit();

    std.debug.print("Expression: {s}\n", .{expression});

    // Evaluate the expression
    const result = fp.evaluateSimple(expression) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    defer result.deinit(allocator);

    // Print the result
    switch (result) {
        .boolean => |val| std.debug.print("Result: {}\n", .{val}),
        .integer => |val| std.debug.print("Result: {}\n", .{val}),
        .decimal => |val| std.debug.print("Result: {d}\n", .{val}),
        .string => |val| std.debug.print("Result: \"{s}\"\n", .{val}),
        .date => |val| {
            std.debug.print("Result: @{d}", .{val.year});
            if (val.month) |m| {
                std.debug.print("-{d:0>2}", .{m});
                if (val.day) |d| {
                    std.debug.print("-{d:0>2}", .{d});
                }
            }
            std.debug.print("\n", .{});
        },
        .time => |val| {
            std.debug.print("Result: @T{d:0>2}:{d:0>2}", .{ val.hour, val.minute });
            if (val.second) |s| {
                std.debug.print(":{d:0>2}", .{s});
                if (val.millisecond) |ms| {
                    std.debug.print(".{d:0>3}", .{ms});
                }
            }
            std.debug.print("\n", .{});
        },
        .date_time => |val| {
            std.debug.print("Result: @{d}", .{val.date.year});
            if (val.date.month) |m| {
                std.debug.print("-{d:0>2}", .{m});
                if (val.date.day) |d| {
                    std.debug.print("-{d:0>2}", .{d});
                }
            }
            if (val.time) |t| {
                std.debug.print("T{d:0>2}:{d:0>2}", .{ t.hour, t.minute });
                if (t.second) |s| {
                    std.debug.print(":{d:0>2}", .{s});
                    if (t.millisecond) |ms| {
                        std.debug.print(".{d:0>3}", .{ms});
                    }
                }
            }
            std.debug.print("\n", .{});
        },
        .quantity => |val| {
            std.debug.print("Result: ", .{});
            if (val.value == @floor(val.value)) {
                std.debug.print("{d}", .{@as(i64, @intFromFloat(val.value))});
            } else {
                std.debug.print("{d}", .{val.value});
            }
            if (val.unit) |u| {
                std.debug.print(" '{s}'", .{u});
            }
            std.debug.print("\n", .{});
        },
        .null_value => std.debug.print("Result: null\n", .{}),
        .json_object => std.debug.print("Result: [JSON Object]\n", .{}),
        .collection => |val| {
            std.debug.print("Result: [", .{});
            for (val, 0..) |item, i| {
                if (i > 0) std.debug.print(", ", .{});
                switch (item) {
                    .boolean => |v| std.debug.print("{}", .{v}),
                    .integer => |v| std.debug.print("{}", .{v}),
                    .decimal => |v| std.debug.print("{d}", .{v}),
                    .string => |v| std.debug.print("\"{s}\"", .{v}),
                    .date => |v| {
                        std.debug.print("@{d}", .{v.year});
                        if (v.month) |m| std.debug.print("-{d:0>2}", .{m});
                        if (v.day) |d| std.debug.print("-{d:0>2}", .{d});
                    },
                    .time => |v| {
                        std.debug.print("@T{d:0>2}:{d:0>2}", .{ v.hour, v.minute });
                        if (v.second) |s| std.debug.print(":{d:0>2}", .{s});
                    },
                    .date_time => |v| {
                        std.debug.print("@{d}", .{v.date.year});
                        if (v.date.month) |m| std.debug.print("-{d:0>2}", .{m});
                        if (v.date.day) |d| std.debug.print("-{d:0>2}", .{d});
                        if (v.time) |t| std.debug.print("T{d:0>2}:{d:0>2}", .{ t.hour, t.minute });
                    },
                    .quantity => |v| {
                        if (v.value == @floor(v.value)) {
                            std.debug.print("{d}", .{@as(i64, @intFromFloat(v.value))});
                        } else {
                            std.debug.print("{d}", .{v.value});
                        }
                        if (v.unit) |u| std.debug.print(" '{s}'", .{u});
                    },
                    .null_value => std.debug.print("null", .{}),
                    .json_object => std.debug.print("[JSON Object]", .{}),
                    .collection => std.debug.print("[Nested Collection]", .{}),
                }
            }
            std.debug.print("]\n", .{});
        },
    }

    // TODO: Parse context JSON if provided
}
