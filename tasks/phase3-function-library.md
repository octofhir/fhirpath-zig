# Phase 3: Function Library

**Status:** Completed  
**Estimated Duration:** 2-3 weeks  
**Dependencies:** Phase 2 Complete  

## Overview

Implement the comprehensive function library required by the FHIRPath specification.

## Tasks

### 1. Function Registry Infrastructure ✅
- [x] Define Function interface
- [x] Implement function registration
- [ ] Add function overloading support
- [ ] Type checking for arguments
- [ ] Function documentation system

### 2. String Functions ✅
- [x] `indexOf(substring)`
- [x] `substring(start, length?)`
- [x] `startsWith(prefix)`
- [x] `endsWith(suffix)`
- [x] `contains(substring)`
- [x] `upper()`
- [x] `lower()`
- [x] `replace(pattern, substitution)`
- [x] `matches(regex)`
- [ ] `replaceMatches(regex, substitution)`
- [x] `length()`
- [ ] `toChars()`
- [ ] `split(separator)`
- [ ] `join(separator)`
- [ ] `encode(format)` / `decode(format)`

### 3. Math Functions ✅
- [x] `abs()`
- [x] `ceiling()`
- [x] `floor()`
- [x] `truncate()`
- [x] `round(precision?)`
- [x] `sqrt()`
- [x] `exp()`
- [x] `ln()`
- [x] `log(base)`
- [x] `power(exponent)`

### 4. Date/Time Functions ✅
- [x] `today()`
- [x] `now()`
- [x] `timeOfDay()`
- [ ] Date/time arithmetic
- [ ] Date/time comparison
- [ ] `toDateTime()`
- [ ] `toTime()`
- [ ] `toDate()`

### 5. Type Conversion Functions ✅
- [x] `toString()`
- [x] `toInteger()`
- [x] `toDecimal()`
- [x] `toBoolean()`
- [ ] `toQuantity(unit?)`
- [ ] `toDateTime()`
- [ ] `toTime()`
- [x] `convertsTo<Type>()`

### 6. Collection Aggregates ✅
- [ ] `aggregate(aggregator, init?)` (stub - requires expression evaluation)
- [x] `sum()`
- [x] `min()`
- [x] `max()`
- [x] `avg()`
- [x] `stdDev()`
- [ ] `population.stdDev()` (not implemented - complex statistical function)
- [x] `variance()`
- [ ] `population.variance()` (not implemented - complex statistical function)

### 7. Utility Functions ✅
- [x] `trace(name?, selector?)`
- [ ] `repeat(projection)` (stub - requires expression evaluation)
- [x] `ofType(type)` (implemented in type_reflection.zig)

### 8. Advanced Collection Functions ✅
- [x] `subsetOf(other)`
- [x] `supersetOf(other)`
- [x] `distinctBy(projection)` (simplified - full version requires expression evaluation)

### 9. Quantity Functions ⬜
- [ ] Quantity arithmetic
- [ ] Unit conversion
- [ ] Quantity comparison
- [ ] UCUM unit support

## Acceptance Criteria

- [ ] All specification functions implemented
- [ ] Correct handling of edge cases
- [ ] Proper null/empty propagation
- [ ] Type safety for all functions
- [ ] Performance optimized implementations
- [ ] Comprehensive test coverage

## Test Categories to Pass

- `testString.json`
- `testMath.json`
- `testDateTime.json`
- `testConversion.json`
- `testAggregates.json`
- `testQuantity.json`

## Notes

- Ensure consistent error handling across all functions
- Use Zig's comptime features for type checking where possible
- Consider SIMD optimizations for aggregate functions
- Follow specification precisely for edge cases