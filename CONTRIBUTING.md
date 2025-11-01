# Contributing to PDFGenerator

Thank you for your interest in contributing to the PDFGenerator ColdBox module! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Testing Guidelines](#testing-guidelines)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code:

- Be respectful and inclusive
- Focus on what is best for the community
- Show empathy towards other community members
- Be patient with questions and provide helpful answers

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/PDFGenerator.git
   cd PDFGenerator
   ```
3. **Set up the upstream remote**:
   ```bash
   git remote add upstream https://github.com/aliaspooryorik/PDFGenerator.git
   ```

## Development Setup

### Prerequisites

- BoxLang >= 1.5.0 OR Lucee >= 6.2.1 OR Adobe ColdFusion >= 2025
- ColdBox Framework
- Java 8+
- Git
- CommandBox (recommended)

### Installation

1. **Download OpenPDF JARs**:
   ```bash
   cd scripts
   ./download-openpdf-jars.sh
   ```

2. **Configure your development environment** with the downloaded JARs in your classpath

3. **Install development dependencies**:
   ```bash
   box install
   ```

4. **Run tests** to verify setup:
   ```bash
   box run-script test
   ```

## Contributing Process

### 1. Create an Issue

Before starting work, please create an issue to discuss:
- Bug reports with reproduction steps
- Feature requests with use cases
- Documentation improvements
- Performance enhancements

### 2. Create a Branch

Create a feature branch from `main`:
```bash
git checkout main
git pull upstream main
git checkout -b feature/your-feature-name
```

Use descriptive branch names:
- `feature/add-watermark-support`
- `bugfix/memory-leak-large-documents`
- `docs/update-api-examples`

### 3. Make Changes

- Follow the existing code style and patterns
- Add tests for new functionality
- Update documentation as needed
- Keep commits atomic and well-described

## Testing Guidelines

### Running Tests

```bash
# Run all tests
box run-script test

# Watch mode for continuous testing
box run-script test:watch

# Run specific test
testbox run --verbose --filter="PDFOptionsTest"
```

### Writing Tests

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions
- **API Tests**: Test RESTful endpoints
- **Performance Tests**: Test with large documents

Test file structure:
```cfml
component extends="testbox.system.BaseSpec" {
    
    function beforeAll() {
        // Setup test environment
    }
    
    function afterAll() {
        // Cleanup resources
    }
    
    function run() {
        describe("Component Name", function() {
            
            it("should do something specific", function() {
                // Test implementation
                expect(result).toBeTrue();
            });
            
        });
    }
}
```

### Test Coverage

Ensure new code includes appropriate test coverage:
- **Models**: Validation, builder patterns, error handling
- **Services**: Business logic, integration points, error scenarios
- **Handlers**: HTTP endpoints, request/response handling
- **Edge Cases**: Invalid inputs, boundary conditions, performance limits

## Code Style

### ColdFusion/BoxLang Standards

- Use **4 spaces** for indentation (no tabs)
- Follow **camelCase** for variables and functions
- Use **PascalCase** for components and constructors
- Add **comprehensive documentation** with examples

### Formatting

Use CFFormat for consistent code style:
```bash
# Format all code
box run-script format

# Check formatting
box run-script format:check

# Watch for changes
box run-script format:watch
```

### Documentation

- **Component headers**: Include purpose, author, version
- **Function documentation**: Parameters, return types, examples
- **Complex logic**: Inline comments explaining the approach
- **API endpoints**: Request/response examples

Example:
```cfml
/**
 * Generate PDF from HTML content
 * 
 * @html The HTML content to convert
 * @options PDFOptions object with configuration (optional)
 * @return PDFResult object with binary data and metadata
 * 
 * @example
* var result = pdfGenerator.generatePDFBase64(
 *     "<html><body><h1>Hello PDF</h1></body></html>",
 *     new PDFOptions().setOrientation("landscape")
 * );
 */
public PDFResult function htmlToPDFBinary( required string html, PDFOptions options ) {
    // Implementation
}
```

## Pull Request Process

### Before Submitting

1. **Sync with upstream**:
   ```bash
   git checkout main
   git pull upstream main
   git checkout your-feature-branch
   git rebase main
   ```

2. **Run all tests**:
   ```bash
   box run-script test
   ```

3. **Check formatting**:
   ```bash
   box run-script format:check
   ```

4. **Update documentation** if needed

### PR Description

Include in your pull request:

- **Clear title** describing the change
- **Description** of what the PR does and why
- **Issue reference** if applicable (`Fixes #123`)
- **Testing performed** and any special considerations
- **Breaking changes** if any

### PR Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing performed
- [ ] New tests added for new functionality

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review of code performed
- [ ] Documentation updated
- [ ] No breaking changes or breaking changes documented
```

## Reporting Issues

### Bug Reports

Include:
- **Clear title** and description
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, CFML engine, versions)
- **Code samples** or test cases
- **Error messages** or stack traces

### Feature Requests

Include:
- **Use case** description
- **Proposed solution** or API
- **Alternative approaches** considered
- **Impact** on existing functionality

### Security Issues

For security vulnerabilities, please email john@aliaspooryorik.com directly instead of creating a public issue.

## Recognition

Contributors will be:
- Listed in the CHANGELOG.md
- Added to the contributors section in box.json
- Mentioned in release notes

Thank you for contributing to PDFGenerator! 🎉
