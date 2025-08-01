const std = @import("std");

// FHIR date/time types
pub const Date = struct {
    year: i32,
    month: ?u8 = null,    // 1-12
    day: ?u8 = null,      // 1-31
    
    pub fn format(self: Date, writer: anytype) !void {
        try writer.print("{d}", .{self.year});
        if (self.month) |m| {
            try writer.print("-{d:0>2}", .{m});
            if (self.day) |d| {
                try writer.print("-{d:0>2}", .{d});
            }
        }
    }
};

pub const Time = struct {
    hour: u8,      // 0-23
    minute: u8,    // 0-59
    second: ?u8 = null,    // 0-59
    millisecond: ?u16 = null, // 0-999
    
    pub fn format(self: Time, writer: anytype) !void {
        try writer.print("{d:0>2}:{d:0>2}", .{ self.hour, self.minute });
        if (self.second) |s| {
            try writer.print(":{d:0>2}", .{s});
            if (self.millisecond) |ms| {
                try writer.print(".{d:0>3}", .{ms});
            }
        }
    }
};

pub const DateTime = struct {
    date: Date,
    time: ?Time = null,
    timezone_offset: ?i16 = null, // minutes from UTC
    
    pub fn format(self: DateTime, writer: anytype) !void {
        try self.date.format(writer);
        if (self.time) |t| {
            try writer.print("T");
            try t.format(writer);
            if (self.timezone_offset) |offset| {
                if (offset == 0) {
                    try writer.print("Z");
                } else {
                    const sign: u8 = if (offset < 0) '-' else '+';
                    const abs_offset = @abs(offset);
                    const hours = abs_offset / 60;
                    const minutes = abs_offset % 60;
                    try writer.print("{c}{d:0>2}:{d:0>2}", .{ sign, hours, minutes });
                }
            }
        }
    }
};

pub const Quantity = struct {
    value: f64,
    unit: ?[]const u8 = null,
    
    pub fn format(self: Quantity, writer: anytype) !void {
        // Handle integer-like values without decimal point
        if (self.value == @floor(self.value)) {
            try writer.print("{d}", .{@as(i64, @intFromFloat(self.value))});
        } else {
            try writer.print("{d}", .{self.value});
        }
        
        if (self.unit) |u| {
            try writer.print(" '{s}'", .{u});
        }
    }
    
    pub fn init(value: f64, unit: ?[]const u8) Quantity {
        return Quantity{
            .value = value,
            .unit = unit,
        };
    }
};

// FHIRPath value types
pub const Value = union(enum) {
    boolean: bool,
    integer: i64,
    decimal: f64,
    string: []const u8,
    date: Date,
    time: Time,
    date_time: DateTime,
    quantity: Quantity,
    collection: []Value,
    json_object: std.json.Value, // For preserving JSON objects that can be navigated
    null_value,
    
    pub fn init(value: anytype) Value {
        const T = @TypeOf(value);
        return switch (T) {
            bool => Value{ .boolean = value },
            i64, i32, i16, i8 => Value{ .integer = @as(i64, value) },
            f64, f32 => Value{ .decimal = @as(f64, value) },
            else => @panic("Unsupported value type"),
        };
    }
    
    /// Free any allocated memory within a Value
    pub fn deinit(self: Value, allocator: std.mem.Allocator) void {
        switch (self) {
            .collection => |coll| {
                // Recursively free any nested collections
                for (coll) |item| {
                    item.deinit(allocator);
                }
                allocator.free(coll);
            },
            // Other types don't own their memory (strings are slices, not owned)
            else => {},
        }
    }
};

// Placeholder tests
test "value types" {
    const bool_val = Value.init(true);
    try std.testing.expectEqual(true, bool_val.boolean);
    
    const int_val = Value.init(@as(i64, 42));
    try std.testing.expectEqual(@as(i64, 42), int_val.integer);
    
    const dec_val = Value.init(@as(f64, 3.14));
    try std.testing.expectEqual(@as(f64, 3.14), dec_val.decimal);
}