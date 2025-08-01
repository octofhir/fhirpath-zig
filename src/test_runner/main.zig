const std = @import("std");
const fhirpath = @import("fhirpath");
const test_loader = @import("test_loader.zig");
const runner = @import("runner.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    var test_dir: ?[]const u8 = null;
    var report_file: ?[]const u8 = null;
    var verbose = false;
    var filter: ?[]const u8 = null;
    
    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--test-dir") and i + 1 < args.len) {
            test_dir = args[i + 1];
            i += 1;
        } else if (std.mem.eql(u8, args[i], "--report") and i + 1 < args.len) {
            report_file = args[i + 1];
            i += 1;
        } else if (std.mem.eql(u8, args[i], "--verbose") or std.mem.eql(u8, args[i], "-v")) {
            verbose = true;
        } else if (std.mem.eql(u8, args[i], "--filter") and i + 1 < args.len) {
            filter = args[i + 1];
            i += 1;
        }
    }
    
    if (test_dir == null) {
        std.debug.print("Usage: test-runner --test-dir <dir> [--report <file>] [--verbose] [--filter <pattern>]\n", .{});
        return;
    }
    
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("FHIRPath Conformance Test Runner\n", .{});
    try stdout.print("================================\n\n", .{});
    try stdout.print("Test directory: {s}\n", .{test_dir.?});
    
    // Initialize test runner
    var test_runner = try runner.Runner.init(allocator);
    defer test_runner.deinit();
    test_runner.verbose = verbose;
    
    // Load and run test suites
    const test_files = try test_loader.listTestFiles(allocator, test_dir.?);
    defer {
        for (test_files) |file| allocator.free(file);
        allocator.free(test_files);
    }
    
    var all_results = std.ArrayList(runner.SuiteResult).init(allocator);
    defer all_results.deinit();
    
    try stdout.print("\nRunning {any} test suites...\n", .{test_files.len});
    
    for (test_files) |test_file| {
        // Apply filter if specified
        if (filter) |f| {
            if (!std.mem.containsAtLeast(u8, test_file, 1, f)) continue;
        }
        
        const test_path = try std.fs.path.join(allocator, &[_][]const u8{ test_dir.?, test_file });
        defer allocator.free(test_path);
        
        const suite = test_loader.loadTestSuite(allocator, test_path) catch |err| {
            std.log.err("Failed to load test suite {s}: {any}", .{ test_file, err });
            continue;
        };
        defer test_loader.freeTestSuite(allocator, &suite);
        
        const result = try test_runner.runTestSuite(suite, test_dir.?);
        try result.format(stdout);
        try all_results.append(result);
    }
    
    // Generate summary
    try generateSummary(stdout, all_results.items);
    
    // Generate detailed report if requested
    if (report_file) |report| {
        try generateDetailedReport(allocator, report, all_results.items);
        try stdout.print("\nDetailed report saved to: {s}\n", .{report});
    }
    
    // Clean up results after generating all reports
    for (all_results.items) |*result| {
        result.deinit(allocator);
    }
}

fn generateSummary(writer: anytype, results: []const runner.SuiteResult) !void {
    var total_tests: usize = 0;
    var total_passed: usize = 0;
    var total_failed: usize = 0;
    var total_skipped: usize = 0;
    var total_time_ns: u64 = 0;
    
    for (results) |result| {
        total_tests += result.total_tests;
        total_passed += result.passed;
        total_failed += result.failed;
        total_skipped += result.skipped;
        total_time_ns += result.execution_time_ns;
    }
    
    const pass_rate = if (total_tests > 0)
        @as(f64, @floatFromInt(total_passed)) / @as(f64, @floatFromInt(total_tests)) * 100.0
    else
        0.0;
    
    try writer.print("\n\nOverall Summary\n", .{});
    try writer.print("{s:═<60}\n", .{""});
    try writer.print("Test Suites: {}\n", .{results.len});
    try writer.print("Total Tests: {}\n", .{total_tests});
    try writer.print("Passed: {} ({d:.1}%)\n", .{ total_passed, pass_rate });
    try writer.print("Failed: {}\n", .{total_failed});
    try writer.print("Skipped: {}\n", .{total_skipped});
    try writer.print("Total Time: {d:.2}s\n", .{
        @as(f64, @floatFromInt(total_time_ns)) / 1_000_000_000.0,
    });
}

fn generateDetailedReport(allocator: std.mem.Allocator, report_file: []const u8, results: []const runner.SuiteResult) !void {
    var report = std.ArrayList(u8).init(allocator);
    defer report.deinit();
    
    const writer = report.writer();
    
    // Header
    try writer.print("# FHIRPath Conformance Test Report\n\n", .{});
    try writer.print("Generated: {}\n\n", .{std.time.timestamp()});
    
    // Summary section
    try generateSummary(writer, results);
    
    // Details by suite
    try writer.print("\n\n## Test Suite Details\n\n", .{});
    
    for (results) |suite_result| {
        try writer.print("### {s}\n\n", .{suite_result.suite_name});
        try writer.print("- Total: {}\n", .{suite_result.total_tests});
        try writer.print("- Passed: {} ({d:.1}%)\n", .{ suite_result.passed, suite_result.passRate() });
        try writer.print("- Failed: {}\n", .{suite_result.failed});
        try writer.print("- Skipped: {}\n", .{suite_result.skipped});
        try writer.print("- Time: {d:.2}ms\n\n", .{
            @as(f64, @floatFromInt(suite_result.execution_time_ns)) / 1_000_000.0,
        });
        
        // Show failed tests
        var has_failures = false;
        for (suite_result.test_results) |test_result| {
            if (!test_result.passed) {
                if (!has_failures) {
                    try writer.print("#### Failed Tests:\n\n", .{});
                    has_failures = true;
                }
                
                try writer.print("- **{s}**: `{s}`\n", .{ test_result.test_name, test_result.expression });
                if (test_result.error_message) |msg| {
                    try writer.print("  - Error: {s}\n", .{msg});
                }
                if (test_result.expected_value) |expected| {
                    try writer.print("  - Expected: {s}\n", .{expected});
                }
                if (test_result.actual_value) |actual| {
                    try writer.print("  - Actual: {s}\n", .{actual});
                }
                try writer.print("\n", .{});
            }
        }
        
        if (!has_failures) {
            try writer.print("✅ All tests passed!\n\n", .{});
        }
    }
    
    // Write to file
    const file = try std.fs.cwd().createFile(report_file, .{});
    defer file.close();
    
    try file.writeAll(report.items);
}