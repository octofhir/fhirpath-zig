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

// today() - returns current date
pub fn today(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 0) return error.InvalidArgumentCount;
    
    const timestamp = std.time.timestamp();
    const seconds_per_day = 86400;
    const days_since_epoch = @divFloor(timestamp, seconds_per_day);
    const epoch_date = types.Date{ .year = 1970, .month = 1, .day = 1 };
    
    // Simple date calculation from days since epoch
    // This is a simplified implementation - in production would use proper calendar arithmetic
    var current_date = epoch_date;
    var remaining_days = days_since_epoch;
    
    // Add years (approximate - doesn't handle leap years perfectly)
    const days_per_year = 365;
    const years_to_add = @divFloor(remaining_days, days_per_year);
    current_date.year += @intCast(years_to_add);
    remaining_days -= years_to_add * days_per_year;
    
    // Add months (approximate)
    const days_per_month = 30;
    const months_to_add = @divFloor(remaining_days, days_per_month);
    const current_month = (current_date.month orelse 1) + @as(u8, @intCast(months_to_add));
    current_date.month = current_month;
    remaining_days -= months_to_add * days_per_month;
    
    // Add remaining days
    const current_day = (current_date.day orelse 1) + @as(u8, @intCast(remaining_days));
    current_date.day = current_day;
    
    // Handle month overflow (simplified)
    if (current_date.month.? > 12) {
        current_date.year += @divFloor(current_date.month.? - 1, 12);
        current_date.month = ((current_date.month.? - 1) % 12) + 1;
    }
    
    const result = types.Value{ .date = current_date };
    return try wrapInCollection(context.allocator, result);
}

// now() - returns current date and time
pub fn now(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 0) return error.InvalidArgumentCount;
    
    const timestamp = std.time.timestamp();
    const seconds_per_day = 86400;
    const days_since_epoch = @divFloor(timestamp, seconds_per_day);
    const seconds_today = @mod(timestamp, seconds_per_day);
    
    // Get date part (same logic as today())
    const epoch_date = types.Date{ .year = 1970, .month = 1, .day = 1 };
    var current_date = epoch_date;
    var remaining_days = days_since_epoch;
    
    const days_per_year = 365;
    const years_to_add = @divFloor(remaining_days, days_per_year);
    current_date.year += @intCast(years_to_add);
    remaining_days -= years_to_add * days_per_year;
    
    const days_per_month = 30;
    const months_to_add = @divFloor(remaining_days, days_per_month);
    const current_month_now = (current_date.month orelse 1) + @as(u8, @intCast(months_to_add));
    current_date.month = current_month_now;
    remaining_days -= months_to_add * days_per_month;
    
    const current_day_now = (current_date.day orelse 1) + @as(u8, @intCast(remaining_days));
    current_date.day = current_day_now;
    
    if (current_date.month.? > 12) {
        current_date.year += @divFloor(current_date.month.? - 1, 12);
        current_date.month = ((current_date.month.? - 1) % 12) + 1;
    }
    
    // Get time part
    const hours = @divFloor(seconds_today, 3600);
    const minutes = @divFloor(@mod(seconds_today, 3600), 60);
    const seconds = @mod(seconds_today, 60);
    
    const current_time = types.Time{
        .hour = @intCast(hours),
        .minute = @intCast(minutes),
        .second = @intCast(seconds),
        .millisecond = 0, // Not tracking milliseconds in this simple implementation
    };
    
    const current_datetime = types.DateTime{
        .date = current_date,
        .time = current_time,
        .timezone_offset = null, // Local time, no timezone info
    };
    
    const result = types.Value{ .date_time = current_datetime };
    return try wrapInCollection(context.allocator, result);
}

// timeOfDay() - returns current time
pub fn timeOfDay(context: *EvaluationContext, args: []types.Value) !types.Value {
    if (args.len != 0) return error.InvalidArgumentCount;
    
    const timestamp = std.time.timestamp();
    const seconds_per_day = 86400;
    const seconds_today = @mod(timestamp, seconds_per_day);
    
    const hours = @divFloor(seconds_today, 3600);
    const minutes = @divFloor(@mod(seconds_today, 3600), 60);
    const seconds = @mod(seconds_today, 60);
    
    const current_time = types.Time{
        .hour = @intCast(hours),
        .minute = @intCast(minutes),
        .second = @intCast(seconds),
        .millisecond = 0,
    };
    
    const result = types.Value{ .time = current_time };
    return try wrapInCollection(context.allocator, result);
}