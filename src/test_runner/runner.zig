const std = @import("std");
const fhirpath = @import("fhirpath");
const test_loader = @import("test_loader.zig");

pub const TestResult = struct {
    test_name: []const u8,
    expression: []const u8,
    passed: bool,
    error_message: ?[]const u8 = null,
    expected_value: ?[]const u8 = null,
    actual_value: ?[]const u8 = null,
    execution_time_ns: u64 = 0,
    
    pub fn format(self: TestResult, writer: anytype) !void {
        if (self.passed) {
            try writer.print("  ✅ {s}: {s}\n", .{ self.test_name, self.expression });
        } else {
            try writer.print("  ❌ {s}: {s}\n", .{ self.test_name, self.expression });
            if (self.error_message) |msg| {
                try writer.print("     Error: {s}\n", .{msg});
            }
            if (self.expected_value) |expected| {
                try writer.print("     Expected: {s}\n", .{expected});
            }
            if (self.actual_value) |actual| {
                try writer.print("     Actual: {s}\n", .{actual});
            }
        }
    }
    
    pub fn deinit(self: *TestResult, allocator: std.mem.Allocator) void {
        allocator.free(self.test_name);
        allocator.free(self.expression);
        if (self.error_message) |msg| allocator.free(msg);
        if (self.expected_value) |val| allocator.free(val);
        if (self.actual_value) |val| allocator.free(val);
    }
};

pub const SuiteResult = struct {
    suite_name: []const u8,
    total_tests: usize,
    passed: usize,
    failed: usize,
    skipped: usize,
    execution_time_ns: u64,
    test_results: []TestResult,
    
    pub fn passRate(self: SuiteResult) f64 {
        if (self.total_tests == 0) return 0.0;
        return @as(f64, @floatFromInt(self.passed)) / @as(f64, @floatFromInt(self.total_tests)) * 100.0;
    }
    
    pub fn format(self: SuiteResult, writer: anytype) !void {
        try writer.print("\n{s}\n", .{self.suite_name});
        try writer.print("{s:─<60}\n", .{""});
        try writer.print("Total: {any} | Passed: {any} | Failed: {any} | Skipped: {any} | Pass Rate: {d:.1}%\n", .{
            self.total_tests,
            self.passed,
            self.failed,
            self.skipped,
            self.passRate(),
        });
        try writer.print("Execution time: {d:.2}ms\n", .{
            @as(f64, @floatFromInt(self.execution_time_ns)) / 1_000_000.0,
        });
    }
    
    pub fn deinit(self: *SuiteResult, allocator: std.mem.Allocator) void {
        for (self.test_results) |*result| {
            result.deinit(allocator);
        }
        allocator.free(self.test_results);
    }
};

