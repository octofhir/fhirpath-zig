# Phase 1: Core Infrastructure

**Status:** ✅ Complete (memory management deferred)  
**Estimated Duration:** 2-3 weeks  
**Dependencies:** None  

## Overview

Implement the foundational components of the FHIRPath library including lexer, parser, AST, and basic type system.

## Tasks

### 1. Project Setup ✅
- [x] Initialize Zig project with build.zig
- [x] Set up directory structure
- [x] Configure testing framework
- [x] Add development dependencies
- [x] Set up ANTLR parser generation for benchmarking
- [x] Create benchmark infrastructure

### 2. Lexer Implementation ✅
- [x] Define Token enum with all FHIRPath tokens
- [x] Implement Scanner struct with position tracking
- [x] Add string literal parsing with escape sequences
- [x] Add number parsing (integers and decimals)
- [x] Add identifier and keyword recognition
- [x] Add operator tokenization
- [x] Implement error reporting with position info
- [x] Write comprehensive lexer tests

### 3. AST Definition ✅
- [x] Define base Node interface
- [x] Implement expression node types:
  - [x] LiteralNode (string, number, boolean, null)
  - [x] IdentifierNode
  - [x] MemberAccessNode (dot notation)
  - [x] IndexerNode (bracket notation)
  - [x] FunctionCallNode
  - [x] BinaryOpNode
  - [x] UnaryOpNode
  - [x] ConditionalNode (if-then-else)
- [x] Add source location tracking to all nodes
- [x] Implement visitor pattern infrastructure

### 4. Parser Implementation ✅
- [x] Implement Pratt parser foundation
- [x] Create operator precedence table
- [x] Define binding power for all operators
- [x] Implement primary expression parsing
- [x] Add expression parsing with Pratt algorithm
- [x] Implement path navigation as postfix operator
- [x] Add function call parsing as postfix
- [x] Handle operator associativity correctly
- [x] Implement error recovery
- [x] Add comprehensive parser tests
- [x] Validate against ANTLR grammar (91.8% pass rate)
- [x] Create parser benchmarks comparing with ANTLR baseline
- [x] Ensure AST compatibility with ANTLR output

### 5. Basic Type System ✅
- [x] Define Value union type
- [x] Implement FHIR primitive types:
  - [x] Boolean
  - [x] String
  - [x] Integer
  - [x] Decimal
  - [x] Date/DateTime/Time
  - [x] Quantity
- [x] Define Collection type with lazy evaluation support
- [x] Add type conversion utilities
- [x] Implement equality and comparison logic

### 6. Error Handling ✅
- [x] Define error types hierarchy
- [x] Add error context and chaining
- [x] Implement error formatting
- [x] Add source location to errors

### 7. Testing Infrastructure ✅
- [x] Set up test harness for official test suite
- [x] Create test runner for JSON test cases
- [x] Add test categorization and filtering
- [x] Implement test result reporting

## Acceptance Criteria

- [x] Can tokenize all valid FHIRPath expressions
- [x] Can parse basic expressions (literals, paths, function calls)
- [x] AST correctly represents expression structure  
- [x] All tokens from ANTLR grammar are supported
- [x] Comprehensive error messages with positions
- [x] Grammar validation tests pass 100% (49/49)
- [x] Parser performance significantly faster than ANTLR baseline
- [x] Benchmark suite operational
- [ ] Memory leaks fixed (deferred to Phase 2)
- [ ] Full conformance test suite passing (Phase 2 dependency)

## Notes

- Focus on correctness over performance in this phase
- Ensure compatibility with ANTLR grammar from the start
- Keep parser modular for easy extension
- Document all public APIs
- Pratt parsing will simplify operator precedence handling
- Use binding power table for clear precedence rules