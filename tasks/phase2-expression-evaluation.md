# Phase 2: Expression Evaluation

**Status:** ✅ Core Complete  
**Estimated Duration:** 3-4 weeks  
**Dependencies:** Phase 1 Complete  

## Overview

Implement the core evaluation engine that can execute FHIRPath expressions against FHIR resources.

## Tasks

### 1. Evaluation Context ✅
- [x] Define EvaluationContext struct
- [x] Implement variable binding
- [x] Add function registry
- [x] Support for $this, $index, $total
- [ ] Environment variable support (deferred)

### 2. Basic Evaluator ✅
- [x] Implement Evaluator struct
- [x] Add AST visitor for evaluation
- [x] Handle literal evaluation
- [x] Implement identifier resolution
- [x] Add basic error propagation

### 3. Path Navigation ✅
- [x] Implement dot notation (`.property`)
- [x] Add bracket notation (`[index]`)
- [x] Support polymorphic property access
- [x] Handle missing properties (empty collection)
- [ ] Implement `children()` and `descendants()` (deferred)

### 4. Collection Operations ⬜
- [ ] Implement collection creation
- [ ] Add lazy evaluation support
- [ ] Basic collection functions:
  - [ ] `where(criteria)`
  - [ ] `select(projection)`
  - [ ] `first()`
  - [ ] `last()`
  - [ ] `tail()`
  - [ ] `skip(count)`
  - [ ] `take(count)`
  - [ ] `single()`
- [ ] Collection combination:
  - [ ] `union(other)`
  - [ ] `intersect(other)`
  - [ ] `exclude(other)`
  - [ ] `combine(other)`

### 5. Operators ⬜
- [ ] Arithmetic operators:
  - [ ] Addition (`+`)
  - [ ] Subtraction (`-`)
  - [ ] Multiplication (`*`)
  - [ ] Division (`/`)
  - [ ] Modulo (`mod`)
  - [ ] Integer division (`div`)
- [ ] Comparison operators:
  - [ ] Equality (`=`, `!=`)
  - [ ] Comparison (`<`, `>`, `<=`, `>=`)
  - [ ] Equivalence (`~`, `!~`)
- [ ] Logical operators:
  - [ ] And (`and`)
  - [ ] Or (`or`)
  - [ ] Xor (`xor`)
  - [ ] Not (`not`)
  - [ ] Implies (`implies`)
- [ ] String concatenation (`&`)
- [ ] Membership (`in`, `contains`)

### 6. Type Operations ⬜
- [ ] Type checking (`is`, `as`)
- [ ] Type conversion functions
- [ ] Polymorphic dispatch
- [ ] Safe casting

### 7. Null and Empty Handling ⬜
- [ ] Implement propagating semantics
- [ ] Empty collection handling
- [ ] Null-safe navigation
- [ ] `exists()` and `empty()` functions

### 8. Basic Functions ✅
- [x] Boolean functions:
  - [ ] `iif(condition, true-result, false-result)` (deferred)
  - [x] `not()`
- [x] Collection testing:
  - [x] `exists(criteria?)`
  - [ ] `all(criteria)` (deferred)
  - [ ] `anyTrue()` (deferred)
  - [ ] `allTrue()` (deferred)
  - [ ] `anyFalse()` (deferred)
  - [ ] `allFalse()` (deferred)
- [x] Collection utilities:
  - [x] `count()`
  - [x] `distinct()`
  - [ ] `isDistinct()` (deferred)

### 9. Performance Optimizations ⬜
- [ ] Short-circuit evaluation
- [ ] Common subexpression elimination
- [ ] Path access optimization
- [ ] Collection operation fusion

## Acceptance Criteria

- [ ] Can evaluate all basic FHIRPath expressions
- [ ] Passes relevant official test cases
- [ ] Correct null/empty propagation
- [ ] Proper type checking and conversion
- [ ] No unnecessary allocations
- [ ] Clear error messages for type mismatches

## Test Categories to Pass

- `testGroup.json`
- `testPath.json` 
- `testOperators.json`
- `testCollections.json`
- `testEquality.json`
- `testLogical.json`
- `testTypes.json`

## Notes

- Focus on correctness of collection semantics
- Ensure lazy evaluation where possible
- Keep evaluator stateless for thread safety
- Profile common operations early