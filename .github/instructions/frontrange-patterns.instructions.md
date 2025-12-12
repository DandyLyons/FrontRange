# FrontRange Project Patterns

## Core Data Structure
- **FrontMatteredDoc** is the central type (Sources/FrontRange/FrontMatteredDoc/FrontMatteredDoc.swift)
- Front matter is stored as `Yams.Node.Mapping`, NOT Swift dictionaries
- Body is a plain `String`
- Struct is immutable by default; use `mutating` methods for modifications

## Yams Node Usage
- All front matter operations work with `Yams.Node` types
- Use `Node.scalar(.init("value"))` for string values, not plain Swift strings
- Convenience methods exist for common types: `setValue("string", forKey:)`, `setValue(42, forKey:)`
- Preserve YAML semantics by keeping data in Node representation

## Parser-Printer Pattern
- FrontMatteredDoc.Parser implements bidirectional conversion
- Parsing: `String` → `FrontMatteredDoc`
- Printing: `FrontMatteredDoc` → `String`
- Uses swift-parsing library for composable parsers

## CLI Command Pattern
- All commands are `ParsableCommand` structs (swift-argument-parser)
- Use `@OptionGroup var options: GlobalOptions` for shared options
- Commands located in Sources/FrontRangeCLI/Commands/
- Follow existing patterns: validate input, process files, output results

## MCP Tool Pattern
- Tools defined in `ThisServer.tools` array (Sources/FrontRangeMCP/Tools/Tools.swift)
- Each tool has a dedicated implementation file in Tools/Implementations/
- Use shared utilities from FrontRange library
- MCP tools should be non-interactive (no user prompts)

## Shared Utilities
- DataParsing.swift converts JSON/YAML/plist to Yams.Node.Mapping
- Use shared code between CLI and MCP implementations
- Don't duplicate logic across targets
