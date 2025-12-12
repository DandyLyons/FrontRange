# Testing Requirements

## Test Coverage
- All new features must include unit tests
- Test both success and failure cases
- CLI commands require integration tests using the Command library
- MCP tools should have corresponding test cases

## CLI Testing Patterns
- Use Command library to invoke CLI programmatically
- Helper functions in Tests/FrontRangeCLITests/CLI Test Helpers.swift:
  - `createTempFile(withContent:)` - Create temporary test files
  - `copyIntoTempFile(source:)` - Copy files to temp locations
- Test files should clean up temporary resources

## Library Testing
- Use XCTest framework with standard patterns
- Use CustomDump for assertion comparisons: `expectNoDifference(expected, actual)`
- Example files in ExampleFiles/ directory for integration tests
- Test edge cases: empty input, invalid YAML, missing keys, etc.

## Test Organization
- Mirror source structure: FrontRangeTests, FrontRangeCLITests, FrontRangeMCPTests
- Group related tests in the same test class
- Test method names use the new Swift function syntax (e.g. `@Test func `CLI runs without arguments` () async throws`)

## What to Verify
- Correct parsing and serialization of front matter
- Proper error handling and error messages
- Command output format (JSON, YAML, plain text)
- File modifications don't corrupt data
- Recursive directory operations work correctly
