# Swift Code Standards

## Swift 6 Requirements
- This project uses **Swift 6.2** with strict concurrency checking enabled
- All code must be Sendable-safe and data-race free
- Use `@MainActor` for UI-related code, `actor` types for concurrent state

## Code Style
- Use Swift's native naming conventions: `camelCase` for methods/properties, `PascalCase` for types
- Prefer value types (struct/enum) over reference types (class) unless inheritance is needed
- Mark types as `final` when inheritance is not intended
- Use explicit `public`, `internal`, or `private` access modifiers

## Error Handling
- Prefer throwing errors over returning optionals for failure cases
- Use descriptive error types conforming to `Error`
- Document throws in method documentation
- Don't silently swallow errors with `try?` without justification

## Documentation
- Add doc comments (`///`) for public APIs
- Document complex algorithms and non-obvious behavior
- Keep comments concise and up-to-date with code changes