pub const Runner = struct {
    allocator: std.mem.Allocator,
    fp: *fhirpath.FHIRPath,
    timer: std.time.Timer,
    verbose: bool = false,
    
    pub fn init(allocator: std.mem.Allocator) !Runner {
        const fp = try allocator.create(fhirpath.FHIRPath);
        fp.* = fhirpath.FHIRPath.init(allocator);
        
        return .{
            .allocator = allocator,
            .fp = fp,
            .timer = try std.time.Timer.start(),
            .verbose = false,
        };
    }
    
    pub fn deinit(self: *Runner) void {
        self.fp.deinit();
        self.allocator.destroy(self.fp);
    }
    
    /// Run a single test suite
    pub fn runTestSuite(self: *Runner, suite: test_loader.TestSuite, base_path: []const u8) !SuiteResult {
        const start_time = self.timer.read();
        
        var results = try self.allocator.alloc(TestResult, suite.tests.len);
        var passed: usize = 0;
        var failed: usize = 0;
        var skipped: usize = 0;
        
        for (suite.tests, 0..) |test_case, i| {
            results[i] = self.runTestCase(test_case, base_path) catch |err| blk: {
                std.log.err("Test runner error for {s}: {any}", .{ test_case.name, err });
                skipped += 1;
                break :blk TestResult{
                    .test_name = try self.allocator.dupe(u8, test_case.name),
                    .expression = try self.allocator.dupe(u8, test_case.expression),
                    .passed = false,
                    .error_message = try self.allocator.dupe(u8, "Test runner error"),
                };
            };
            
            if (results[i].passed) {
                passed += 1;
            } else {
                failed += 1;
            }
            
            if (self.verbose) {
                try results[i].format(std.io.getStdErr().writer());
            }
        }
        
        const end_time = self.timer.read();
        
        return SuiteResult{
            .suite_name = suite.name,
            .total_tests = suite.tests.len,
            .passed = passed,
            .failed = failed,
            .skipped = skipped,
            .execution_time_ns = end_time - start_time,
            .test_results = results,
        };
    }
    
    /// Run a single test case
    fn runTestCase(self: *Runner, test_case: test_loader.TestCase, base_path: []const u8) !TestResult {
        const start_time = self.timer.read();
        
        // Create evaluation context
        var eval_context = fhirpath.evaluator.EvaluationContext.init(self.allocator);
        defer eval_context.deinit();
        
        // Load input data if specified
        if (test_case.inputfile) |filename| {
            const input_data = try test_loader.loadTestInput(self.allocator, base_path, filename);
            eval_context.setResource(input_data);
            // TODO: Fix JSON value cleanup - currently causes double-free
        } else if (test_case.input) |input| {
            eval_context.setResource(input); // Use the pre-parsed input directly
        }
        
        // Evaluate expression
        const result = self.fp.evaluateString(test_case.expression, &eval_context) catch |err| {
            if (test_case.shouldError()) {
                // Expected error
                return TestResult{
                    .test_name = try self.allocator.dupe(u8, test_case.name),
                    .expression = try self.allocator.dupe(u8, test_case.expression),
                    .passed = true,
                    .execution_time_ns = self.timer.read() - start_time,
                };
            }
            
            // Unexpected error
            const error_msg = try std.fmt.allocPrint(self.allocator, "{any}", .{err});
            return TestResult{
                .test_name = try self.allocator.dupe(u8, test_case.name),
                .expression = try self.allocator.dupe(u8, test_case.expression),
                .passed = false,
                .error_message = error_msg,
                .execution_time_ns = self.timer.read() - start_time,
            };
        };
        defer result.deinit(self.allocator); // Clean up evaluation result
        
        // Check if we expected an error but didn't get one
        if (test_case.shouldError()) {
            const actual_str = try valueToString(self.allocator, result);
            return TestResult{
                .test_name = try self.allocator.dupe(u8, test_case.name),
                .expression = try self.allocator.dupe(u8, test_case.expression),
                .passed = false,
                .error_message = try self.allocator.dupe(u8, "Expected error but got result"),
                .actual_value = actual_str,
                .execution_time_ns = self.timer.read() - start_time,
            };
        }
        
        // Compare result with expected
        const matches = try compareValues(result, test_case.expected);
        
        const execution_time = self.timer.read() - start_time;
        
        if (matches) {
            return TestResult{
                .test_name = try self.allocator.dupe(u8, test_case.name),
                .expression = try self.allocator.dupe(u8, test_case.expression),
                .passed = true,
                .execution_time_ns = execution_time,
            };
        } else {
            const expected_str = try jsonValueToString(self.allocator, test_case.expected);
            const actual_str = try valueToString(self.allocator, result);
            
            return TestResult{
                .test_name = try self.allocator.dupe(u8, test_case.name),
                .expression = try self.allocator.dupe(u8, test_case.expression),
                .passed = false,
                .expected_value = expected_str,
                .actual_value = actual_str,
                .execution_time_ns = execution_time,
            };
        }
    }
};

