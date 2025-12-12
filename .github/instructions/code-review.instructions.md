# Code Review Guidelines

## Focus Areas

### Correctness
- Does the code do what it claims to do?
- Are edge cases handled (empty input, nil values, invalid data)?
- Is error handling appropriate and informative?
- Are YAML semantics preserved (Yams.Node usage)?

### Testing
- Are there tests for new functionality?
- Do tests cover both success and failure paths?
- Are existing tests still passing?
- Is test data realistic and comprehensive?

### Architecture
- Does code follow established patterns (parser-printer, CLI commands, MCP tools)?
- Is shared logic properly extracted and reused?
- Are dependencies appropriate and minimal?
- Is the code in the right module/target?

### Code Quality
- Is the code readable and well-structured?
- Are naming conventions followed?
- Is documentation present for public APIs?
- Are there unnecessary abstractions or over-engineering?

### Security & Safety
- Are file operations safe (proper paths, permissions)?
- Is user input validated before use?
- Are temporary files cleaned up?
- Is Swift 6 concurrency safety maintained?

## Review Tone
- Be constructive and specific
- Suggest improvements with examples
- Acknowledge good patterns and solutions
- Ask questions when intent is unclear

## Common Issues to Flag
- Using Swift dictionaries instead of Yams.Node for front matter
- CLI commands without proper error handling
- Missing tests for new features
- Duplicated logic between CLI and MCP implementations
- Breaking changes to public APIs without documentation
- Non-mutating methods that should be mutating (and vice versa)
