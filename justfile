# FHIRPath Zig Development Commands

# Default recipe - show help
default:
    @just --list

# Build the project
build:
    zig build

# Run all tests
test:
    zig build test

# Run conformance tests
test-conformance:
    zig build test-conformance

# Run benchmarks
bench:
    zig build bench

# Run the CLI with an expression
run expr:
    zig build run -- "{{expr}}"

# Run the CLI with an expression and show timing
run-timed expr:
    time zig build run -- "{{expr}}"

# Clean build artifacts
clean:
    rm -rf zig-cache zig-out

# Format code (when zig fmt is available)
fmt:
    find src -name "*.zig" -exec zig fmt {} \;

# Check for common issues
check:
    zig build test
    @echo "✅ All tests passed"

# Development workflow - test and run example
dev:
    just test
    just run "1 + 2 * 3"
    just run "true and false"
    just run "not true"

# Update task files with current status
update-tasks:
    @echo "Updating task completion status..."
    # This would be automated in a real workflow

# Examples of FHIRPath expressions to test
examples:
    @echo "Testing various FHIRPath expressions..."
    just run "true"
    just run "42"
    just run "1 + 2"
    just run "1 + 2 * 3"
    just run "true and false"
    just run "true or false"
    just run "not true"
    just run "(1 + 2) * 3"

# Performance testing
perf expr="1 + 2 * 3":
    @echo "Performance testing: {{expr}}"
    hyperfine --warmup 3 'zig build run -- "{{expr}}"' || time zig build run -- "{{expr}}"

# Generate test report
report:
    zig build test-conformance --verbose

# Show project status
status:
    @echo "FHIRPath Zig Implementation Status"
    @echo "=================================="
    @echo "✅ Lexer: Complete"
    @echo "✅ Parser: Pratt parser with operator precedence"
    @echo "✅ AST: All node types implemented"
    @echo "✅ Evaluator: Basic arithmetic and logical operations"
    @echo "✅ CLI: Working with expression evaluation"
    @echo "⚠️  Memory management: Has known leaks (cleanup needed)"
    @echo "🔄 In progress: Advanced FHIRPath features"
    @echo ""
    @just test --silent >/dev/null 2>&1 && echo "✅ All tests passing" || echo "❌ Some tests failing"

# Development setup
setup:
    @echo "Setting up FHIRPath Zig development environment..."
    @echo "Checking Zig installation..."
    zig version
    @echo "Building project..."
    just build
    @echo "Running tests..."
    just test --silent >/dev/null 2>&1 && echo "✅ Setup complete!" || echo "❌ Setup failed - check test output"

# Quick syntax check
syntax-check:
    zig build-lib src/fhirpath.zig --name fhirpath -femit-bin=/dev/null

# Show current implementation coverage
coverage:
    @echo "Implementation Coverage:"
    @echo "Literals: ✅ boolean, number, string"
    @echo "Operators: ✅ +, -, *, /, =, and, or, not"
    @echo "Precedence: ✅ Mathematical and logical"
    @echo "Parentheses: ✅ Grouping expressions"
    @echo "Missing: Path navigation, functions, collections"