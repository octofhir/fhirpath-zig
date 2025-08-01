const std = @import("std");
const fhirpath = @import("fhirpath");
const benchmark = @import("benchmark.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("FHIRPath Performance Benchmark\n", .{});
    try stdout.print("=============================\n\n", .{});
    
    // Parse command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    var config = benchmark.Config{
        .warmup_iterations = 10,
        .benchmark_iterations = 100,
        .time_limit_ms = 5000,
        .verbose = false,
    };
    
    // Parse command line arguments
    for (args) |arg| {
        if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-v")) {
            config.verbose = true;
        }
    }
    
    
    // Initialize benchmark runner
    var runner = try benchmark.Runner.init(allocator, config);
    
    // Run all test suites
    for (benchmark.standard_suites) |suite| {
        try stdout.print("\n## {s}\n", .{suite.name});
        try stdout.print("{s}\n", .{suite.description});
        
        var results = std.ArrayList(benchmark.BenchmarkResult).init(allocator);
        defer results.deinit();
        
        for (suite.expressions) |expr| {
            const result = try runner.benchmarkExpression(expr);
            try results.append(result);
        }
        
        try benchmark.formatResults(stdout, results.items);
    }
    
    // Summary statistics
    try stdout.print("\n## Summary\n", .{});
    try stdout.print("- Warmup iterations: {}\n", .{config.warmup_iterations});
    try stdout.print("- Benchmark iterations: {}\n", .{config.benchmark_iterations});
    try stdout.print("- Time limit per expression: {}ms\n", .{config.time_limit_ms});
}