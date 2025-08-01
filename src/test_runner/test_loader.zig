const std = @import("std");

/// Official FHIRPath test suite format
pub const TestSuite = struct {
    name: []const u8,
    description: ?[]const u8 = null,
    source: ?[]const u8 = null,
    tests: []TestCase,
};

pub const TestCase = struct {
    name: []const u8,
    expression: []const u8,
    input: ?std.json.Value = null,
    inputfile: ?[]const u8 = null,
    tags: ?[]const []const u8 = null,
    expected: std.json.Value,
    should_error: ?bool = null,
    
    pub fn shouldError(self: *const TestCase) bool {
        return self.should_error orelse false;
    }
};

/// Load a test suite from JSON file
pub fn loadTestSuite(allocator: std.mem.Allocator, path: []const u8) !TestSuite {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    
    const content = try file.readToEndAlloc(allocator, 1024 * 1024); // 1MB max
    defer allocator.free(content);
    
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, content, .{});
    defer parsed.deinit();
    
    return parseTestSuite(allocator, parsed.value);
}

/// Parse test suite from JSON value
fn parseTestSuite(allocator: std.mem.Allocator, value: std.json.Value) !TestSuite {
    const obj = value.object;
    
    const name = try allocator.dupe(u8, obj.get("name").?.string);
    const description = if (obj.get("description")) |desc|
        try allocator.dupe(u8, desc.string)
    else
        null;
    const source = if (obj.get("source")) |src|
        try allocator.dupe(u8, src.string)
    else
        null;
    
    const tests_array = obj.get("tests").?.array;
    var tests = try allocator.alloc(TestCase, tests_array.items.len);
    
    for (tests_array.items, 0..) |test_json, i| {
        tests[i] = try parseTestCase(allocator, test_json);
    }
    
    return TestSuite{
        .name = name,
        .description = description,
        .source = source,
        .tests = tests,
    };
}

/// Parse individual test case
fn parseTestCase(allocator: std.mem.Allocator, value: std.json.Value) !TestCase {
    const obj = value.object;
    
    const name = try allocator.dupe(u8, obj.get("name").?.string);
    const expression = try allocator.dupe(u8, obj.get("expression").?.string);
    const inputfile = if (obj.get("inputfile")) |file|
        try allocator.dupe(u8, file.string)
    else
        null;
    
    // Clone the expected value
    const expected = try cloneJsonValue(allocator, obj.get("expected").?);
    
    // Parse optional fields
    const input = if (obj.get("input")) |inp|
        try cloneJsonValue(allocator, inp)
    else
        null;
        
    const error_field = if (obj.get("error")) |err|
        err.bool
    else
        null;
    
    // Parse tags if present
    var tags: ?[]const []const u8 = null;
    if (obj.get("tags")) |tags_json| {
        const tags_array = tags_json.array;
        var tag_list = try allocator.alloc([]const u8, tags_array.items.len);
        for (tags_array.items, 0..) |tag, i| {
            tag_list[i] = try allocator.dupe(u8, tag.string);
        }
        tags = tag_list;
    }
    
    return TestCase{
        .name = name,
        .expression = expression,
        .input = input,
        .inputfile = inputfile,
        .tags = tags,
        .expected = expected,
        .should_error = error_field,
    };
}

/// Clone a JSON value with allocation
fn cloneJsonValue(allocator: std.mem.Allocator, value: std.json.Value) !std.json.Value {
    switch (value) {
        .null => return .null,
        .bool => |b| return .{ .bool = b },
        .integer => |i| return .{ .integer = i },
        .float => |f| return .{ .float = f },
        .number_string => |s| return .{ .number_string = try allocator.dupe(u8, s) },
        .string => |s| return .{ .string = try allocator.dupe(u8, s) },
        .array => |arr| {
            var new_array = std.json.Array.init(allocator);
            try new_array.ensureTotalCapacity(arr.items.len);
            for (arr.items) |item| {
                const cloned = try cloneJsonValue(allocator, item);
                try new_array.append(cloned);
            }
            return .{ .array = new_array };
        },
        .object => |obj| {
            var new_map = std.json.ObjectMap.init(allocator);
            var it = obj.iterator();
            while (it.next()) |entry| {
                const key = try allocator.dupe(u8, entry.key_ptr.*);
                const val = try cloneJsonValue(allocator, entry.value_ptr.*);
                try new_map.put(key, val);
            }
            return .{ .object = new_map };
        },
    }
}

/// Load test input data from file
pub fn loadTestInput(allocator: std.mem.Allocator, base_path: []const u8, filename: []const u8) !std.json.Value {
    const path = try std.fs.path.join(allocator, &[_][]const u8{ base_path, "input", filename });
    defer allocator.free(path);
    
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    
    const content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024); // 10MB max for resources
    defer allocator.free(content);
    
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, content, .{});
    return parsed.value;
}

/// Free test suite resources
pub fn freeTestSuite(allocator: std.mem.Allocator, suite: *const TestSuite) void {
    allocator.free(suite.name);
    if (suite.description) |desc| allocator.free(desc);
    if (suite.source) |src| allocator.free(src);
    
    for (suite.tests) |*test_case| {
        allocator.free(test_case.name);
        allocator.free(test_case.expression);
        if (test_case.inputfile) |file| allocator.free(file);
        if (test_case.tags) |tags| {
            for (tags) |tag| allocator.free(tag);
            allocator.free(tags);
        }
        freeJsonValue(allocator, &test_case.expected);
        if (test_case.input) |*inp| freeJsonValue(allocator, inp);
    }
    
    allocator.free(suite.tests);
}

/// Free a cloned JSON value
pub fn freeJsonValue(allocator: std.mem.Allocator, value: *std.json.Value) void {
    switch (value.*) {
        .null, .bool, .integer, .float => {},
        .number_string => |s| allocator.free(s),
        .string => |s| allocator.free(s),
        .array => |*arr| {
            for (arr.items) |*item| {
                freeJsonValue(allocator, item);
            }
            arr.deinit();
        },
        .object => |*obj| {
            var it = obj.iterator();
            while (it.next()) |entry| {
                allocator.free(entry.key_ptr.*);
                freeJsonValue(allocator, entry.value_ptr);
            }
            obj.deinit();
        },
    }
}

/// List all test files in a directory
pub fn listTestFiles(allocator: std.mem.Allocator, dir_path: []const u8) ![][]const u8 {
    var dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    defer dir.close();
    
    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();
    
    var it = dir.iterate();
    while (try it.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".json")) {
            const name = try allocator.dupe(u8, entry.name);
            try files.append(name);
        }
    }
    
    return try files.toOwnedSlice();
}