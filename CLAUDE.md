# FHIRPath Zig Implementation - Claude Development Guide

## Project Overview

This is a Zig implementation of FHIRPath, a path-based navigation and extraction language for FHIR (Fast Healthcare Interoperability Resources) data. FHIRPath is similar to XPath but designed specifically for navigating hierarchical healthcare data models.

## Current Status

**⚠️ This project is in initial setup phase - no source code has been implemented yet.**

The repository currently contains:
- Complete FHIRPath specification (version 1.3.0)
- Comprehensive test suite in JSON format
- ANTLR grammar file (`fhirpath.g4`)
- Test input data (FHIR resources in JSON)

## Project Structure

```
fhirpath-zig/
├── specs/                      # FHIRPath specification and test suite
│   ├── *.md                   # Specification chapters
│   ├── fhirpath.g4            # ANTLR grammar definition
│   └── fhirpath/
│       └── tests/             # Official test suite
│           ├── *.json         # Test case definitions
│           └── input/         # Test input FHIR resources
└── CLAUDE.md                  # This file
```

## FHIRPath Overview

FHIRPath is a expression language that allows:
- Navigation through FHIR resource hierarchies
- Selection and filtering of data
- Type-safe operations on healthcare data
- Mathematical and string operations
- Collection manipulation

Example expressions:
- `Patient.name.given` - Get all given names
- `Patient.telecom.where(use = 'home')` - Filter telecom by use
- `Observation.value.as(Quantity).value > 100` - Type casting and comparison

## Implementation Roadmap

### Phase 1: Core Infrastructure
1. **Project Setup**
   - Create `build.zig` file
   - Set up basic project structure
   - Add testing framework

2. **Lexer/Tokenizer**
   - Implement token types based on grammar
   - Handle literals (strings, numbers, booleans, dates)
   - Support operators and keywords

3. **Parser**
   - Convert ANTLR grammar to Zig parser
   - Build AST (Abstract Syntax Tree)
   - Handle operator precedence

### Phase 2: Core Functionality
1. **Type System**
   - Implement FHIRPath types (primitive, complex, collections)
   - Type checking and conversions
   - Support for FHIR-specific types (Quantity, Period, etc.)

2. **Evaluator**
   - Path navigation (`Patient.name.given`)
   - Basic operations (arithmetic, comparison, boolean)
   - Collection operations (where, select, first, etc.)

3. **Functions**
   - Existence functions (empty, exists, all, etc.)
   - Filtering/projection (where, select, repeat)
   - String manipulation
   - Math functions
   - Type operations

### Phase 3: Advanced Features
1. **Advanced Functions**
   - Aggregates (sum, avg, min, max)
   - Tree navigation (children, descendants)
   - Utility functions (trace, now, today)

2. **Type Safety & Reflection**
   - Strict evaluation mode
   - Type reflection (`type()`, `is()`, `as()`)
   - Polymorphic resolution

3. **Environment Variables**
   - Support for `%context`, `%ucum`, `%vs`
   - Custom variable injection

## Development Guidelines

### Building the Project
```bash
# Once build.zig is created:
zig build

# Run tests
zig build test
```

### Code Organization Suggestions
```
src/
├── main.zig              # Entry point
├── lexer.zig            # Tokenization
├── parser.zig           # AST construction
├── ast.zig              # AST node definitions
├── evaluator.zig        # Expression evaluation
├── types.zig            # Type system
├── functions/           # Built-in functions
│   ├── existence.zig
│   ├── filtering.zig
│   ├── math.zig
│   └── string.zig
└── tests/              # Unit tests
```

### Testing Strategy

1. **Unit Tests**: Test individual components (lexer, parser, functions)
2. **Integration Tests**: Use the official test suite in `specs/fhirpath/tests/`
3. **Test Runner**: Build a test runner that:
   - Loads JSON test files
   - Parses input FHIR resources
   - Evaluates expressions
   - Compares results with expected values

### Key Implementation Considerations

1. **Error Handling**
   - Use Zig's error unions for recoverable errors
   - Provide clear error messages with location info
   - Handle invalid paths gracefully (return empty collection)

2. **Performance**
   - Lazy evaluation for collection operations
   - Efficient path traversal
   - Memory-efficient collection handling

3. **FHIR Compatibility**
   - Support both JSON and XML FHIR formats
   - Handle FHIR-specific types (Reference, Coding, etc.)
   - Respect FHIR versioning

4. **Collection Semantics**
   - FHIRPath uses "collection of one" semantics
   - Empty collections for non-existent paths
   - Proper null handling

## Test Suite Structure

Each test file in `specs/fhirpath/tests/` contains:
```json
{
  "name": "test suite name",
  "tests": [
    {
      "name": "test name",
      "expression": "FHIRPath expression",
      "inputfile": "input file name",
      "expected": [expected results]
    }
  ]
}
```

## Resources

- **Specification**: See `specs/§00-index.md` for complete spec
- **Grammar**: `specs/fhirpath.g4` - ANTLR grammar definition
- **Test Cases**: `specs/fhirpath/tests/` - Comprehensive test suite
- **HL7 Wiki**: [FHIRPath Implementations](http://wiki.hl7.org/index.php?title=FHIRPath_Implementations)

## Getting Started

1. **Understand the Spec**: Read through the specification files, starting with:
   - `§01-title-and-introduction.md`
   - `§03-navigation-model.md`
   - `§05-expressions.md`

2. **Study the Grammar**: Review `fhirpath.g4` to understand syntax

3. **Examine Tests**: Look at test files to understand expected behavior:
   - `basics.json` - Simple path navigation
   - `literals.json` - Literal value handling
   - `functions.json` - Built-in function tests

4. **Start Implementation**: Begin with lexer/parser using the grammar as a guide

## Common FHIRPath Patterns

```
// Basic navigation
Patient.name.family

// Filtering
Patient.name.where(use = 'official')

// Existence checking
Patient.deceased.exists()

// Type operations
Observation.value.as(Quantity).value

// Collection operations
Patient.name.given.first()

// Complex expressions
Patient.telecom.where(system = 'phone' and use = 'home').value
```

## Notes for Implementation

- The specification marks some features as "Standard for Trial Use" (STU): Aggregates, Type Reflection, Math functions
- Pay attention to operator precedence defined in the grammar
- Collection semantics are crucial - most operations work on collections
- Null/empty handling follows specific rules outlined in the spec
- The test suite is comprehensive and should guide implementation correctness



## Guidelines

Apply the following guidelines when developing fhirpath-core:
- [Ziglang docs](https://ziglang.org/documentation/master/)

## Specifications and Dependencies

- FHIRPath specification reference in `specs/` folder
- Official test cases in `specs/fhirpath/tests/` 
- FHIRSchema spec: https://fhir-schema.github.io/fhir-schema/intro.html
- Take a look for fhipath.js as referneed implemmentation  

## Architecture Decision Records (ADRs)

Before implementing major features:
1. Create ADR following: https://github.com/joelparkerhenderson/architecture-decision-record
2. Split implementation into phases/tasks stored in `tasks/` directory  
3. Update task files with implementation status

## Planing Phase

For every ADR implementation split record into phases/tasks and store in `tasks` directory. Maintain a specific task file when working on it. Before starting on the first task, create all tasks for future use. After implementing features from a task file update it status
For debugging cases create a simple test inside the test directory and delete it after resolving the issue


## Task executing phase
Update task file for aligh with implemented features
