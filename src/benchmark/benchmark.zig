const std = @import("std");
const fhirpath = @import("fhirpath");

/// Benchmark result for a single expression
pub const BenchmarkResult = struct {
    expression: []const u8,
    zig_metrics: Metrics,
};

/// Performance metrics
pub const Metrics = struct {
    parse_time_ns: u64,
    eval_time_ns: u64,
    total_time_ns: u64,
    memory_bytes: usize,
    node_count: usize,
    iterations: u32,
    errors: u32,
    
    /// Calculate average time in nanoseconds
    pub fn avgParseTimeNs(self: Metrics) u64 {
        if (self.iterations == 0) return 0;
        return self.parse_time_ns / self.iterations;
    }
    
    /// Calculate average time in microseconds
    pub fn avgParseTimeUs(self: Metrics) f64 {
        return @as(f64, @floatFromInt(self.avgParseTimeNs())) / 1000.0;
    }
    
    /// Calculate average time in milliseconds
    pub fn avgParseTimeMs(self: Metrics) f64 {
        return self.avgParseTimeUs() / 1000.0;
    }
};

/// Benchmark configuration
pub const Config = struct {
    warmup_iterations: u32 = 10,
    benchmark_iterations: u32 = 100,
    time_limit_ms: u64 = 5000,
    verbose: bool = false,
};

/// Benchmark runner
pub const Runner = struct {
    allocator: std.mem.Allocator,
    config: Config,
    timer: std.time.Timer,
    
    pub fn init(allocator: std.mem.Allocator, config: Config) !Runner {
        return .{
            .allocator = allocator,
            .config = config,
            .timer = try std.time.Timer.start(),
        };
    }
    
    /// Run benchmark for a single expression
    pub fn benchmarkExpression(self: *Runner, expression: []const u8) !BenchmarkResult {
        if (self.config.verbose) {
            std.debug.print("Benchmarking: {s}\n", .{expression});
        }
        
        // Benchmark Zig parser
        const zig_metrics = try self.benchmarkZigParser(expression);
        
        return BenchmarkResult{
            .expression = expression,
            .zig_metrics = zig_metrics,
        };
    }
    
    /// Benchmark the Zig parser
    fn benchmarkZigParser(self: *Runner, expression: []const u8) !Metrics {
        var metrics = Metrics{
            .parse_time_ns = 0,
            .eval_time_ns = 0,
            .total_time_ns = 0,
            .memory_bytes = 0,
            .node_count = 0,
            .iterations = 0,
            .errors = 0,
        };
        
        // Warmup
        for (0..self.config.warmup_iterations) |_| {
            var arena = std.heap.ArenaAllocator.init(self.allocator);
            defer arena.deinit();
            
            _ = fhirpath.parse(expression, arena.allocator()) catch {
                continue;
            };
        }
        
        // Benchmark
        const start_time = self.timer.read();
        while (metrics.iterations < self.config.benchmark_iterations) {
            if (self.timer.read() - start_time > self.config.time_limit_ms * std.time.ns_per_ms) {
                break;
            }
            
            var arena = std.heap.ArenaAllocator.init(self.allocator);
            defer arena.deinit();
            
            const iter_start = self.timer.read();
            const ast = fhirpath.parse(expression, arena.allocator()) catch {
                metrics.errors += 1;
                continue;
            };
            const iter_end = self.timer.read();
            
            metrics.parse_time_ns += iter_end - iter_start;
            metrics.node_count = countNodes(ast);
            metrics.iterations += 1;
        }
        
        metrics.total_time_ns = self.timer.read() - start_time;
        
        return metrics;
    }
    
    
    /// Count nodes in AST
    fn countNodes(node: *const fhirpath.ast.Node) usize {
        // For now, just count this node
        // TODO: Implement proper AST traversal when visitor pattern is available
        _ = node;
        return 1;
    }
};

/// Test suite for benchmarking
pub const TestSuite = struct {
    name: []const u8,
    expressions: []const []const u8,
    description: []const u8,
};

/// Standard benchmark test suites
pub const standard_suites = [_]TestSuite{
    .{
        .name = "Simple Operators",
        .description = "Basic arithmetic and comparison operations",
        .expressions = &[_][]const u8{
            "1 + 2",
            "1 + 2 * 3",
            "1 + 2 * 3 - 4",
            "(1 + 2) * (3 - 4)",
            "a + b * c / d - e",
            "x > 5 and y < 10",
        },
    },
    .{
        .name = "Path Navigation",
        .description = "Property access and path traversal",
        .expressions = &[_][]const u8{
            "Patient",
            "Patient.name",
            "Patient.name.given",
            "Patient.name[0].given",
            "Patient.name.given.first()",
            "Bundle.entry.resource.name",
        },
    },
    .{
        .name = "Complex Expressions",
        .description = "Real-world FHIRPath expressions",
        .expressions = &[_][]const u8{
            "Patient.telecom.where(use = 'home')",
            "Observation.value.as(Quantity).value > 100",
            "Bundle.entry.resource.where($this is Patient)",
            "items.where(code = 'xyz').select(display)",
            "(a + b) * c where d.exists() and e > 5",
        },
    },
    .{
        .name = "Operator Stress",
        .description = "Deep operator nesting and precedence",
        .expressions = &[_][]const u8{
            "a or b and c implies d",
            "a + b * c - d / e + f * g - h",
            "(a + b) * (c - d) / (e + f) - (g * h)",
            "a + b + c + d + e + f + g + h + i + j",
            "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p",
        },
    },
};

/// Format benchmark results as a table
pub fn formatResults(writer: anytype, results: []const BenchmarkResult) !void {
    try writer.print("\n{s:<50} {s:>15}\n", .{
        "Expression",
        "Zig (μs)",
    });
    try writer.print("{s:-<50} {s:->15}\n", .{ "", "" });
    
    for (results) |result| {
        const expr = if (result.expression.len > 47)
            result.expression[0..47]
        else
            result.expression;
            
        try writer.print("{s:<50} {d:>15.2}\n", .{
            expr,
            result.zig_metrics.avgParseTimeUs(),
        });
    }
}