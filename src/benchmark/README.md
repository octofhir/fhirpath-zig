# FHIRPath Parser Benchmarks

This directory contains performance benchmarks comparing our Pratt parser implementation with the ANTLR-generated baseline.

## Setup

### Prerequisites

- ANTLR 4.13.1+ runtime library
- CMake 3.14+
- C++ compiler with C++17 support

### Building ANTLR Parser

1. Generate ANTLR parser:
   ```bash
   ./scripts/generate-antlr.sh
   ```

2. Build ANTLR library:
   ```bash
   ./scripts/build-antlr.sh
   ```

## Running Benchmarks

```bash
# Run with ANTLR comparison (default)
zig build bench

# Run without ANTLR comparison
zig build bench -- --no-antlr

# Run with verbose output
zig build bench -- --verbose
```

## Benchmark Suites

### Simple Operators
Basic arithmetic and comparison operations to test operator precedence handling.

### Path Navigation
Property access and path traversal operations common in FHIR resources.

### Complex Expressions
Real-world FHIRPath expressions combining multiple features.

### Operator Stress
Deep operator nesting and precedence to highlight Pratt parser advantages.

## Metrics Collected

- **Parse Time**: Time to convert expression string to AST
- **Node Count**: Number of AST nodes created
- **Memory Usage**: Bytes allocated during parsing (when available)
- **Speedup**: Ratio of ANTLR time to Zig time

## Expected Results

The Pratt parser should show significant performance improvements over ANTLR, especially for:
- Operator-heavy expressions (5-10x speedup expected)
- Deep precedence levels
- Left-associative operator chains

## Implementation Details

The benchmark infrastructure:
1. Warms up both parsers before measurement
2. Runs multiple iterations (default 100)
3. Calculates average times
4. Handles parse errors gracefully
5. Supports time-based cutoff for long-running tests