# FHIRPath Test Runner

This directory contains the official FHIRPath conformance test runner, which validates our implementation against the standard test suite.

## Usage

```bash
# Run all tests
zig build test-conformance

# Run with custom options
./zig-out/bin/test-runner --test-dir specs/fhirpath/tests [options]

Options:
  --test-dir <dir>     Directory containing test JSON files (required)
  --report <file>      Generate detailed report to file
  --verbose, -v        Show individual test results
  --filter <pattern>   Only run test files matching pattern
```

## Test Format

Test files follow the official FHIRPath test format:

```json
{
  "name": "testSuiteName",
  "description": "Suite description",
  "tests": [
    {
      "name": "testName",
      "expression": "FHIRPath expression",
      "inputfile": "input-resource.json",
      "expected": ["expected", "results"],
      "error": false
    }
  ]
}
```

## Features

- **Comprehensive Loading**: Loads official JSON test suites
- **Resource Loading**: Automatically loads input FHIR resources
- **Result Comparison**: Compares actual vs expected values
- **Error Handling**: Tests both successful and error cases
- **Performance Tracking**: Measures execution time per test
- **Detailed Reporting**: Generates markdown reports with failure details
- **Filtering**: Run specific test suites with pattern matching
- **Progress Display**: Shows real-time test execution progress

## Implementation Details

### Components

1. **test_loader.zig**: Handles loading test suites and input data
2. **runner.zig**: Executes tests and collects results
3. **main.zig**: CLI interface and report generation

### Test Execution Flow

1. Load test suite JSON file
2. For each test case:
   - Load input resource if specified
   - Parse and evaluate FHIRPath expression
   - Compare result with expected value
   - Track timing and errors
3. Generate summary and detailed reports

## Current Status

The test runner is fully functional and can:
- Load and parse official test suites
- Execute FHIRPath expressions with context
- Compare results with expected values
- Generate detailed failure reports
- Track performance metrics

## Next Steps

1. Implement missing FHIRPath features to pass more tests
2. Add parallel test execution for performance
3. Implement test result caching
4. Add regression detection between runs
5. Create test coverage reports