/// Compare FHIRPath value with expected JSON value
fn compareValues(actual: fhirpath.types.Value, expected: std.json.Value) !bool {
    switch (expected) {
        .null => return actual == .null_value,
        .bool => |b| return actual == .boolean and actual.boolean == b,
        .integer => |i| return actual == .integer and actual.integer == i,
        .float => |f| return actual == .decimal and actual.decimal == f,
        .string => |s| return actual == .string and std.mem.eql(u8, actual.string, s),
        .array => |arr| {
            if (actual != .collection) return false;
            if (actual.collection.len != arr.items.len) return false;
            
            for (actual.collection, arr.items) |actual_item, expected_item| {
                if (!try compareValues(actual_item, expected_item)) return false;
            }
            return true;
        },
        else => return false,
    }
}

/// Convert FHIRPath value to string for display
fn valueToString(allocator: std.mem.Allocator, value: fhirpath.types.Value) ![]const u8 {
    switch (value) {
        .null_value => return try allocator.dupe(u8, "null"),
        .boolean => |b| return try std.fmt.allocPrint(allocator, "{}", .{b}),
        .integer => |i| return try std.fmt.allocPrint(allocator, "{}", .{i}),
        .decimal => |d| return try std.fmt.allocPrint(allocator, "{d}", .{d}),
        .string => |s| return try std.fmt.allocPrint(allocator, "'{s}'", .{s}),
        .date => |d| return try std.fmt.allocPrint(allocator, "@{}-{?:0>2}-{?:0>2}", .{ d.year, d.month, d.day }),
        .time => |t| return try std.fmt.allocPrint(allocator, "@T{:0>2}:{:0>2}:{?:0>2}", .{ t.hour, t.minute, t.second }),
        .date_time => |dt| {  
            if (dt.time) |t| {
                return try std.fmt.allocPrint(allocator, "@{}-{?:0>2}-{?:0>2}T{:0>2}:{:0>2}:{?:0>2}", .{
                    dt.date.year, dt.date.month, dt.date.day, t.hour, t.minute, t.second,
                });
            } else {
                return try std.fmt.allocPrint(allocator, "@{}-{?:0>2}-{?:0>2}", .{ dt.date.year, dt.date.month, dt.date.day });
            }
        },
        .quantity => |q| return try std.fmt.allocPrint(allocator, "{d} '{?s}'", .{ q.value, q.unit }),
        .collection => |c| {
            if (c.len == 0) return try allocator.dupe(u8, "[]");
            if (c.len == 1) return valueToString(allocator, c[0]);
            
            var result = std.ArrayList(u8).init(allocator);
            try result.append('[');
            for (c, 0..) |item, i| {
                if (i > 0) try result.appendSlice(", ");
                const item_str = try valueToString(allocator, item);
                defer allocator.free(item_str);
                try result.appendSlice(item_str);
            }
            try result.append(']');
            return try result.toOwnedSlice();
        },
        .json_object => return try allocator.dupe(u8, "[JSON Object]"),
    }
}

/// Convert JSON value to string for display
fn jsonValueToString(allocator: std.mem.Allocator, value: std.json.Value) ![]const u8 {
    switch (value) {
        .null => return try allocator.dupe(u8, "null"),
        .bool => |b| return try std.fmt.allocPrint(allocator, "{}", .{b}),
        .integer => |i| return try std.fmt.allocPrint(allocator, "{}", .{i}),
        .float => |f| return try std.fmt.allocPrint(allocator, "{d}", .{f}),
        .string => |s| return try std.fmt.allocPrint(allocator, "'{s}'", .{s}),
        .array => |arr| {
            if (arr.items.len == 0) return try allocator.dupe(u8, "[]");
            
            var result = std.ArrayList(u8).init(allocator);
            try result.append('[');
            for (arr.items, 0..) |item, i| {
                if (i > 0) try result.appendSlice(", ");
                const item_str = try jsonValueToString(allocator, item);
                defer allocator.free(item_str);
                try result.appendSlice(item_str);
            }
            try result.append(']');
            return try result.toOwnedSlice();
        },
        else => return try allocator.dupe(u8, "<complex>"),
    }
}