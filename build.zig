const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main library
    const lib = b.addStaticLibrary(.{
        .name = "fhirpath",
        .root_source_file = b.path("src/fhirpath.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the library
    b.installArtifact(lib);

    // Example executable
    const exe = b.addExecutable(.{
        .name = "fhirpath-cli",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("fhirpath", lib.root_module);
    
    // Install the executable
    b.installArtifact(exe);

    // Test runner executable
    const test_runner = b.addExecutable(.{
        .name = "test-runner",
        .root_source_file = b.path("src/test_runner/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_runner.root_module.addImport("fhirpath", lib.root_module);
    b.installArtifact(test_runner);

    // Benchmark executable
    const benchmark = b.addExecutable(.{
        .name = "benchmark",
        .root_source_file = b.path("src/benchmark/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    benchmark.root_module.addImport("fhirpath", lib.root_module);
    
    b.installArtifact(benchmark);

    // Grammar validation executable
    const grammar_test = b.addExecutable(.{
        .name = "test-grammar",
        .root_source_file = b.path("src/test_grammar_validation.zig"),
        .target = target,
        .optimize = optimize,
    });
    grammar_test.root_module.addImport("fhirpath", lib.root_module);
    b.installArtifact(grammar_test);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/fhirpath.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Conformance tests
    const run_conformance = b.addRunArtifact(test_runner);
    run_conformance.addArg("--test-dir");
    run_conformance.addArg("specs/fhirpath/tests");
    run_conformance.addArg("--report");
    run_conformance.addArg("test_results.md");

    const conformance_step = b.step("test-conformance", "Run conformance tests");
    conformance_step.dependOn(&run_conformance.step);

    // Benchmarks
    const run_benchmark = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("bench", "Run performance benchmarks");
    benchmark_step.dependOn(&run_benchmark.step);

    // Grammar validation
    const run_grammar_test = b.addRunArtifact(grammar_test);
    const grammar_step = b.step("test-grammar", "Run grammar validation tests");
    grammar_step.dependOn(&run_grammar_test.step);

    // Run example
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}