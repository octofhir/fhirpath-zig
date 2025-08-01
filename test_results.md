# FHIRPath Conformance Test Report

Generated: 1754033754



Overall Summary
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Test Suites: 98
Total Tests: 1005
Passed: 121 (12.0%)
Failed: 884
Skipped: 0
Total Time: 0.37s


## Test Suite Details

### ªªªªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.31ms

#### Failed Tests:

- **testDistinct1**: `(1 | 2 | 3).isDistinct()`
  - Error: error.InvalidFunctionCall

- **testDistinct2**: `Questionnaire.descendants().linkId.isDistinct()`
  - Error: error.InvalidFunctionCall

- **testDistinct3**: `Questionnaire.descendants().linkId.select(substring(0,1)).isDistinct().not()`
  - Error: error.InvalidFunctionCall

- **testDistinct4**: `(1 | 2 | 3).distinct()`
  - Error: error.InvalidFunctionCall

- **testDistinct5**: `Questionnaire.descendants().linkId.distinct().count()`
  - Error: error.InvalidFunctionCall

- **testDistinct6**: `Questionnaire.descendants().linkId.select(substring(0,1)).distinct().count()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.51ms

#### Failed Tests:

- **testSkip1**: `(0 | 1 | 2).skip(1) = 1 | 2`
  - Error: error.InvalidFunctionCall

- **testSkip2**: `(0 | 1 | 2).skip(2) = 2`
  - Error: error.InvalidFunctionCall

- **testSkip3**: `Patient.name.skip(1).given.trace('test') = 'Jim' | 'Peter' | 'James'`
  - Error: error.InvalidFunctionCall

- **testSkip4**: `Patient.name.skip(3).given.exists() = false`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªª

- Total: 11
- Passed: 0 (0.0%)
- Failed: 11
- Skipped: 0
- Time: 3.85ms

#### Failed Tests:

- **testSubstring1**: `'12345'.substring(2) = '345'`
  - Error: error.InvalidFunctionCall

- **testSubstring2**: `'12345'.substring(2,1) = '3'`
  - Error: error.InvalidFunctionCall

- **testSubstring3**: `'12345'.substring(2,5) = '345'`
  - Error: error.InvalidFunctionCall

- **testSubstring4**: `'12345'.substring(25).empty()`
  - Error: error.InvalidFunctionCall

- **testSubstring5**: `'12345'.substring(-1).empty()`
  - Error: error.InvalidFunctionCall

- **testSubstring7**: `'LogicalModel-Person'.substring(0, 12)`
  - Error: error.InvalidFunctionCall

- **testSubstring8**: `'LogicalModel-Person'.substring(0, 'LogicalModel-Person'.indexOf('-'))`
  - Error: error.InvalidFunctionCall

- **testSubstring9**: `{}.substring(25).empty() = true`
  - Error: error.InvalidFunctionCall

- **testSubstring10**: `Patient.name.family.first().substring(2, length()-5)`
  - Error: error.InvalidFunctionCall

- **testSubstring11**: `{}.substring({}).empty() = true`
  - Error: error.InvalidFunctionCall

- **testSubstring12**: `'string'.substring({}).empty() = true`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªª

- Total: 9
- Passed: 6 (66.7%)
- Failed: 3
- Skipped: 0
- Time: 3.25ms

#### Failed Tests:

- **testBooleanLogicOr6**: `(false or {}).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicOr8**: `({} or false).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicOr9**: `({} or {}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 1.91ms

#### Failed Tests:

- **testToDecimal1**: `'1'.toDecimal() = 1`
  - Error: error.InvalidFunctionCall

- **testToDecimal2**: `'-1'.toInteger() = -1`
  - Error: error.InvalidFunctionCall

- **testToDecimal3**: `'0'.toDecimal() = 0`
  - Error: error.InvalidFunctionCall

- **testToDecimal4**: `'0.0'.toDecimal() = 0.0`
  - Error: error.InvalidFunctionCall

- **testToDecimal5**: `'st'.toDecimal().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.09ms

#### Failed Tests:

- **testConformsTo1**: `conformsTo('http://hl7.org/fhir/StructureDefinition/Patient')`
  - Error: error.UnsupportedOperation

- **testConformsTo2**: `conformsTo('http://hl7.org/fhir/StructureDefinition/Person')`
  - Error: error.UnsupportedOperation

- **testConformsTo3**: `conformsTo('http://trash')`
  - Error: error.UnsupportedOperation

### ªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.76ms

#### Failed Tests:

- **testPeriodInvariantOld**: `Patient.identifier.period.all(start.hasValue().not() or end.hasValue().not() or (start <= end))`
  - Error: error.InvalidFunctionCall

- **testPeriodInvariantNew**: `Patient.identifier.period.all(start.empty() or end.empty() or (start.lowBoundary() < end.highBoundary()))`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªª

- Total: 30
- Passed: 0 (0.0%)
- Failed: 30
- Skipped: 0
- Time: 11.08ms

#### Failed Tests:

- **testGreatorOrEqual1**: `1 >= 2`
  - Error: error.TypeMismatch

- **testGreatorOrEqual2**: `1.0 >= 1.2`
  - Error: error.TypeMismatch

- **testGreatorOrEqual3**: `'a' >= 'b'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual4**: `'A' >= 'a'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual5**: `@2014-12-12 >= @2014-12-13`
  - Error: error.TypeMismatch

- **testGreatorOrEqual6**: `@2014-12-13T12:00:00 >= @2014-12-13T12:00:01`
  - Error: error.TypeMismatch

- **testGreatorOrEqual7**: `@T12:00:00 >= @T14:00:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual8**: `1 >= 1`
  - Error: error.TypeMismatch

- **testGreatorOrEqual9**: `1.0 >= 1.0`
  - Error: error.TypeMismatch

- **testGreatorOrEqual10**: `'a' >= 'a'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual11**: `'A' >= 'A'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual12**: `@2014-12-12 >= @2014-12-12`
  - Error: error.TypeMismatch

- **testGreatorOrEqual13**: `@2014-12-13T12:00:00 >= @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual14**: `@T12:00:00 >= @T12:00:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual15**: `2 >= 1`
  - Error: error.TypeMismatch

- **testGreatorOrEqual16**: `1.1 >= 1.0`
  - Error: error.TypeMismatch

- **testGreatorOrEqual17**: `'b' >= 'a'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual18**: `'B' >= 'A'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual19**: `@2014-12-13 >= @2014-12-12`
  - Error: error.TypeMismatch

- **testGreatorOrEqual20**: `@2014-12-13T12:00:01 >= @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual21**: `@T12:00:01 >= @T12:00:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual22**: `Observation.value >= 100 '[lb_av]'`
  - Error: error.TypeMismatch

- **testGreatorOrEqual23**: `@2018-03 >= @2018-03-01`
  - Error: error.TypeMismatch

- **testGreatorOrEqual24**: `@2018-03-01T10:30 >= @2018-03-01T10:30:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual25**: `@T10:30 >= @T10:30:00`
  - Error: error.TypeMismatch

- **testGreatorOrEqual26**: `@2018-03-01T10:30:00 >= @2018-03-01T10:30:00.0`
  - Error: error.TypeMismatch

- **testGreatorOrEqual27**: `@T10:30:00 >= @T10:30:00.0`
  - Error: error.TypeMismatch

- **testGreatorOrEqualEmpty1**: `1 >= {}`
  - Error: error.TypeMismatch

- **testGreatorOrEqualEmpty2**: `{} >= 1`
  - Error: error.TypeMismatch

- **testGreatorOrEqualEmpty3**: `{} >= {}`
  - Error: error.TypeMismatch

### ªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.78ms

#### Failed Tests:

- **testTrace1**: `name.given.trace('test').count() = 5`
  - Error: error.InvalidFunctionCall

- **testTrace2**: `name.trace('test', given).count() = 3`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 34
- Passed: 3 (8.8%)
- Failed: 31
- Skipped: 0
- Time: 12.63ms

#### Failed Tests:

- **testPlus4**: `'a'+'b' = 'ab'`
  - Error: error.TypeMismatch

- **testPlus5**: `'a'+{}`
  - Error: error.EmptyCollection

- **testPlusDate1**: `@1973-12-25 + 7 days`
  - Error: error.TypeMismatch

- **testPlusDate2**: `@1973-12-25 + 7.7 days`
  - Error: error.TypeMismatch

- **testPlusDate3**: `@1973-12-25T00:00:00.000+10:00 + 7 days`
  - Error: error.TypeMismatch

- **testPlusDate4**: `@1973-12-25T00:00:00.000+10:00 + 7.7 days`
  - Error: error.TypeMismatch

- **testPlusDate5**: `@1973-12-25T00:00:00.000+10:00 + 1 second`
  - Error: error.TypeMismatch

- **testPlusDate6**: `@1973-12-25T00:00:00.000+10:00 + 10 millisecond`
  - Error: error.TypeMismatch

- **testPlusDate7**: `@1973-12-25T00:00:00.000+10:00 + 1 minute`
  - Error: error.TypeMismatch

- **testPlusDate8**: `@1973-12-25T00:00:00.000+10:00 + 1 hour`
  - Error: error.TypeMismatch

- **testPlusDate9**: `@1973-12-25 + 1 day`
  - Error: error.TypeMismatch

- **testPlusDate10**: `@1973-12-25 + 1 month`
  - Error: error.TypeMismatch

- **testPlusDate11**: `@1973-12-25 + 1 week`
  - Error: error.TypeMismatch

- **testPlusDate12**: `@1973-12-25 + 1 year`
  - Error: error.TypeMismatch

- **testPlusDate13**: `@1973-12-25 + 1 'd'`
  - Error: error.TypeMismatch

- **testPlusDate14**: `@1973-12-25 + 1 'mo'`
  - Error: error.TypeMismatch

- **testPlusDate15**: `@1973-12-25 + 1 'wk'`
  - Error: error.TypeMismatch

- **testPlusDate16**: `@1973-12-25 + 1 'a'`
  - Error: error.TypeMismatch

- **testPlusDate17**: `@1975-12-25 + 1 'a'`
  - Error: error.TypeMismatch

- **testPlusDate18**: `@1973-12-25T00:00:00.000+10:00 + 1 's'`
  - Error: error.TypeMismatch

- **testPlusDate19**: `@1973-12-25T00:00:00.000+10:00 + 0.1 's'`
  - Error: error.TypeMismatch

- **testPlusDate20**: `@1973-12-25T00:00:00.000+10:00 + 10 'ms'`
  - Error: error.TypeMismatch

- **testPlusDate21**: `@1973-12-25T00:00:00.000+10:00 + 1 'min'`
  - Error: error.TypeMismatch

- **testPlusDate22**: `@1973-12-25T00:00:00.000+10:00 + 1 'h'`
  - Error: error.TypeMismatch

- **testPlus6**: `@1974-12-25 + 7`
  - Error: error.TypeMismatch

- **testPlusTime1**: `@T01:00:00 + 2 hours`
  - Error: error.TypeMismatch

- **testPlusTime2**: `@T23:00:00 + 2 hours`
  - Error: error.TypeMismatch

- **testPlusTime3**: `@T23:00:00 + 50 hours`
  - Error: error.TypeMismatch

- **testPlusEmpty1**: `1 + {}`
  - Error: error.EmptyCollection

- **testPlusEmpty2**: `{} + 1`
  - Error: error.EmptyCollection

- **testPlusEmpty3**: `{} + {}`
  - Error: error.EmptyCollection

### ªªªªªªªªªªªªªªª

- Total: 30
- Passed: 0 (0.0%)
- Failed: 30
- Skipped: 0
- Time: 10.80ms

#### Failed Tests:

- **testGreaterThan1**: `1 > 2`
  - Error: error.TypeMismatch

- **testGreaterThan2**: `1.0 > 1.2`
  - Error: error.TypeMismatch

- **testGreaterThan3**: `'a' > 'b'`
  - Error: error.TypeMismatch

- **testGreaterThan4**: `'A' > 'a'`
  - Error: error.TypeMismatch

- **testGreaterThan5**: `@2014-12-12 > @2014-12-13`
  - Error: error.TypeMismatch

- **testGreaterThan6**: `@2014-12-13T12:00:00 > @2014-12-13T12:00:01`
  - Error: error.TypeMismatch

- **testGreaterThan7**: `@T12:00:00 > @T14:00:00`
  - Error: error.TypeMismatch

- **testGreaterThan8**: `1 > 1`
  - Error: error.TypeMismatch

- **testGreaterThan9**: `1.0 > 1.0`
  - Error: error.TypeMismatch

- **testGreaterThan10**: `'a' > 'a'`
  - Error: error.TypeMismatch

- **testGreaterThan11**: `'A' > 'A'`
  - Error: error.TypeMismatch

- **testGreaterThan12**: `@2014-12-12 > @2014-12-12`
  - Error: error.TypeMismatch

- **testGreaterThan13**: `@2014-12-13T12:00:00 > @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testGreaterThan14**: `@T12:00:00 > @T12:00:00`
  - Error: error.TypeMismatch

- **testGreaterThan15**: `2 > 1`
  - Error: error.TypeMismatch

- **testGreaterThan16**: `1.1 > 1.0`
  - Error: error.TypeMismatch

- **testGreaterThan17**: `'b' > 'a'`
  - Error: error.TypeMismatch

- **testGreaterThan18**: `'B' > 'A'`
  - Error: error.TypeMismatch

- **testGreaterThan19**: `@2014-12-13 > @2014-12-12`
  - Error: error.TypeMismatch

- **testGreaterThan20**: `@2014-12-13T12:00:01 > @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testGreaterThan21**: `@T12:00:01 > @T12:00:00`
  - Error: error.TypeMismatch

- **testGreaterThan22**: `Observation.value > 100 '[lb_av]'`
  - Error: error.TypeMismatch

- **testGreaterThan23**: `@2018-03 > @2018-03-01`
  - Error: error.TypeMismatch

- **testGreaterThan24**: `@2018-03-01T10:30 > @2018-03-01T10:30:00`
  - Error: error.TypeMismatch

- **testGreaterThan25**: `@T10:30 > @T10:30:00`
  - Error: error.TypeMismatch

- **testGreaterThan26**: `@2018-03-01T10:30:00 > @2018-03-01T10:30:00.0`
  - Error: error.TypeMismatch

- **testGreaterThan27**: `@T10:30:00 > @T10:30:00.0`
  - Error: error.TypeMismatch

- **testGreaterThanEmpty1**: `1 > {}`
  - Error: error.TypeMismatch

- **testGreaterThanEmpty2**: `{} > 1`
  - Error: error.TypeMismatch

- **testGreaterThanEmpty3**: `{} > {}`
  - Error: error.TypeMismatch

### ªªªªªªªªªªªªª

- Total: 24
- Passed: 13 (54.2%)
- Failed: 11
- Skipped: 0
- Time: 9.27ms

#### Failed Tests:

- **testNEquality13**: `@2012-04-15 != @2012-04-15T10:00:00`
  - Expected: []
  - Actual: true

- **testNEquality15**: `@2012-04-15T15:30:31 != @2012-04-15T15:30:31.0`
  - Expected: [false]
  - Actual: []

- **testNEquality16**: `@2012-04-15T15:30:31 != @2012-04-15T15:30:31.1`
  - Expected: [true]
  - Actual: []

- **testNEquality17**: `@2012-04-15T15:00:00Z != @2012-04-15T10:00:00`
  - Expected: []
  - Actual: true

- **testNEquality18**: `@2012-04-15T15:00:00+02:00 != @2012-04-15T16:00:00+03:00`
  - Expected: [false]
  - Actual: true

- **testNEquality19**: `name != name`
  - Expected: [false]
  - Actual: true

- **testNEquality20**: `name.take(2) != name.take(2).first() | name.take(2).last()`
  - Error: error.InvalidFunctionCall

- **testNEquality21**: `name.take(2) != name.take(2).last() | name.take(2).first()`
  - Error: error.InvalidFunctionCall

- **testNEquality22**: `(1.2 / 1.8).round(2) != 0.6666667`
  - Error: error.InvalidFunctionCall

- **testNEquality23**: `(1.2 / 1.8).round(2) != 0.67`
  - Error: error.InvalidFunctionCall

- **testNEquality24**: `Observation.value != 185 'kg'`
  - Expected: [true]
  - Actual: []

### ªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.40ms

#### Failed Tests:

- **testFloor1**: `1.floor() = 1`
  - Error: error.InvalidFunctionCall

- **testFloor2**: `2.1.floor() = 2`
  - Error: error.InvalidFunctionCall

- **testFloor3**: `(-2.1).floor() = -3`
  - Error: error.InvalidFunctionCall

- **testFloorEmpty**: `{}.floor().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.39ms

#### Failed Tests:

- **testTruncate1**: `101.truncate() = 101`
  - Error: error.InvalidFunctionCall

- **testTruncate2**: `1.00000001.truncate() = 1`
  - Error: error.InvalidFunctionCall

- **testTruncate3**: `(-1.56).truncate() = -1`
  - Error: error.InvalidFunctionCall

- **testTruncateEmpty**: `{}.truncate().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.12ms

#### Failed Tests:

- **testIndexOf1**: `'LogicalModel-Person'.indexOf('-')`
  - Error: error.InvalidFunctionCall

- **testIndexOf2**: `'LogicalModel-Person'.indexOf('z')`
  - Error: error.InvalidFunctionCall

- **testIndexOf3**: `'LogicalModel-Person'.indexOf('')`
  - Error: error.InvalidFunctionCall

- **testIndexOf5**: `'LogicalModel-Person'.indexOf({}).empty() = true`
  - Error: error.InvalidFunctionCall

- **testIndexOf4**: `{}.indexOf('-').empty() = true`
  - Error: error.InvalidFunctionCall

- **testIndexOf6**: `{}.indexOf({}).empty() = true`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªª

- Total: 11
- Passed: 0 (0.0%)
- Failed: 11
- Skipped: 0
- Time: 4.06ms

#### Failed Tests:

- **testContainsString1**: `'12345'.contains('6') = false`
  - Error: error.ExpectedIdentifier

- **testContainsString2**: `'12345'.contains('5') = true`
  - Error: error.ExpectedIdentifier

- **testContainsString3**: `'12345'.contains('45') = true`
  - Error: error.ExpectedIdentifier

- **testContainsString4**: `'12345'.contains('35') = false`
  - Error: error.ExpectedIdentifier

- **testContainsString5**: `'12345'.contains('12345') = true`
  - Error: error.ExpectedIdentifier

- **testContainsString6**: `'12345'.contains('012345') = false`
  - Error: error.ExpectedIdentifier

- **testContainsString7**: `'12345'.contains('') = true`
  - Error: error.ExpectedIdentifier

- **testContainsString8**: `{}.contains('a').empty() = true`
  - Error: error.ExpectedIdentifier

- **testContainsString9**: `{}.contains('').empty() = true`
  - Error: error.ExpectedIdentifier

- **testContainsString10**: `'123456789'.contains(length().toString())`
  - Error: error.ExpectedIdentifier

- **testContainsNonString1**: `Appointment.identifier.contains('rand')`
  - Error: error.ExpectedIdentifier

### ªªªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.50ms

#### Failed Tests:

- **testIntersect1**: `(1 | 2 | 3).intersect(2 | 4) = 2`
  - Error: error.InvalidFunctionCall

- **testIntersect2**: `(1 | 2).intersect(4).empty()`
  - Error: error.InvalidFunctionCall

- **testIntersect3**: `(1 | 2).intersect({}).empty()`
  - Error: error.InvalidFunctionCall

- **testIntersect4**: `1.combine(1).intersect(1).count() = 1`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªª

- Total: 22
- Passed: 17 (77.3%)
- Failed: 5
- Skipped: 0
- Time: 8.23ms

#### Failed Tests:

- **testNotEquivalent6**: `'a' !~ 'A'`
  - Expected: [false]
  - Actual: true

- **testNotEquivalent17**: `@2012-04-15T15:30:31 !~ @2012-04-15T15:30:31.0`
  - Expected: [false]
  - Actual: true

- **testNotEquivalent19**: `name !~ name`
  - Expected: [false]
  - Actual: true

- **testNotEquivalent20**: `name.take(2).given !~ name.take(2).first().given | name.take(2).last().given`
  - Error: error.InvalidFunctionCall

- **testNotEquivalent21**: `name.take(2).given !~ name.take(2).last().given | name.take(2).first().given`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 9
- Passed: 0 (0.0%)
- Failed: 9
- Skipped: 0
- Time: 4.09ms

#### Failed Tests:

- **testComment1**: `2 + 2 // This is a single-line comment + 4`
  - Error: error.TypeMismatch

- **testComment2**: `// This is a multi line comment using // that
  // should not fail during parsing
  2+2`
  - Error: error.EmptyCollection

- **testComment3**: `2 + 2 
      /*
This is a multi-line comment
Any text enclosed within is ignored
+2
*/`
  - Error: error.TypeMismatch

- **testComment4**: `2 + 2 
      /*
This is a multi-line comment
Any text enclosed within is ignored
*/
+2`
  - Error: error.TypeMismatch

- **testComment5**: `/*
This is a multi-line comment
Any text enclosed within is ignored
*/
2+2`
  - Error: error.EmptyCollection

- **testComment6**: `2 // comment
/ 2`
  - Error: error.TypeMismatch

- **testComment7**: `2 + 2 /`
  - Error: error.TypeMismatch

- **testComment8**: `2 + 2 /* not finished`
  - Error: error.TypeMismatch

- **testComment9**: `2 + /* inline $@%^+ * */ 2 = 4`
  - Error: error.EmptyCollection

### ªªªªªªª

- Total: 8
- Passed: 3 (37.5%)
- Failed: 5
- Skipped: 0
- Time: 2.86ms

#### Failed Tests:

- **testMod4**: `2.2 mod 1.8 = 0.4`
  - Error: error.TypeMismatch

- **testMod5**: `5 mod 0`
  - Error: error.DivisionByZero

- **testModEmpty1**: `1 mod {}`
  - Error: error.EmptyCollection

- **testModEmpty2**: `{} mod 1`
  - Error: error.EmptyCollection

- **testModEmpty3**: `{} mod {}`
  - Error: error.EmptyCollection

### ªªªªªªªªªªªªªªªªªªªªª

- Total: 6
- Passed: 1 (16.7%)
- Failed: 5
- Skipped: 0
- Time: 2.49ms

#### Failed Tests:

- **testCollectionBoolean1**: `iif(1 | 2 | 3, true, false)`
  - Error: error.UnsupportedOperation

- **testCollectionBoolean2**: `iif({}, true, false)`
  - Error: error.EmptyCollection

- **testCollectionBoolean4**: `iif({} | true, true, false)`
  - Error: error.UnsupportedOperation

- **testCollectionBoolean5**: `iif(true, true, 1/0)`
  - Error: error.DivisionByZero

- **testCollectionBoolean6**: `iif(false, 1/0, true)`
  - Error: error.DivisionByZero

### ªªªªªªªªª

- Total: 11
- Passed: 2 (18.2%)
- Failed: 9
- Skipped: 0
- Time: 3.99ms

#### Failed Tests:

- **testMinus3**: `1.8 - 1.2 = 0.6`
  - Expected: [true]
  - Actual: false

- **testMinus4**: `'a'-'b' = 'ab'`
  - Error: error.TypeMismatch

- **testMinus5**: `@1974-12-25 - 1 'month'`
  - Error: error.TypeMismatch

- **testMinus6**: `@1974-12-25 - 1 'cm'`
  - Error: error.TypeMismatch

- **testMinus7**: `@T00:30:00 - 1 hour`
  - Error: error.TypeMismatch

- **testMinus8**: `@T01:00:00 - 2 hours`
  - Error: error.TypeMismatch

- **testMinusEmpty1**: `1 - {}`
  - Error: error.EmptyCollection

- **testMinusEmpty2**: `{} - 1`
  - Error: error.EmptyCollection

- **testMinusEmpty3**: `{} - {}`
  - Error: error.EmptyCollection

### ªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.66ms

#### Failed Tests:

- **testPower1**: `2.power(3) = 8`
  - Error: error.InvalidFunctionCall

- **testPower2**: `2.5.power(2) = 6.25`
  - Error: error.InvalidFunctionCall

- **testPower3**: `(-1).power(0.5)`
  - Error: error.InvalidFunctionCall

- **testPowerEmpty**: `{}.power(2).empty()`
  - Error: error.InvalidFunctionCall

- **testPowerEmpty2**: `{}.power({}).empty()`
  - Error: error.InvalidFunctionCall

- **testPowerEmpty3**: `2.5.power({}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 2.54ms

#### Failed Tests:

- **testHasTemplateId1**: `hasTemplateIdOf('http://hl7.org/cda/us/ccda/StructureDefinition/ContinuityofCareDocumentCCD')`
  - Error: error.UnsupportedOperation

- **testHasTemplateId2**: `ClinicalDocument.hasTemplateIdOf('http://hl7.org/cda/us/ccda/StructureDefinition/ContinuityofCareDocumentCCD')`
  - Error: error.InvalidFunctionCall

- **testHasTemplateId3**: `recordTarget.patientRole.hasTemplateIdOf('http://hl7.org/cda/us/ccda/StructureDefinition/ContinuityofCareDocumentCCD')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.73ms

#### Failed Tests:

- **from-zulip-1**: `(true and 'foo').empty()`
  - Error: error.InvalidFunctionCall

- **from-zulip-2**: `(true | 'foo').allTrue()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 99
- Passed: 0 (0.0%)
- Failed: 99
- Skipped: 0
- Time: 37.44ms

#### Failed Tests:

- **testStringYearConvertsToDate**: `'2015'.convertsToDate()`
  - Error: error.InvalidFunctionCall

- **testStringMonthConvertsToDate**: `'2015-02'.convertsToDate()`
  - Error: error.InvalidFunctionCall

- **testStringDayConvertsToDate**: `'2015-02-04'.convertsToDate()`
  - Error: error.InvalidFunctionCall

- **testStringYearConvertsToDateTime**: `'2015'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringMonthConvertsToDateTime**: `'2015-02'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringDayConvertsToDateTime**: `'2015-02-04'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringHourConvertsToDateTime**: `'2015-02-04T14'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringMinuteConvertsToDateTime**: `'2015-02-04T14:34'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringSecondConvertsToDateTime**: `'2015-02-04T14:34:28'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringMillisecondConvertsToDateTime**: `'2015-02-04T14:34:28.123'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringUTCConvertsToDateTime**: `'2015-02-04T14:34:28Z'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringTZConvertsToDateTime**: `'2015-02-04T14:34:28+10:00'.convertsToDateTime()`
  - Error: error.InvalidFunctionCall

- **testStringHourConvertsToTime**: `'14'.convertsToTime()`
  - Error: error.InvalidFunctionCall

- **testStringMinuteConvertsToTime**: `'14:34'.convertsToTime()`
  - Error: error.InvalidFunctionCall

- **testStringSecondConvertsToTime**: `'14:34:28'.convertsToTime()`
  - Error: error.InvalidFunctionCall

- **testStringMillisecondConvertsToTime**: `'14:34:28.123'.convertsToTime()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToInteger**: `1.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralIsInteger**: `1.is(Integer)`
  - Error: error.ExpectedIdentifier

- **testIntegerLiteralIsSystemInteger**: `1.is(System.Integer)`
  - Error: error.ExpectedIdentifier

- **testStringLiteralConvertsToInteger**: `'1'.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testStringLiteralConvertsToIntegerFalse**: `'a'.convertsToInteger().not()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalConvertsToIntegerFalse**: `'1.0'.convertsToInteger().not()`
  - Error: error.InvalidFunctionCall

- **testStringLiteralIsNotInteger**: `'1'.is(Integer).not()`
  - Error: error.ExpectedIdentifier

- **testBooleanLiteralConvertsToInteger**: `true.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralIsNotInteger**: `true.is(Integer).not()`
  - Error: error.ExpectedIdentifier

- **testDateIsNotInteger**: `@2013-04-05.is(Integer).not()`
  - Error: error.ExpectedIdentifier

- **testIntegerLiteralToInteger**: `1.toInteger() = 1`
  - Error: error.InvalidFunctionCall

- **testStringIntegerLiteralToInteger**: `'1'.toInteger() = 1`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToInteger**: `'1.1'.toInteger() = {}`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToIntegerIsEmpty**: `'1.1'.toInteger().empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralToInteger**: `true.toInteger() = 1`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToDecimal**: `1.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralIsNotDecimal**: `1.is(Decimal).not()`
  - Error: error.ExpectedIdentifier

- **testDecimalLiteralConvertsToDecimal**: `1.0.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralIsDecimal**: `1.0.is(Decimal)`
  - Error: error.ExpectedIdentifier

- **testStringIntegerLiteralConvertsToDecimal**: `'1'.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testStringIntegerLiteralIsNotDecimal**: `'1'.is(Decimal).not()`
  - Error: error.ExpectedIdentifier

- **testStringLiteralConvertsToDecimalFalse**: `'1.a'.convertsToDecimal().not()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralConvertsToDecimal**: `'1.0'.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralIsNotDecimal**: `'1.0'.is(Decimal).not()`
  - Error: error.ExpectedIdentifier

- **testBooleanLiteralConvertsToDecimal**: `true.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralIsNotDecimal**: `true.is(Decimal).not()`
  - Error: error.ExpectedIdentifier

- **testIntegerLiteralToDecimal**: `1.toDecimal() = 1.0`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralToDeciamlEquivalent**: `1.toDecimal() ~ 1.0`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToDecimal**: `1.0.toDecimal() = 1.0`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToDecimalEqual**: `'1.1'.toDecimal() = 1.1`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralToDecimal**: `true.toDecimal() = 1`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToQuantity**: `1.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralIsNotQuantity**: `1.is(Quantity).not()`
  - Error: error.ExpectedIdentifier

- **testDecimalLiteralConvertsToQuantity**: `1.0.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralIsNotQuantity**: `1.0.is(System.Quantity).not()`
  - Error: error.ExpectedIdentifier

- **testStringIntegerLiteralConvertsToQuantity**: `'1'.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testStringIntegerLiteralIsNotQuantity**: `'1'.is(System.Quantity).not()`
  - Error: error.ExpectedIdentifier

- **testStringQuantityLiteralConvertsToQuantity**: `'1 day'.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testStringQuantityWeekConvertsToQuantity**: `'1 \'wk\''.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testStringQuantityWeekConvertsToQuantityFalse**: `'1 wk'.convertsToQuantity().not()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralConvertsToQuantityFalse**: `'1.a'.convertsToQuantity().not()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralConvertsToQuantity**: `'1.0'.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralIsNotSystemQuantity**: `'1.0'.is(System.Quantity).not()`
  - Error: error.ExpectedIdentifier

- **testBooleanLiteralConvertsToQuantity**: `true.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralIsNotSystemQuantity**: `true.is(System.Quantity).not()`
  - Error: error.ExpectedIdentifier

- **testIntegerLiteralToQuantity**: `1.toQuantity() = 1 '1'`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToQuantity**: `1.0.toQuantity() = 1.0 '1'`
  - Error: error.InvalidFunctionCall

- **testStringIntegerLiteralToQuantity**: `'1'.toQuantity()`
  - Error: error.InvalidFunctionCall

- **testStringQuantityLiteralToQuantity**: `'1 day'.toQuantity() = 1 day`
  - Error: error.InvalidFunctionCall

- **testStringQuantityDayLiteralToQuantity**: `'1 day'.toQuantity() = 1 'd'`
  - Error: error.InvalidFunctionCall

- **testStringQuantityWeekLiteralToQuantity**: `'1 \'wk\''.toQuantity() = 1 week`
  - Error: error.InvalidFunctionCall

- **testStringQuantityMonthLiteralToQuantity**: `'1 \'mo\''.toQuantity() = 1 month`
  - Error: error.InvalidFunctionCall

- **testStringQuantityYearLiteralToQuantity**: `'1 \'a\''.toQuantity() = 1 year`
  - Error: error.InvalidFunctionCall

- **testStringDecimalLiteralToQuantity**: `'1.0'.toQuantity() ~ 1 '1'`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToBoolean**: `1.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToBooleanFalse**: `2.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testNegativeIntegerLiteralConvertsToBooleanFalse**: `(-1).convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralFalseConvertsToBoolean**: `0.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralConvertsToBoolean**: `1.0.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testStringTrueLiteralConvertsToBoolean**: `'true'.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testStringFalseLiteralConvertsToBoolean**: `'false'.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testStringFalseLiteralAlsoConvertsToBoolean**: `'False'.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testTrueLiteralConvertsToBoolean**: `true.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testFalseLiteralConvertsToBoolean**: `false.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralToBoolean**: `1.toBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralToBooleanEmpty**: `2.toBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralToBooleanFalse**: `0.toBoolean()`
  - Error: error.InvalidFunctionCall

- **testStringTrueToBoolean**: `'true'.toBoolean()`
  - Error: error.InvalidFunctionCall

- **testStringFalseToBoolean**: `'false'.toBoolean()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralConvertsToString**: `1.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralIsNotString**: `1.is(String).not()`
  - Error: error.ExpectedIdentifier

- **testNegativeIntegerLiteralConvertsToString**: `(-1).convertsToString()`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralConvertsToString**: `1.0.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testStringLiteralConvertsToString**: `'true'.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralConvertsToString**: `true.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testQuantityLiteralConvertsToString**: `1 'wk'.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testIntegerLiteralToString**: `1.toString()`
  - Error: error.InvalidFunctionCall

- **testNegativeIntegerLiteralToString**: `(-1).toString()`
  - Error: error.InvalidFunctionCall

- **testDecimalLiteralToString**: `1.0.toString()`
  - Error: error.InvalidFunctionCall

- **testStringLiteralToString**: `'true'.toString()`
  - Error: error.InvalidFunctionCall

- **testBooleanLiteralToString**: `true.toString()`
  - Error: error.InvalidFunctionCall

- **testQuantityLiteralWkToString**: `1 'wk'.toString()`
  - Error: error.InvalidFunctionCall

- **testQuantityLiteralWeekToString**: `1 week.toString()`
  - Expected: ['1 week']
  - Actual: 1

### ªªªªªªªªªªªªªªªªªª

- Total: 9
- Passed: 6 (66.7%)
- Failed: 3
- Skipped: 0
- Time: 3.32ms

#### Failed Tests:

- **testBooleanImplies3**: `(true implies {}).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanImplies8**: `({} implies false).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanImplies9**: `({} implies {}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 1.82ms

#### Failed Tests:

- **testToInteger1**: `'1'.toInteger() = 1`
  - Error: error.InvalidFunctionCall

- **testToInteger2**: `'-1'.toInteger() = -1`
  - Error: error.InvalidFunctionCall

- **testToInteger3**: `'0'.toInteger() = 0`
  - Error: error.InvalidFunctionCall

- **testToInteger4**: `'0.0'.toInteger().empty()`
  - Error: error.InvalidFunctionCall

- **testToInteger5**: `'st'.toInteger().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªª

- Total: 13
- Passed: 0 (0.0%)
- Failed: 13
- Skipped: 0
- Time: 4.76ms

#### Failed Tests:

- **testStartsWith1**: `'12345'.startsWith('2') = false`
  - Error: error.InvalidFunctionCall

- **testStartsWith2**: `'12345'.startsWith('1') = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith3**: `'12345'.startsWith('12') = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith4**: `'12345'.startsWith('13') = false`
  - Error: error.InvalidFunctionCall

- **testStartsWith5**: `'12345'.startsWith('12345') = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith6**: `'12345'.startsWith('123456') = false`
  - Error: error.InvalidFunctionCall

- **testStartsWith7**: `'12345'.startsWith('') = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith8**: `{}.startsWith('1').empty() = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith9**: `{}.startsWith('').empty() = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith10**: `''.startsWith('') = true`
  - Error: error.InvalidFunctionCall

- **testStartsWith11**: `{}.startsWith('').exists() = false`
  - Error: error.InvalidFunctionCall

- **testStartsWith12**: `'987654321'.startsWith(length().toString())`
  - Error: error.InvalidFunctionCall

- **testStartsWithNonString1**: `Appointment.identifier.startsWith('rand')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 30
- Passed: 0 (0.0%)
- Failed: 30
- Skipped: 0
- Time: 10.78ms

#### Failed Tests:

- **testLessThan1**: `1 < 2`
  - Error: error.TypeMismatch

- **testLessThan2**: `1.0 < 1.2`
  - Error: error.TypeMismatch

- **testLessThan3**: `'a' < 'b'`
  - Error: error.TypeMismatch

- **testLessThan4**: `'A' < 'a'`
  - Error: error.TypeMismatch

- **testLessThan5**: `@2014-12-12 < @2014-12-13`
  - Error: error.TypeMismatch

- **testLessThan6**: `@2014-12-13T12:00:00 < @2014-12-13T12:00:01`
  - Error: error.TypeMismatch

- **testLessThan7**: `@T12:00:00 < @T14:00:00`
  - Error: error.TypeMismatch

- **testLessThan8**: `1 < 1`
  - Error: error.TypeMismatch

- **testLessThan9**: `1.0 < 1.0`
  - Error: error.TypeMismatch

- **testLessThan10**: `'a' < 'a'`
  - Error: error.TypeMismatch

- **testLessThan11**: `'A' < 'A'`
  - Error: error.TypeMismatch

- **testLessThan12**: `@2014-12-12 < @2014-12-12`
  - Error: error.TypeMismatch

- **testLessThan13**: `@2014-12-13T12:00:00 < @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testLessThan14**: `@T12:00:00 < @T12:00:00`
  - Error: error.TypeMismatch

- **testLessThan15**: `2 < 1`
  - Error: error.TypeMismatch

- **testLessThan16**: `1.1 < 1.0`
  - Error: error.TypeMismatch

- **testLessThan17**: `'b' < 'a'`
  - Error: error.TypeMismatch

- **testLessThan18**: `'B' < 'A'`
  - Error: error.TypeMismatch

- **testLessThan19**: `@2014-12-13 < @2014-12-12`
  - Error: error.TypeMismatch

- **testLessThan20**: `@2014-12-13T12:00:01 < @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testLessThan21**: `@T12:00:01 < @T12:00:00`
  - Error: error.TypeMismatch

- **testLessThan22**: `Observation.value < 200 '[lb_av]'`
  - Error: error.TypeMismatch

- **testLessThan23**: `@2018-03 < @2018-03-01`
  - Error: error.TypeMismatch

- **testLessThan24**: `@2018-03-01T10:30 < @2018-03-01T10:30:00`
  - Error: error.TypeMismatch

- **testLessThan25**: `@T10:30 < @T10:30:00`
  - Error: error.TypeMismatch

- **testLessThan26**: `@2018-03-01T10:30:00 < @2018-03-01T10:30:00.0`
  - Error: error.TypeMismatch

- **testLessThan27**: `@T10:30:00 < @T10:30:00.0`
  - Error: error.TypeMismatch

- **testLessThanEmpty1**: `1 < {}`
  - Error: error.TypeMismatch

- **testLessThanEmpty2**: `{} < 1`
  - Error: error.TypeMismatch

- **testLessThanEmpty3**: `{} < {}`
  - Error: error.TypeMismatch

### ªªªªªªªªªªª

- Total: 28
- Passed: 0 (0.0%)
- Failed: 28
- Skipped: 0
- Time: 4.29ms

#### Failed Tests:

- **LowBoundaryDecimalDefault**: `1.587.lowBoundary()`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal1**: `1.587.lowBoundary(6)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal2**: `1.587.lowBoundary(2)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal3**: `1.587.lowBoundary(-1)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal4**: `1.587.lowBoundary(0)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal5**: `1.587.lowBoundary(32)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimalDefault**: `(-1.587).lowBoundary()`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimal1**: `(-1.587).lowBoundary(6)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimal2**: `(-1.587).lowBoundary(2)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimal3**: `(-1.587).lowBoundary(-1)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimal4**: `(-1.587).lowBoundary(0)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryNegDecimal5**: `(-1.587).lowBoundary(32)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal6**: `1.587.lowBoundary(39)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal7**: `1.toDecimal().lowBoundary()`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal8**: `1.lowBoundary(0)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal9**: `1.lowBoundary(5)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal10**: `12.587.lowBoundary(2)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal11**: `12.500.lowBoundary(4)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal12**: `120.lowBoundary(2)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal13**: `(-120).lowBoundary(2)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal14**: `0.0034.lowBoundary(1)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDecimal15**: `(-0.0034).lowBoundary(1)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryQuantity**: `1.587 'cm'.lowBoundary(8)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDateMonth**: `@2014.lowBoundary(6)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDateTimeMillisecond1**: `@2014-01-01T08.lowBoundary(17)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDateTimeMillisecond2**: `@2014-01-01T08:05+08:00.lowBoundary(17)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryDateTimeMillisecond3**: `@2014-01-01T08.lowBoundary(8)`
  - Error: error.InvalidFunctionCall

- **LowBoundaryTimeMillisecond**: `@T10:30.lowBoundary(9)`
  - Error: error.InvalidFunctionCall

### ªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 1.75ms

#### Failed Tests:

- **testLog1**: `16.log(2) = 4.0`
  - Error: error.InvalidFunctionCall

- **testLog2**: `100.0.log(10.0) = 2.0`
  - Error: error.InvalidFunctionCall

- **testLogEmpty**: `{}.log(10).empty()`
  - Error: error.InvalidFunctionCall

- **testLogEmpty2**: `{}.log({}).empty()`
  - Error: error.InvalidFunctionCall

- **testLogEmpty3**: `16.log({}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 9
- Passed: 4 (44.4%)
- Failed: 5
- Skipped: 0
- Time: 3.27ms

#### Failed Tests:

- **testDivide5**: `(1.2 / 1.8).round(2) = 0.67`
  - Error: error.InvalidFunctionCall

- **testDivide6**: `1 / 0`
  - Error: error.DivisionByZero

- **testDivideEmpty1**: `1 / {}`
  - Error: error.EmptyCollection

- **testDivideEmpty2**: `{} / 1`
  - Error: error.EmptyCollection

- **testDivideEmpty3**: `{} / {}`
  - Error: error.EmptyCollection

### ªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.43ms

#### Failed Tests:

- **testAbs1**: `(-5).abs() = 5`
  - Error: error.InvalidFunctionCall

- **testAbs2**: `(-5.5).abs() = 5.5`
  - Error: error.InvalidFunctionCall

- **testAbs3**: `(-5.5 'mg').abs() = 5.5 'mg'`
  - Error: error.InvalidFunctionCall

- **testAbsEmpty**: `{}.abs().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªª

- Total: 6
- Passed: 1 (16.7%)
- Failed: 5
- Skipped: 0
- Time: 2.13ms

#### Failed Tests:

- **testPrecedence1**: `-1.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testPrecedence3**: `1 > 2 is Boolean`
  - Error: error.TypeMismatch

- **testPrecedence4**: `1 | 1 is Integer`
  - Error: error.UnsupportedOperation

- **testPrecedence5**: `true and '0215' in ('0215' | '0216')`
  - Error: error.UnsupportedOperation

- **testPrecedence6**: `category.exists(coding.exists(system = 'http://terminology.hl7.org/CodeSystem/observation-category' and code.trace('c') in ('vital-signs' | 'vital-signs2').trace('codes')))`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 2.17ms

#### Failed Tests:

- **testToString1**: `1.toString() = '1'`
  - Error: error.InvalidFunctionCall

- **testToString2**: `'-1'.toInteger() = -1`
  - Error: error.InvalidFunctionCall

- **testToString3**: `0.toString() = '0'`
  - Error: error.InvalidFunctionCall

- **testToString4**: `0.0.toString() = '0.0'`
  - Error: error.InvalidFunctionCall

- **testToString5**: `@2014-12-14.toString() = '2014-12-14'`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.73ms

#### Failed Tests:

- **testToday1**: `Patient.birthDate < today()`
  - Error: error.TypeMismatch

- **testToday2**: `today().toString().length() = 10`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.15ms

#### Failed Tests:

- **testCombine1**: `concept.code.combine($this.descendants().concept.code).isDistinct()`
  - Error: error.InvalidFunctionCall

- **testCombine2**: `name.given.combine(name.family).exclude('Jim')`
  - Error: error.InvalidFunctionCall

- **testCombine3**: `name.given.combine($this.name.family).exclude('Jim')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.74ms

#### Failed Tests:

- **testFirstLast1**: `Patient.name.first().given = 'Peter' | 'James'`
  - Error: error.InvalidFunctionCall

- **testFirstLast2**: `Patient.name.last().given = 'Peter' | 'James'`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.74ms

#### Failed Tests:

- **testTail1**: `(0 | 1 | 2).tail() = 1 | 2`
  - Error: error.InvalidFunctionCall

- **testTail2**: `Patient.name.tail().given = 'Jim' | 'Peter' | 'James'`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªªª

- Total: 9
- Passed: 6 (66.7%)
- Failed: 3
- Skipped: 0
- Time: 3.35ms

#### Failed Tests:

- **testBooleanLogicAnd3**: `(true and {}).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicAnd7**: `({} and true).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicAnd9**: `({} and {}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªª

- Total: 24
- Passed: 0 (0.0%)
- Failed: 24
- Skipped: 0
- Time: 10.31ms

#### Failed Tests:

- **testFHIRPathIsFunction1**: `Patient.gender.is(code)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction2**: `Patient.gender.is(string)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction3**: `Patient.gender.is(id)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction4**: `Questionnaire.url.is(uri)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction5**: `Questionnaire.url.is(url)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction6**: `ValueSet.version.is(string)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction7**: `ValueSet.version.is(code)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathIsFunction8**: `Observation.extension('http://example.com/fhir/StructureDefinition/patient-age').value is Age`
  - Error: error.InvalidFunctionCall

- **testFHIRPathIsFunction9**: `Observation.extension('http://example.com/fhir/StructureDefinition/patient-age').value is Quantity`
  - Error: error.InvalidFunctionCall

- **testFHIRPathIsFunction10**: `Observation.extension('http://example.com/fhir/StructureDefinition/patient-age').value is Duration`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction11**: `Patient.gender.as(string)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction12**: `Patient.gender.as(code)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction13**: `Patient.gender.as(id)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction14**: `ValueSet.version.as(string)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction15**: `ValueSet.version.as(code)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction16**: `Patient.gender.ofType(string)`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction17**: `Patient.gender.ofType(code)`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction18**: `Patient.gender.ofType(id)`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction19**: `ValueSet.version.ofType(string)`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction20**: `ValueSet.version.ofType(code)`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction21**: `Patient.name.as(HumanName).use`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction22**: `Patient.name.ofType(HumanName).use`
  - Error: error.InvalidFunctionCall

- **testFHIRPathAsFunction23**: `Patient.gender.as(string1)`
  - Error: error.ExpectedIdentifier

- **testFHIRPathAsFunction24**: `Patient.gender.ofType(string1)`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.42ms

#### Failed Tests:

- **testConcatenate1**: `'a' & 'b' = 'ab'`
  - Error: error.UnsupportedOperation

- **testConcatenate2**: `'1' & {} = '1'`
  - Error: error.UnsupportedOperation

- **testConcatenate3**: `{} & 'b' = 'b'`
  - Error: error.UnsupportedOperation

- **testConcatenate4**: `(1 | 2 | 3) & 'b' = '1,2,3b'`
  - Error: error.UnsupportedOperation

### ªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.12ms

#### Failed Tests:

- **testTrim1**: `'123456'.trim().length() = 6`
  - Error: error.InvalidFunctionCall

- **testTrim2**: `'123 456'.trim().length() = 7`
  - Error: error.InvalidFunctionCall

- **testTrim3**: `' 123456 '.trim().length() = 6`
  - Error: error.InvalidFunctionCall

- **testTrim4**: `'  '.trim().length() = 0`
  - Error: error.InvalidFunctionCall

- **testTrim5**: `{}.trim().empty() = true`
  - Error: error.InvalidFunctionCall

- **testTrim6**: `'      '.trim() = ''`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 28
- Passed: 16 (57.1%)
- Failed: 12
- Skipped: 0
- Time: 11.01ms

#### Failed Tests:

- **testEquality5**: `(1 | 2) = (1 | 2)`
  - Error: error.UnsupportedOperation

- **testEquality6**: `(1 | 2 | 3) = (1 | 2 | 3)`
  - Error: error.UnsupportedOperation

- **testEquality7**: `(1 | 1) = (1 | 2 | {})`
  - Error: error.UnsupportedOperation

- **testEquality19**: `@2012-04-15 = @2012-04-15T10:00:00`
  - Expected: []
  - Actual: false

- **testEquality21**: `@2012-04-15T15:30:31 = @2012-04-15T15:30:31.0`
  - Expected: [true]
  - Actual: []

- **testEquality22**: `@2012-04-15T15:30:31 = @2012-04-15T15:30:31.1`
  - Expected: [false]
  - Actual: []

- **testEquality23**: `@2012-04-15T15:00:00Z = @2012-04-15T10:00:00`
  - Expected: []
  - Actual: false

- **testEquality24**: `@2012-04-15T15:00:00+02:00 = @2012-04-15T16:00:00+03:00`
  - Expected: [true]
  - Actual: false

- **testEquality25**: `name = name`
  - Expected: [true]
  - Actual: false

- **testEquality26**: `name.take(2) = name.take(2).first() | name.take(2).last()`
  - Error: error.InvalidFunctionCall

- **testEquality27**: `name.take(2) = name.take(2).last() | name.take(2).first()`
  - Error: error.InvalidFunctionCall

- **testEquality28**: `Observation.value = 185 '[lb_av]'`
  - Expected: [true]
  - Actual: []

### ªªªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.77ms

#### Failed Tests:

- **testAggregate1**: `(1|2|3|4|5|6|7|8|9).aggregate($this+$total, 0) = 45`
  - Error: error.InvalidFunctionCall

- **testAggregate2**: `(1|2|3|4|5|6|7|8|9).aggregate($this+$total, 2) = 47`
  - Error: error.InvalidFunctionCall

- **testAggregate3**: `(1|2|3|4|5|6|7|8|9).aggregate(iif($total.empty(), $this, iif($this < $total, $this, $total))) = 1`
  - Error: error.InvalidFunctionCall

- **testAggregate4**: `(1|2|3|4|5|6|7|8|9).aggregate(iif($total.empty(), $this, iif($this > $total, $this, $total))) = 9`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.38ms

#### Failed Tests:

- **testSubSetOf1**: `Patient.name.first().subsetOf($this.name)`
  - Error: error.InvalidFunctionCall

- **testSubSetOf2**: `Patient.name.subsetOf($this.name.first()).not()`
  - Error: error.InvalidFunctionCall

- **testSubSetOf3**: `supportingInfo.where(category.coding.code = 'additionalbodysite').sequence.subsetOf($this.item.informationSequence)`
  - Error: error.ExpectedIdentifier

### ªªªªªªª

- Total: 8
- Passed: 3 (37.5%)
- Failed: 5
- Skipped: 0
- Time: 3.00ms

#### Failed Tests:

- **testDiv4**: `2.2 div 1.8 = 1`
  - Error: error.TypeMismatch

- **testDiv5**: `5 div 0`
  - Error: error.DivisionByZero

- **testDivEmpty1**: `1 div {}`
  - Error: error.EmptyCollection

- **testDivEmpty2**: `{} div 1`
  - Error: error.EmptyCollection

- **testDivEmpty3**: `{} div {}`
  - Error: error.EmptyCollection

### ªªªªªª

- Total: 8
- Passed: 0 (0.0%)
- Failed: 8
- Skipped: 0
- Time: 3.03ms

#### Failed Tests:

- **testIn1**: `1 in (1 | 2 | 3)`
  - Error: error.UnsupportedOperation

- **testIn2**: `1 in (2 | 3)`
  - Error: error.UnsupportedOperation

- **testIn3**: `'a' in ('a' | 'c' | 'd')`
  - Error: error.UnsupportedOperation

- **testIn4**: `'b' in ('a' | 'c' | 'd')`
  - Error: error.UnsupportedOperation

- **testIn5**: `('a' | 'c' | 'd') in 'b'`
  - Error: error.UnsupportedOperation

- **testInEmptyCollection**: `1 in {}`
  - Error: error.UnsupportedOperation

- **testInEmptyValue**: `{} in (1 | 2 | 3)`
  - Error: error.UnsupportedOperation

- **testInEmptyBoth**: `{} in {}`
  - Error: error.UnsupportedOperation

### ªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 0.42ms

#### Failed Tests:

- **Comparable1**: `1 'cm'.comparable(1 '[in_i]')`
  - Error: error.InvalidFunctionCall

- **Comparable2**: `1 'cm'.comparable(1 '[s]')`
  - Error: error.InvalidFunctionCall

- **Comparable3**: `1 'cm'.comparable(1 's')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 11
- Passed: 1 (9.1%)
- Failed: 10
- Skipped: 0
- Time: 4.04ms

#### Failed Tests:

- **testQuantity1**: `4.0000 'g' = 4000.0 'mg'`
  - Expected: [true]
  - Actual: false

- **testQuantity2**: `4 'g' ~ 4000 'mg'`
  - Expected: [true]
  - Actual: false

- **testQuantity4**: `4 'g' ~ 4040 'mg'`
  - Expected: [true]
  - Actual: false

- **testQuantity5**: `7 days = 1 week`
  - Expected: [true]
  - Actual: 7

- **testQuantity6**: `7 days = 1 'wk'`
  - Expected: [true]
  - Actual: 7

- **testQuantity7**: `6 days < 1 week`
  - Expected: [true]
  - Actual: 6

- **testQuantity8**: `8 days > 1 week`
  - Expected: [true]
  - Actual: 8

- **testQuantity9**: `2.0 'cm' * 2.0 'm' = 0.040 'm2'`
  - Error: error.TypeMismatch

- **testQuantity10**: `4.0 'g' / 2.0 'm' = 2 'g/m'`
  - Error: error.TypeMismatch

- **testQuantity11**: `1.0 'm' / 1.0 'm' = 1 '1'`
  - Error: error.TypeMismatch

### ªªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.10ms

#### Failed Tests:

- **testLength1**: `'123456'.length() = 6`
  - Error: error.InvalidFunctionCall

- **testLength2**: `'12345'.length() = 5`
  - Error: error.InvalidFunctionCall

- **testLength3**: `'123'.length() = 3`
  - Error: error.InvalidFunctionCall

- **testLength4**: `'1'.length() = 1`
  - Error: error.InvalidFunctionCall

- **testLength5**: `''.length() = 0`
  - Error: error.InvalidFunctionCall

- **testLength6**: `{}.length().empty() = true`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.60ms

#### Failed Tests:

- **testCount1**: `Patient.name.count()`
  - Error: error.InvalidFunctionCall

- **testCount2**: `Patient.name.count() = 3`
  - Error: error.InvalidFunctionCall

- **testCount3**: `Patient.name.first().count()`
  - Error: error.InvalidFunctionCall

- **testCount4**: `Patient.name.first().count() = 1`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.45ms

#### Failed Tests:

- **testCeiling1**: `1.ceiling() = 1`
  - Error: error.InvalidFunctionCall

- **testCeiling2**: `(-1.1).ceiling() = -1`
  - Error: error.InvalidFunctionCall

- **testCeiling3**: `1.1.ceiling() = 2`
  - Error: error.InvalidFunctionCall

- **testCeilingEmpty**: `{}.ceiling().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 2.14ms

#### Failed Tests:

- **testReplace1**: `'123456'.replace('234', 'X')`
  - Error: error.InvalidFunctionCall

- **testReplace2**: `'abc'.replace('', 'x')`
  - Error: error.InvalidFunctionCall

- **testReplace3**: `'123456'.replace('234', '')`
  - Error: error.InvalidFunctionCall

- **testReplace4**: `{}.replace('234', 'X').empty() = true`
  - Error: error.InvalidFunctionCall

- **testReplace5**: `'123'.replace({}, 'X').empty() = true`
  - Error: error.InvalidFunctionCall

- **testReplace6**: `'123'.replace('2', {}).empty() = true`
  - Error: error.InvalidFunctionCall

### ªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.13ms

#### Failed Tests:

- **testExp1**: `0.exp() = 1`
  - Error: error.InvalidFunctionCall

- **testExp2**: `(-0.0).exp() = 1`
  - Error: error.InvalidFunctionCall

- **testExp3**: `{}.exp().empty() = true`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªª

- Total: 21
- Passed: 0 (0.0%)
- Failed: 21
- Skipped: 0
- Time: 9.35ms

#### Failed Tests:

- **defineVariable1**: `defineVariable('v1', 'value1').select(%v1)`
  - Error: error.ExpectedIdentifier

- **defineVariable2**: `defineVariable('n1', name.first()).select(%n1.given)`
  - Error: error.ExpectedIdentifier

- **defineVariable3**: `defineVariable('n1', name.first()).select(%n1.given).first()`
  - Error: error.ExpectedIdentifier

- **defineVariable4**: `defineVariable('n1', name.first()).select(%n1.given) | defineVariable('n1', name.skip(1).first()).select(%n1.given)`
  - Error: error.ExpectedIdentifier

- **defineVariable5**: `defineVariable('n1', name.first()).where(active.not()) | defineVariable('n1', name.skip(1).first()).select(%n1.given)`
  - Error: error.ExpectedIdentifier

- **defineVariable6**: `defineVariable('n1', name.first()).select(id & '-' & %n1.given.join('|')) | defineVariable('n2', name.skip(1).first()).select(%n2.given)`
  - Error: error.ExpectedIdentifier

- **defineVariable7**: `defineVariable('n1', name.first()).active | defineVariable('n2', name.skip(1).first()).select(%n2.given)`
  - Error: error.InvalidFunctionCall

- **defineVariable8**: `defineVariable('v1', 'value1').select(%v1).trace('data').defineVariable('v2', 'value2').select($this & ':' & %v1 & '-' & %v2) | defineVariable('v3', 'value3').select(%v3)`
  - Error: error.ExpectedIdentifier

- **defineVariable9**: `defineVariable('n1', name.first()).active | defineVariable('n2', name.skip(1).first()).select(%n1.given)`
  - Error: error.InvalidFunctionCall

- **defineVariable10**: `select(%fam.given)`
  - Error: error.InvalidFunctionCall

- **dvRedefiningVariableThrowsError**: `defineVariable('v1').defineVariable('v1').select(%v1)`
  - Error: error.InvalidFunctionCall

- **defineVariable12**: `Patient.name.defineVariable('n1', first()).active | Patient.name.defineVariable('n2', skip(1).first()).select(%n1.given)`
  - Error: error.InvalidFunctionCall

- **defineVariable13**: `Patient.name.defineVariable('n2', skip(1).first()).defineVariable('res', %n2.given+%n2.given).select(%res)`
  - Error: error.InvalidFunctionCall

- **defineVariable14**: `Patient.name.defineVariable('n1', first()).select(%n1).exists() | Patient.name.defineVariable('n2', skip(1).first()).defineVariable('res', %n2.given+%n2.given).select(%res)`
  - Error: error.InvalidFunctionCall

- **defineVariable15**: `defineVariable('root', 'r1-').select(defineVariable('v1', 'v1').defineVariable('v2', 'v2').select(%v1 | %v2)).select(%root & $this)`
  - Error: error.ExpectedIdentifier

- **defineVariable16**: `defineVariable('root', 'r1-').select(defineVariable('v1', 'v1').defineVariable('v2', 'v2').select(%v1 | %v2)).select(%root & $this & %v1)`
  - Error: error.ExpectedIdentifier

- **dvCantOverwriteSystemVar**: `defineVariable('context', 'oops')`
  - Error: error.UnsupportedOperation

- **dvConceptMapExample**: `group.select(
				defineVariable('grp')
				.element
				.select(
					defineVariable('ele')
					.target
					.select(%grp.source & '|' & %ele.code & ' ' & relationship & ' ' & %grp.target & '|' & code)
				)
			)
			.trace('all')
			.isDistinct()`
  - Error: error.ExpectedIdentifier

- **defineVariable19**: `defineVariable(defineVariable('param','ppp').select(%param), defineVariable('param','value').select(%param)).select(%ppp)`
  - Error: error.UnsupportedOperation

- **dvParametersDontColide**: `'aaa'.replace(defineVariable('param', 'aaa').select(%param), defineVariable('param','bbb').select(%param))`
  - Error: error.InvalidFunctionCall

- **dvUsageOutsideScopeThrows**: `defineVariable('n1', 'v1').active | defineVariable('n2', 'v2').select(%n1)`
  - Error: error.ExpectedIdentifier

### ªªªªªªªªªª

- Total: 7
- Passed: 4 (57.1%)
- Failed: 3
- Skipped: 0
- Time: 5.81ms

#### Failed Tests:

- **testEscapedIdentifier**: `name.`given``
  - Error: error.ExpectedIdentifier

- **testSimpleBackTick1**: ``Patient`.name.`given``
  - Error: error.ExpectedIdentifier

- **testSimpleWithContext**: `Patient.name.given`
  - Expected: ['Peter', 'James', 'Jim', 'Peter', 'James']
  - Actual: []

### ªªªªªªªªªªªªªªªª

- Total: 10
- Passed: 2 (20.0%)
- Failed: 8
- Skipped: 0
- Time: 3.31ms

#### Failed Tests:

- **testPolymorphismA**: `Observation.value.unit`
  - Expected: ['lbs']
  - Actual: []

- **testPolymorphismB**: `Observation.valueQuantity.unit`
  - Expected: ['lbs']
  - Actual: []

- **testPolymorphismIsA1**: `Observation.value.is(Quantity)`
  - Error: error.ExpectedIdentifier

- **testPolymorphismIsA2**: `Observation.value is Quantity`
  - Expected: [true]
  - Actual: []

- **testPolymorphismIsB**: `Observation.value.is(Period).not()`
  - Error: error.ExpectedIdentifier

- **testPolymorphismAsA**: `Observation.value.as(Quantity).unit`
  - Error: error.ExpectedIdentifier

- **testPolymorphismAsAFunction**: `(Observation.value as Quantity).unit`
  - Expected: ['lbs']
  - Actual: []

- **testPolymorphismAsBFunction**: `Observation.value.as(Period).start`
  - Error: error.ExpectedIdentifier

### ªªªªªªªªªªªªªª

- Total: 24
- Passed: 15 (62.5%)
- Failed: 9
- Skipped: 0
- Time: 9.92ms

#### Failed Tests:

- **testEquivalent6**: `'a' ~ 'A'`
  - Expected: [true]
  - Actual: false

- **testEquivalent11**: `1.2 / 1.8 ~ 0.67`
  - Expected: [true]
  - Actual: false

- **testEquivalent17**: `@2012-04-15T15:30:31 ~ @2012-04-15T15:30:31.0`
  - Expected: [true]
  - Actual: false

- **testEquivalent19**: `name ~ name`
  - Expected: [true]
  - Actual: false

- **testEquivalent20**: `name.take(2).given ~ name.take(2).first().given | name.take(2).last().given`
  - Error: error.InvalidFunctionCall

- **testEquivalent21**: `name.take(2).given ~ name.take(2).last().given | name.take(2).first().given`
  - Error: error.InvalidFunctionCall

- **testEquivalent22**: `Observation.value ~ 185 '[lb_av]'`
  - Expected: [true]
  - Actual: false

- **testEquivalent23**: `(1 | 2 | 3) ~ (1 | 2 | 3)`
  - Error: error.UnsupportedOperation

- **testEquivalent24**: `(1 | 2 | 3) ~ (3 | 2 | 1)`
  - Error: error.UnsupportedOperation

### ªªªªªªªªªªªªªªªªªªª

- Total: 9
- Passed: 4 (44.4%)
- Failed: 5
- Skipped: 0
- Time: 3.28ms

#### Failed Tests:

- **testBooleanLogicXOr3**: `(true xor {}).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicXOr6**: `(false xor {}).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicXOr7**: `({} xor true).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicXOr8**: `({} xor false).empty()`
  - Error: error.InvalidFunctionCall

- **testBooleanLogicXOr9**: `({} xor {}).empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.16ms

#### Failed Tests:

- **testSqrt1**: `81.sqrt() = 9.0`
  - Error: error.InvalidFunctionCall

- **testSqrt2**: `(-1).sqrt()`
  - Error: error.InvalidFunctionCall

- **testSqrtEmpty**: `{}.sqrt().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 2.03ms

#### Failed Tests:

- **testRepeat1**: `ValueSet.expansion.repeat(contains).count() = 10`
  - Error: error.InvalidFunctionCall

- **testRepeat2**: `Questionnaire.repeat(item).code.count() = 11`
  - Error: error.InvalidFunctionCall

- **testRepeat3**: `Questionnaire.descendants().code.count() = 23`
  - Error: error.InvalidFunctionCall

- **testRepeat4**: `Questionnaire.children().code.count() = 2`
  - Error: error.InvalidFunctionCall

- **testRepeat5**: `Patient.name.repeat('test')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 1
- Passed: 0 (0.0%)
- Failed: 1
- Skipped: 0
- Time: 0.39ms

#### Failed Tests:

- **testToChars1**: `'t2'.toChars() = 't' | '2'`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªª

- Total: 7
- Passed: 0 (0.0%)
- Failed: 7
- Skipped: 0
- Time: 2.44ms

#### Failed Tests:

- **testReplaceMatches1**: `'123456'.replaceMatches('234', 'X')`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches2**: `'abc'.replaceMatches('', 'x')`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches3**: `'123456'.replaceMatches('234', '')`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches4**: `{}.replaceMatches('234', 'X').empty() = true`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches5**: `'123'.replaceMatches({}, 'X').empty() = true`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches6**: `'123'.replaceMatches('2', {}).empty() = true`
  - Error: error.InvalidFunctionCall

- **testReplaceMatches7**: `'abc123'.replaceMatches('[0-9]', '-')`
  - Error: error.InvalidFunctionCall

### ªªªªªªª

- Total: 11
- Passed: 3 (27.3%)
- Failed: 8
- Skipped: 0
- Time: 4.49ms

#### Failed Tests:

- **testIif1**: `iif(Patient.name.exists(), 'named', 'unnamed') = 'named'`
  - Expected: [true]
  - Actual: false

- **testIif5**: `iif(false, 'true-result').empty()`
  - Error: error.InvalidFunctionCall

- **testIif6**: `iif('non boolean criteria', 'true-result', 'true-result')`
  - Expected: []
  - Actual: 'true-result'

- **testIif7**: `{}.iif(true, 'true-result', 'false-result')`
  - Error: error.InvalidFunctionCall

- **testIif8**: `('item').iif(true, 'true-result', 'false-result')`
  - Error: error.InvalidFunctionCall

- **testIif9**: `('context').iif(true, select($this), 'false-result')`
  - Error: error.InvalidFunctionCall

- **testIif10**: `('item1' | 'item2').iif(true, 'true-result', 'false-result')`
  - Error: error.InvalidFunctionCall

- **testIif11**: `('context').iif($this = 'context','true-result', 'false-result')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.40ms

#### Failed Tests:

- **testEscapeHtml**: `'"1<2"'.escape('html')`
  - Error: error.InvalidFunctionCall

- **testEscapeJson**: `'"1<2"'.escape('json')`
  - Error: error.InvalidFunctionCall

- **testUnescapeHtml**: `'&quot;1&lt;2&quot;'.unescape('html')`
  - Error: error.InvalidFunctionCall

- **testUnescapeJson**: `'\"1<2\"'.unescape('json')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 82
- Passed: 5 (6.1%)
- Failed: 77
- Skipped: 0
- Time: 29.68ms

#### Failed Tests:

- **testLiteralTrue**: `Patient.name.exists() = true`
  - Error: error.InvalidFunctionCall

- **testLiteralFalse**: `Patient.name.empty() = false`
  - Error: error.InvalidFunctionCall

- **testLiteralString1**: `Patient.name.given.first() = 'Peter'`
  - Error: error.InvalidFunctionCall

- **testLiteralInteger1**: `1.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testLiteralInteger0**: `0.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerNegative1**: `(-1).convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerNegative1Invalid**: `-1.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerMax**: `2147483647.convertsToInteger()`
  - Error: error.InvalidFunctionCall

- **testLiteralString2**: `'test'.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testLiteralStringEscapes**: `'\\\/\f\r\n\t\"\`\'\u002a'.convertsToString()`
  - Error: error.InvalidFunctionCall

- **testLiteralBooleanTrue**: `true.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testLiteralBooleanFalse**: `false.convertsToBoolean()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimal10**: `1.0.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimal01**: `0.1.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimal00**: `0.0.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimalNegative01**: `(-0.1).convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimalNegative01Invalid**: `-0.1.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimalMax**: `1234567890987654321.0.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDecimalStep**: `0.00000001.convertsToDecimal()`
  - Error: error.InvalidFunctionCall

- **testLiteralDateYear**: `@2015.is(Date)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateMonth**: `@2015-02.is(Date)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateDay**: `@2015-02-04.is(Date)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeYear**: `@2015T.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeMonth**: `@2015-02T.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeDay**: `@2015-02-04T.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeHour**: `@2015-02-04T14.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeMinute**: `@2015-02-04T14:34.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeSecond**: `@2015-02-04T14:34:28.is(DateTime)`
  - Expected: [true]
  - Actual: null

- **testLiteralDateTimeMillisecond**: `@2015-02-04T14:34:28.123.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeUTC**: `@2015-02-04T14:34:28Z.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralDateTimeTimezoneOffset**: `@2015-02-04T14:34:28+10:00.is(DateTime)`
  - Error: error.ExpectedIdentifier

- **testLiteralTimeHour**: `@T14.is(Time)`
  - Error: error.ExpectedIdentifier

- **testLiteralTimeMinute**: `@T14:34.is(Time)`
  - Error: error.ExpectedIdentifier

- **testLiteralTimeSecond**: `@T14:34:28.is(Time)`
  - Expected: [true]
  - Actual: null

- **testLiteralTimeMillisecond**: `@T14:34:28.123.is(Time)`
  - Error: error.ExpectedIdentifier

- **testLiteralTimeUTC**: `@T14:34:28Z.is(Time)`
  - Error: error.ExpectedIdentifier

- **testLiteralTimeTimezoneOffset**: `@T14:34:28+10:00.is(Time)`
  - Error: error.ExpectedIdentifier

- **testLiteralQuantityDecimal**: `10.1 'mg'.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testLiteralQuantityInteger**: `10 'mg'.convertsToQuantity()`
  - Error: error.InvalidFunctionCall

- **testLiteralQuantityDay**: `4 days.convertsToQuantity()`
  - Expected: [true]
  - Actual: 4

- **testLiteralIntegerNotEqual**: `-3 != 3`
  - Error: error.TypeMismatch

- **testLiteralIntegerEqual**: `Patient.name.given.count() = 5`
  - Error: error.InvalidFunctionCall

- **testPolarityPrecedence**: `-Patient.name.given.count() = -5`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerGreaterThan**: `Patient.name.given.count() > -3`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerCountNotEqual**: `Patient.name.given.count() != 0`
  - Error: error.InvalidFunctionCall

- **testLiteralIntegerLessThanTrue**: `1 < 2`
  - Error: error.TypeMismatch

- **testLiteralIntegerLessThanFalse**: `1 < -2`
  - Error: error.TypeMismatch

- **testLiteralIntegerLessThanPolarityTrue**: `+1 < +2`
  - Error: error.TypeMismatch

- **testLiteralIntegerLessThanPolarityFalse**: `-1 < 2`
  - Error: error.TypeMismatch

- **testLiteralDecimalGreaterThanNonZeroTrue**: `Observation.value.value > 180.0`
  - Error: error.TypeMismatch

- **testLiteralDecimalGreaterThanZeroTrue**: `Observation.value.value > 0.0`
  - Error: error.TypeMismatch

- **testLiteralDecimalGreaterThanIntegerTrue**: `Observation.value.value > 0`
  - Error: error.TypeMismatch

- **testLiteralDecimalLessThanInteger**: `Observation.value.value < 190`
  - Error: error.TypeMismatch

- **testLiteralDecimalLessThanInvalid**: `Observation.value.value < 'test'`
  - Error: error.TypeMismatch

- **testDateEqual**: `Patient.birthDate = @1974-12-25`
  - Expected: [true]
  - Actual: []

- **testDateNotEqualTimeSecond**: `Patient.birthDate != @T12:14:15`
  - Expected: [true]
  - Actual: []

- **testDateNotEqualTimeMinute**: `Patient.birthDate != @T12:14`
  - Expected: [true]
  - Actual: []

- **testDateNotEqualToday**: `Patient.birthDate < today()`
  - Error: error.UnsupportedOperation

- **testDateTimeGreaterThanDate1**: `now() > Patient.birthDate`
  - Error: error.TypeMismatch

- **testDateGreaterThanDate**: `today() > Patient.birthDate`
  - Error: error.TypeMismatch

- **testDateTimeGreaterThanDate2**: `now() > today()`
  - Error: error.TypeMismatch

- **testLiteralDateTimeTZGreater**: `@2017-11-05T01:30:00.0-04:00 > @2017-11-05T01:15:00.0-05:00`
  - Error: error.TypeMismatch

- **testLiteralDateTimeTZLess**: `@2017-11-05T01:30:00.0-04:00 < @2017-11-05T01:15:00.0-05:00`
  - Error: error.TypeMismatch

- **testLiteralDateTimeTZEqualFalse**: `@2017-11-05T01:30:00.0-04:00 = @2017-11-05T01:15:00.0-05:00`
  - Error: error.TypeMismatch

- **testLiteralDateTimeTZEqualTrue**: `@2017-11-05T01:30:00.0-04:00 = @2017-11-05T00:30:00.0-05:00`
  - Error: error.TypeMismatch

- **testLiteralUnicode**: `Patient.name.given.first() = 'P\u0065ter'`
  - Error: error.InvalidFunctionCall

- **testCollectionNotEmpty**: `Patient.name.given.empty().not()`
  - Error: error.InvalidFunctionCall

- **testExpressions**: `Patient.name.select(given | family).distinct()`
  - Error: error.ExpectedIdentifier

- **testExpressionsEqual**: `Patient.name.given.count() = 1 + 4`
  - Error: error.InvalidFunctionCall

- **testNotEmpty**: `Patient.name.empty().not()`
  - Error: error.InvalidFunctionCall

- **testEmpty**: `Patient.link.empty()`
  - Error: error.InvalidFunctionCall

- **testLiteralNotOnEmpty**: `{}.not().empty()`
  - Error: error.ExpectedIdentifier

- **testLiteralNotTrue**: `true.not() = false`
  - Error: error.ExpectedIdentifier

- **testLiteralNotFalse**: `false.not() = true`
  - Error: error.ExpectedIdentifier

- **testIntegerBooleanNotTrue**: `(0).not() = false`
  - Error: error.ExpectedIdentifier

- **testIntegerBooleanNotFalse**: `(1).not() = false`
  - Error: error.ExpectedIdentifier

- **testNotInvalid**: `(1|2).not() = false`
  - Error: error.ExpectedIdentifier

### ªªªªªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.73ms

#### Failed Tests:

- **testSuperSetOf1**: `Patient.name.first().supersetOf($this.name).not()`
  - Error: error.InvalidFunctionCall

- **testSuperSetOf2**: `Patient.name.supersetOf($this.name.first())`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.54ms

#### Failed Tests:

- **testSplit1**: `'Peter,James,Jim,Peter,James'.split(',').count() = 5`
  - Error: error.InvalidFunctionCall

- **testSplit2**: `'A,,C'.split(',').join(',') = 'A,,C'`
  - Error: error.InvalidFunctionCall

- **testSplit3**: `'[stop]ONE[stop][stop]TWO[stop][stop][stop]THREE[stop][stop]'.split('[stop]').trace('n').count() = 9`
  - Error: error.InvalidFunctionCall

- **testSplit4**: `'[stop]ONE[stop][stop]TWO[stop][stop][stop]THREE[stop][stop]'.split('[stop]').join('[stop]')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 11
- Passed: 0 (0.0%)
- Failed: 11
- Skipped: 0
- Time: 3.83ms

#### Failed Tests:

- **testEndsWith1**: `'12345'.endsWith('2') = false`
  - Error: error.InvalidFunctionCall

- **testEndsWith2**: `'12345'.endsWith('5') = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith3**: `'12345'.endsWith('45') = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith4**: `'12345'.endsWith('35') = false`
  - Error: error.InvalidFunctionCall

- **testEndsWith5**: `'12345'.endsWith('12345') = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith6**: `'12345'.endsWith('012345') = false`
  - Error: error.InvalidFunctionCall

- **testEndsWith7**: `'12345'.endsWith('') = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith8**: `{}.endsWith('1').empty() = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith9**: `{}.endsWith('').empty() = true`
  - Error: error.InvalidFunctionCall

- **testEndsWith10**: `'123456789'.endsWith(length().toString())`
  - Error: error.InvalidFunctionCall

- **testEndsWithNonString1**: `Appointment.identifier.endsWith('rand')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 1
- Passed: 0 (0.0%)
- Failed: 1
- Skipped: 0
- Time: 0.39ms

#### Failed Tests:

- **testIndex**: `Patient.telecom.select(iif(value='(03) 3410 5613', $index, {} ))`
  - Error: error.ExpectedIdentifier

### ªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.75ms

#### Failed Tests:

- **testNow1**: `Patient.birthDate < now()`
  - Error: error.TypeMismatch

- **testNow2**: `now().toString().length() > 10`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.06ms

#### Failed Tests:

- **testRound1**: `1.round() = 1`
  - Error: error.InvalidFunctionCall

- **testRound2**: `3.14159.round(3) = 3.142`
  - Error: error.InvalidFunctionCall

- **testRoundEmpty**: `{}.round().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.83ms

#### Failed Tests:

- **testContainedId**: `contained.id`
  - Expected: [1]
  - Actual: '1'

- **testMultipleResolve**: `composition.exists() 
			implies 
			(
				composition.resolve().section.entry.reference.where(resolve() is Observation)
				.where($this in (%resource.result.reference | %resource.result.reference.resolve().hasMember.reference)).exists()
			)`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.68ms

#### Failed Tests:

- **testPolymorphicsA**: `Observation.value.exists()`
  - Error: error.InvalidFunctionCall

- **testPolymorphicsB**: `Observation.valueQuantity.exists()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 2.27ms

#### Failed Tests:

- **testDollarThis1**: `Patient.name.given.where(substring($this.length()-3) = 'out')`
  - Error: error.ExpectedIdentifier

- **testDollarThis2**: `Patient.name.given.where(substring($this.length()-3) = 'ter')`
  - Error: error.ExpectedIdentifier

- **testDollarOrderAllowed**: `Patient.name.skip(1).given`
  - Error: error.InvalidFunctionCall

- **testDollarOrderAllowedA**: `Patient.name.skip(3).given`
  - Error: error.InvalidFunctionCall

- **testDollarOrderNotAllowed**: `Patient.children().skip(1)`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 16
- Passed: 0 (0.0%)
- Failed: 16
- Skipped: 0
- Time: 2.42ms

#### Failed Tests:

- **testMatchesCaseSensitive1**: `'FHIR'.matches('FHIR')`
  - Error: error.InvalidFunctionCall

- **testMatchesCaseSensitive2**: `'FHIR'.matches('fhir')`
  - Error: error.InvalidFunctionCall

- **testMatchesEmpty**: `'FHIR'.matches({}).empty() = true`
  - Error: error.InvalidFunctionCall

- **testMatchesEmpty2**: `{}.matches('FHIR').empty() = true`
  - Error: error.InvalidFunctionCall

- **testMatchesEmpty3**: `{}.matches({}).empty() = true`
  - Error: error.InvalidFunctionCall

- **testMatchesSingleLineMode1**: `'A
			B'.matches('A.*B')`
  - Error: error.InvalidFunctionCall

- **testMatchesWithinUrl1**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matches('library')`
  - Error: error.InvalidFunctionCall

- **testMatchesWithinUrl2**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matches('Library')`
  - Error: error.InvalidFunctionCall

- **testMatchesWithinUrl3**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matches('^Library$')`
  - Error: error.InvalidFunctionCall

- **testMatchesWithinUrl1a**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matches('.*Library.*')`
  - Error: error.InvalidFunctionCall

- **testMatchesWithinUrl4**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matches('Measure')`
  - Error: error.InvalidFunctionCall

- **testMatchesFullWithinUrl1**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('library')`
  - Error: error.InvalidFunctionCall

- **testMatchesFullWithinUrl3**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('Library')`
  - Error: error.InvalidFunctionCall

- **testMatchesFullWithinUrl4**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('^Library$')`
  - Error: error.InvalidFunctionCall

- **testMatchesFullWithinUrl1a**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('.*Library.*')`
  - Error: error.InvalidFunctionCall

- **testMatchesFullWithinUrl2**: `'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('Measure')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 30
- Passed: 2 (6.7%)
- Failed: 28
- Skipped: 0
- Time: 17.20ms

#### Failed Tests:

- **testType1**: `1.type().namespace = 'System'`
  - Error: error.InvalidFunctionCall

- **testType1a**: `1.type().name = 'Integer'`
  - Error: error.InvalidFunctionCall

- **testType2**: `'1'.type().namespace = 'System'`
  - Error: error.InvalidFunctionCall

- **testType2a**: `'1'.type().name = 'String'`
  - Error: error.InvalidFunctionCall

- **testType3**: `true.type().namespace = 'System'`
  - Error: error.InvalidFunctionCall

- **testType4**: `true.type().name = 'Boolean'`
  - Error: error.InvalidFunctionCall

- **testType5**: `true.is(Boolean)`
  - Error: error.ExpectedIdentifier

- **testType6**: `true.is(System.Boolean)`
  - Error: error.ExpectedIdentifier

- **testType9**: `Patient.active.type().namespace = 'FHIR'`
  - Error: error.InvalidFunctionCall

- **testType10**: `Patient.active.type().name = 'boolean'`
  - Error: error.InvalidFunctionCall

- **testType11**: `Patient.active.is(boolean)`
  - Error: error.ExpectedIdentifier

- **testType12**: `Patient.active.is(Boolean).not()`
  - Error: error.ExpectedIdentifier

- **testType13**: `Patient.active.is(FHIR.boolean)`
  - Error: error.ExpectedIdentifier

- **testType14**: `Patient.active.is(System.Boolean).not()`
  - Error: error.ExpectedIdentifier

- **testType15**: `Patient.type().namespace = 'FHIR'`
  - Error: error.InvalidFunctionCall

- **testType16**: `Patient.type().name = 'Patient'`
  - Error: error.InvalidFunctionCall

- **testType17**: `Patient.is(Patient)`
  - Error: error.ExpectedIdentifier

- **testType18**: `Patient.is(FHIR.Patient)`
  - Error: error.ExpectedIdentifier

- **testType19**: `Patient.is(FHIR.`Patient`)`
  - Error: error.ExpectedIdentifier

- **testType20**: `Patient.ofType(Patient).type().name`
  - Error: error.InvalidFunctionCall

- **testType21**: `Patient.ofType(FHIR.Patient).type().name`
  - Error: error.InvalidFunctionCall

- **testType22**: `Patient.is(System.Patient).not()`
  - Error: error.ExpectedIdentifier

- **testType23**: `Patient.ofType(FHIR.`Patient`).type().name`
  - Error: error.InvalidFunctionCall

- **testTypeA1**: `Parameters.parameter[0].value.is(FHIR.string)`
  - Error: error.ExpectedIdentifier

- **testTypeA2**: `Parameters.parameter[1].value.is(FHIR.integer)`
  - Error: error.ExpectedIdentifier

- **testTypeA3**: `Parameters.parameter[2].value.is(FHIR.uuid)`
  - Error: error.ExpectedIdentifier

- **testTypeA4**: `Parameters.parameter[2].value.is(FHIR.uri)`
  - Error: error.ExpectedIdentifier

- **testTypeA**: `Parameters.parameter[3].value.is(FHIR.decimal)`
  - Error: error.ExpectedIdentifier

### ªªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.78ms

#### Failed Tests:

- **testIndexer1**: `Patient.name[0].given = 'Peter' | 'James'`
  - Error: error.TypeMismatch

- **testIndexer2**: `Patient.name[1].given = 'Jim'`
  - Error: error.TypeMismatch

### ªªªªªªªª

- Total: 7
- Passed: 0 (0.0%)
- Failed: 7
- Skipped: 0
- Time: 2.62ms

#### Failed Tests:

- **testTake1**: `(0 | 1 | 2).take(1) = 0`
  - Error: error.InvalidFunctionCall

- **testTake2**: `(0 | 1 | 2).take(2) = 0 | 1`
  - Error: error.InvalidFunctionCall

- **testTake3**: `Patient.name.take(1).given = 'Peter' | 'James'`
  - Error: error.InvalidFunctionCall

- **testTake4**: `Patient.name.take(2).given = 'Peter' | 'James' | 'Jim'`
  - Error: error.InvalidFunctionCall

- **testTake5**: `Patient.name.take(3).given.count() = 5`
  - Error: error.InvalidFunctionCall

- **testTake6**: `Patient.name.take(4).given.count() = 5`
  - Error: error.InvalidFunctionCall

- **testTake7**: `Patient.name.take(0).given.exists() = false`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.74ms

#### Failed Tests:

- **testExclude1**: `(1 | 2 | 3).exclude(2 | 4) = 1 | 3`
  - Error: error.InvalidFunctionCall

- **testExclude2**: `(1 | 2).exclude(4) = 1 | 2`
  - Error: error.InvalidFunctionCall

- **testExclude3**: `(1 | 2).exclude({}) = 1 | 2`
  - Error: error.InvalidFunctionCall

- **testExclude4**: `1.combine(1).exclude(2).count() = 2`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªªªªªªªªªªªªªª

- Total: 3
- Passed: 1 (33.3%)
- Failed: 2
- Skipped: 0
- Time: 1.08ms

#### Failed Tests:

- **testExtractBirthDate**: `birthDate`
  - Expected: ['@1974-12-25']
  - Actual: '1974-12-25'

- **testPatientHasBirthDate**: `birthDate`
  - Expected: [true]
  - Actual: '1974-12-25'

### ªªªªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.12ms

#### Failed Tests:

- **testExtension1**: `Patient.birthDate.extension('http://hl7.org/fhir/StructureDefinition/patient-birthTime').exists()`
  - Error: error.InvalidFunctionCall

- **testExtension2**: `Patient.birthDate.extension(%`ext-patient-birthTime`).exists()`
  - Error: error.InvalidFunctionCall

- **testExtension3**: `Patient.birthDate.extension('http://hl7.org/fhir/StructureDefinition/patient-birthTime1').empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªªªªªªªª

- Total: 9
- Passed: 0 (0.0%)
- Failed: 9
- Skipped: 0
- Time: 3.22ms

#### Failed Tests:

- **testContainsCollection1**: `(1 | 2 | 3) contains 1`
  - Error: error.UnsupportedOperation

- **testContainsCollection2**: `(2 | 3) contains 1`
  - Error: error.UnsupportedOperation

- **testContainsCollection3**: `('a' | 'c' | 'd') contains 'a'`
  - Error: error.UnsupportedOperation

- **testContainsCollection4**: `('a' | 'c' | 'd') contains 'b'`
  - Error: error.UnsupportedOperation

- **testContainsCollectionEmpty1**: `{} contains 1`
  - Error: error.UnsupportedOperation

- **testContainsCollectionEmpty2**: `{} contains 'value'`
  - Error: error.UnsupportedOperation

- **testContainsCollectionEmpty3**: `{} contains true`
  - Error: error.UnsupportedOperation

- **testContainsCollectionEmpty4**: `{} contains {}`
  - Error: error.UnsupportedOperation

- **testContainsCollectionEmptyDateTime**: `{} contains @2023-01-01`
  - Error: error.UnsupportedOperation

### ªªªªªªªªªªªª

- Total: 24
- Passed: 0 (0.0%)
- Failed: 24
- Skipped: 0
- Time: 3.52ms

#### Failed Tests:

- **HighBoundaryDecimalDefault**: `1.587.highBoundary()`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal1**: `1.587.highBoundary(2)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal2**: `1.587.highBoundary(6)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal3**: `1.587.highBoundary(-1)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal4**: `(-1.587).highBoundary()`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal5**: `(-1.587).highBoundary(2)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal6**: `(-1.587).highBoundary(6)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal7**: `1.587.highBoundary(39)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal8**: `1.highBoundary()`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal9**: `1.highBoundary(0)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal10**: `1.highBoundary(5)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal11**: `12.587.highBoundary(2)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal12**: `12.500.highBoundary(4)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal13**: `120.highBoundary(2)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal14**: `-120.highBoundary(2)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal15**: `0.0034.highBoundary(1)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal16**: `-0.0034.highBoundary(1)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDecimal**: `1.587.highBoundary(8)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryQuantity**: `1.587 'm'.highBoundary(8)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDateMonth**: `@2014.highBoundary(6)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDateTimeMillisecond1**: `@2014-01-01T08.highBoundary(17)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDateTimeMillisecond2**: `@2014-01-01T08:05-05:00.highBoundary(17)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryDateTimeMillisecond3**: `@2014-01-01T08.highBoundary(17)`
  - Error: error.InvalidFunctionCall

- **HighBoundaryTimeMillisecond**: `@T10:30.highBoundary(9)`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 5
- Passed: 0 (0.0%)
- Failed: 5
- Skipped: 0
- Time: 1.98ms

#### Failed Tests:

- **testExists1**: `Patient.name.exists()`
  - Error: error.InvalidFunctionCall

- **testExists2**: `Patient.name.exists(use = 'nickname')`
  - Error: error.InvalidFunctionCall

- **testExists3**: `Patient.name.exists(use = 'official')`
  - Error: error.InvalidFunctionCall

- **testExists4**: `Patient.maritalStatus.coding.exists(code = 'P' and system = 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus')
			or Patient.maritalStatus.coding.exists(code = 'A' and system = 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus')`
  - Error: error.InvalidFunctionCall

- **testExists5**: `(1 | 2).exists()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªª

- Total: 6
- Passed: 3 (50.0%)
- Failed: 3
- Skipped: 0
- Time: 2.49ms

#### Failed Tests:

- **testMultiplyEmpty1**: `1 * {}`
  - Error: error.EmptyCollection

- **testMultiplyEmpty2**: `{} * 1`
  - Error: error.EmptyCollection

- **testMultiplyEmpty3**: `{} * {}`
  - Error: error.EmptyCollection

### ªªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.47ms

#### Failed Tests:

- **testCase1**: `'t'.upper() = 'T'`
  - Error: error.InvalidFunctionCall

- **testCase2**: `'t'.lower() = 't'`
  - Error: error.InvalidFunctionCall

- **testCase3**: `'T'.upper() = 'T'`
  - Error: error.InvalidFunctionCall

- **testCase4**: `'T'.lower() = 't'`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªª

- Total: 30
- Passed: 0 (0.0%)
- Failed: 30
- Skipped: 0
- Time: 11.27ms

#### Failed Tests:

- **testLessOrEqual1**: `1 <= 2`
  - Error: error.TypeMismatch

- **testLessOrEqual2**: `1.0 <= 1.2`
  - Error: error.TypeMismatch

- **testLessOrEqual3**: `'a' <= 'b'`
  - Error: error.TypeMismatch

- **testLessOrEqual4**: `'A' <= 'a'`
  - Error: error.TypeMismatch

- **testLessOrEqual5**: `@2014-12-12 <= @2014-12-13`
  - Error: error.TypeMismatch

- **testLessOrEqual6**: `@2014-12-13T12:00:00 <= @2014-12-13T12:00:01`
  - Error: error.TypeMismatch

- **testLessOrEqual7**: `@T12:00:00 <= @T14:00:00`
  - Error: error.TypeMismatch

- **testLessOrEqual8**: `1 <= 1`
  - Error: error.TypeMismatch

- **testLessOrEqual9**: `1.0 <= 1.0`
  - Error: error.TypeMismatch

- **testLessOrEqual10**: `'a' <= 'a'`
  - Error: error.TypeMismatch

- **testLessOrEqual11**: `'A' <= 'A'`
  - Error: error.TypeMismatch

- **testLessOrEqual12**: `@2014-12-12 <= @2014-12-12`
  - Error: error.TypeMismatch

- **testLessOrEqual13**: `@2014-12-13T12:00:00 <= @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testLessOrEqual14**: `@T12:00:00 <= @T12:00:00`
  - Error: error.TypeMismatch

- **testLessOrEqual15**: `2 <= 1`
  - Error: error.TypeMismatch

- **testLessOrEqual16**: `1.1 <= 1.0`
  - Error: error.TypeMismatch

- **testLessOrEqual17**: `'b' <= 'a'`
  - Error: error.TypeMismatch

- **testLessOrEqual18**: `'B' <= 'A'`
  - Error: error.TypeMismatch

- **testLessOrEqual19**: `@2014-12-13 <= @2014-12-12`
  - Error: error.TypeMismatch

- **testLessOrEqual20**: `@2014-12-13T12:00:01 <= @2014-12-13T12:00:00`
  - Error: error.TypeMismatch

- **testLessOrEqual21**: `@T12:00:01 <= @T12:00:00`
  - Error: error.TypeMismatch

- **testLessOrEqual22**: `Observation.value <= 200 '[lb_av]'`
  - Error: error.TypeMismatch

- **testLessOrEqual23**: `@2018-03 <= @2018-03-01`
  - Error: error.TypeMismatch

- **testLessOrEqual24**: `@2018-03-01T10:30 <= @2018-03-01T10:30:00`
  - Error: error.TypeMismatch

- **testLessOrEqual25**: `@T10:30 <= @T10:30:00`
  - Error: error.TypeMismatch

- **testLessOrEqual26**: `@2018-03-01T10:30:00  <= @2018-03-01T10:30:00.0`
  - Error: error.TypeMismatch

- **testLessOrEqual27**: `@T10:30:00 <= @T10:30:00.0`
  - Error: error.TypeMismatch

- **testLessOrEqualEmpty1**: `1 <= {}`
  - Error: error.TypeMismatch

- **testLessOrEqualEmpty2**: `{} <= 1`
  - Error: error.TypeMismatch

- **testLessOrEqualEmpty3**: `{} <= {}`
  - Error: error.TypeMismatch

### ªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.08ms

#### Failed Tests:

- **testLn1**: `1.ln() = 0.0`
  - Error: error.InvalidFunctionCall

- **testLn2**: `1.0.ln() = 0.0`
  - Error: error.InvalidFunctionCall

- **testLnEmpty**: `{}.ln().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªª

- Total: 10
- Passed: 0 (0.0%)
- Failed: 10
- Skipped: 0
- Time: 3.95ms

#### Failed Tests:

- **testSort1**: `(1 | 2 | 3).sort() = (1 | 2 | 3)`
  - Error: error.InvalidFunctionCall

- **testSort2**: `(3 | 2 | 1).sort() = (1 | 2 | 3)`
  - Error: error.InvalidFunctionCall

- **testSort3**: `(1 | 2 | 3).sort($this) = (1 | 2 | 3)`
  - Error: error.InvalidFunctionCall

- **testSort4**: `(3 | 2 | 1).sort($this) = (1 | 2 | 3)`
  - Error: error.InvalidFunctionCall

- **testSort5**: `(1 | 2 | 3).sort(-$this) = (3 | 2 | 1)`
  - Error: error.InvalidFunctionCall

- **testSort6**: `('a' | 'b' | 'c').sort($this) = ('a' | 'b' | 'c')`
  - Error: error.InvalidFunctionCall

- **testSort7**: `('c' | 'b' | 'a').sort($this) = ('a' | 'b' | 'c')`
  - Error: error.InvalidFunctionCall

- **testSort8**: `('a' | 'b' | 'c').sort(-$this) = ('c' | 'b' | 'a')`
  - Error: error.InvalidFunctionCall

- **testSort9**: `Patient.name[0].given.sort() = ('James' | 'Peter')`
  - Error: error.InvalidFunctionCall

- **testSort10**: `Patient.name.sort(-family, -given.first()).first().use = 'usual'`
  - Error: error.InvalidFunctionCall

### ªªªªªªª

- Total: 4
- Passed: 0 (0.0%)
- Failed: 4
- Skipped: 0
- Time: 1.51ms

#### Failed Tests:

- **testAllTrue1**: `Patient.name.select(given.exists()).allTrue()`
  - Error: error.ExpectedIdentifier

- **testAllTrue2**: `Patient.name.select(period.exists()).allTrue()`
  - Error: error.ExpectedIdentifier

- **testAllTrue3**: `Patient.name.all(given.exists())`
  - Error: error.InvalidFunctionCall

- **testAllTrue4**: `Patient.name.all(period.exists())`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªª

- Total: 6
- Passed: 0 (0.0%)
- Failed: 6
- Skipped: 0
- Time: 1.33ms

#### Failed Tests:

- **PrecisionDecimal**: `1.58700.precision()`
  - Error: error.InvalidFunctionCall

- **PrecisionYear**: `@2014.precision()`
  - Error: error.InvalidFunctionCall

- **PrecisionDateTimeMilliseconds**: `@2014-01-05T10:30:00.000.precision()`
  - Error: error.InvalidFunctionCall

- **PrecisionTimeMinutes**: `@T10:30.precision()`
  - Error: error.InvalidFunctionCall

- **PrecisionTimeMilliseconds**: `@T10:30:00.000.precision()`
  - Error: error.InvalidFunctionCall

- **PrecisionEmpty**: `{}.precision().empty()`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªªªªªªªª

- Total: 8
- Passed: 0 (0.0%)
- Failed: 8
- Skipped: 0
- Time: 3.09ms

#### Failed Tests:

- **testEncodeBase64A**: `'test'.encode('base64')`
  - Error: error.InvalidFunctionCall

- **testEncodeHex**: `'test'.encode('hex')`
  - Error: error.InvalidFunctionCall

- **testEncodeBase64B**: `'subjects?_d'.encode('base64')`
  - Error: error.InvalidFunctionCall

- **testEncodeUrlBase64**: `'subjects?_d'.encode('urlbase64')`
  - Error: error.InvalidFunctionCall

- **testDecodeBase64A**: `'dGVzdA=='.decode('base64')`
  - Error: error.InvalidFunctionCall

- **testDecodeHex**: `'74657374'.decode('hex')`
  - Error: error.InvalidFunctionCall

- **testDecodeBase64B**: `'c3ViamVjdHM/X2Q='.decode('base64')`
  - Error: error.InvalidFunctionCall

- **testDecodeUrlBase64**: `'c3ViamVjdHM_X2Q='.decode('urlbase64')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 3
- Passed: 0 (0.0%)
- Failed: 3
- Skipped: 0
- Time: 1.47ms

#### Failed Tests:

- **testSelect1**: `Patient.name.select(given).count() = 5`
  - Error: error.ExpectedIdentifier

- **testSelect2**: `Patient.name.select(given | family).count() = 7`
  - Error: error.ExpectedIdentifier

- **testSelect3**: `name.select(use.contains('i')).count()`
  - Error: error.ExpectedIdentifier

### ªªªªªªªª

- Total: 1
- Passed: 0 (0.0%)
- Failed: 1
- Skipped: 0
- Time: 0.42ms

#### Failed Tests:

- **testJoin**: `name.given.join(',')`
  - Error: error.InvalidFunctionCall

### ªªªªªªªªªª

- Total: 2
- Passed: 0 (0.0%)
- Failed: 2
- Skipped: 0
- Time: 0.75ms

#### Failed Tests:

- **testSingle1**: `Patient.name.first().single().exists()`
  - Error: error.InvalidFunctionCall

- **testSingle2**: `Patient.name.single().exists()`
  - Error: error.InvalidFunctionCall

