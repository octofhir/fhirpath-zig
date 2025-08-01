# Test Runner Implementation

**Status:** Not Started  
**Estimated Duration:** 1 week  
**Dependencies:** Can be developed in parallel with core implementation  

## Overview

Implement the FHIRPath conformance test runner that executes official test suites and generates markdown reports with implementation progress.

## Tasks

### 1. Test Data Models ⬜
- [ ] Define TestCase struct matching JSON format
- [ ] Define TestGroup struct for test organization
- [ ] Add test metadata (tags, categories)
- [ ] Create result tracking structures
- [ ] Add timing and performance metrics

### 2. JSON Test Loader ⬜
- [ ] Parse test JSON files from `specs/fhirpath/tests/`
- [ ] Validate test file format
- [ ] Handle different test case formats
- [ ] Support context and variables loading
- [ ] Implement test filtering by tags/categories

### 3. Test Executor ⬜
- [ ] Create test execution engine
- [ ] Handle expression evaluation
- [ ] Compare expected vs actual results
- [ ] Capture errors and exceptions
- [ ] Track execution time per test
- [ ] Support timeout for long-running tests

### 4. Result Comparison ⬜
- [ ] Implement value comparison logic
- [ ] Handle collection order sensitivity
- [ ] Support approximate decimal comparison
- [ ] Error message matching
- [ ] Null/empty value handling

### 5. Markdown Report Generator ⬜
- [ ] Generate summary statistics table
- [ ] Create progress visualization
- [ ] Group results by category
- [ ] Calculate implementation percentages
- [ ] Generate detailed failure reports
- [ ] Add execution time analysis
- [ ] Include implementation roadmap suggestions

### 6. Test Runner CLI ⬜
- [ ] Command-line argument parsing
- [ ] Filter options (--filter, --tags)
- [ ] Output format options
- [ ] Verbose/quiet modes
- [ ] Compare with previous runs
- [ ] Watch mode for development

### 7. Progress Tracking ⬜
- [ ] Store historical test results
- [ ] Generate progress charts
- [ ] Detect regressions
- [ ] Track newly passing tests
- [ ] Generate diff reports

### 8. Integration ⬜
- [ ] Add to build.zig
- [ ] Create test-conformance target
- [ ] CI/CD integration
- [ ] Git pre-commit hooks
- [ ] Automated report commits
- [ ] Include Pratt parser performance benchmarks
- [ ] Generate combined conformance + performance reports

## Report Features

### Summary Section
- Total tests by category
- Pass/fail/skip counts
- Implementation percentage
- Execution time statistics

### Progress Visualization
```
Literals:     ████████████████████ 100%
Operators:    ████████████████░░░░  83%
Functions:    ███████████████░░░░░  75%
Collections:  ████████████░░░░░░░░  60%
```

### Detailed Results
- Failed test details with diffs
- Not implemented features
- Performance bottlenecks
- Suggested implementation order

## Acceptance Criteria

- [ ] Loads all test files from specs directory
- [ ] Executes tests with proper context
- [ ] Generates readable markdown reports
- [ ] Accurately calculates implementation %
- [ ] Provides actionable failure information
- [ ] Runs in under 10 seconds for full suite
- [ ] Integrates with build system

## Example Usage

```bash
# Run all tests
zig build test-conformance

# Run with filter
zig build test-conformance -- --filter="Operators"

# Generate report only
zig build test-conformance -- --report-only

# Compare with baseline
zig build test-conformance -- --baseline=v1.0.0

# Watch mode
zig build test-conformance -- --watch
```

## Notes

- Start with basic functionality, enhance incrementally
- Ensure report is human-readable and actionable
- Consider generating multiple format outputs (JSON, HTML)
- Make test runner reusable for other projects
- Include Pratt parser performance comparison in reports
- Track parsing performance improvements over time