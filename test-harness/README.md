# PDFGenerator Test Harness

This test harness provides a complete testing environment for the PDFGenerator ColdBox module, including both integration tests and a web interface for manual testing.

## Quick Start

### Prerequisites

- CommandBox CLI installed
- BoxLang runtime (will be downloaded automatically)

### Starting the Test Harness

**Linux/macOS:**
```bash
./start-test-harness.sh
```

**Windows:**
```batch
start-test-harness.bat
```

**Manual Start:**
```bash
cd test-harness
box install
box server start
```

The test harness will be available at: http://127.0.0.1:8080

## Available Endpoints

### Web Interface

- **Home Page**: http://127.0.0.1:8080
  - Interactive testing interface
  - Basic PDF generation test
  - Advanced PDF generation test (landscape, custom margins)
  - Health check interface

### Test Runners

- **Unit Tests**: http://127.0.0.1:8080/tests/runner.cfm
  - Runs the complete TestBox test suite
  - Includes integration tests for all module functionality

- **Test Browser**: http://127.0.0.1:8080/tests/
  - Browse and run individual test files
  - Useful for debugging specific tests

### API Endpoints

The test harness also exposes the module's REST API endpoints:

- `GET /main/testBasicConversion` - Download a basic test PDF
- `GET /main/testAdvancedConversion` - Download an advanced test PDF  
- `GET /main/testHealthCheck` - View health check results

## Test Structure

```
test-harness/
├── Application.cfc              # Main application config
├── server.json                  # Server configuration
├── box.json                     # Dependencies
├── config/
│   ├── Coldbox.cfc             # ColdBox configuration
│   └── WireBox.cfc             # Dependency injection config
├── handlers/
│   └── Main.cfc                # Test handlers
├── layouts/
│   └── Main.cfm                # Main layout template
├── views/main/
│   ├── index.cfm               # Home page
│   ├── error.cfm               # Error display
│   └── health.cfm              # Health check results
└── tests/
    ├── Application.cfc         # Test application config
    ├── runner.cfm              # TestBox runner
    ├── index.cfm               # Test browser
    └── specs/
        └── IntegrationTest.cfc # Integration tests
```

## Module Testing

The test harness automatically loads the PDFGenerator module and makes it available for testing. You can:

1. **Use the Web Interface**: Click the test buttons on the home page to generate PDFs
2. **Run Unit Tests**: Use the TestBox runner to execute automated tests
3. **Manual API Testing**: Use curl or Postman to test the API endpoints directly

## Configuration

The test harness is configured to:

- Run on port 8080 by default
- Use BoxLang runtime
- Load the PDFGenerator module automatically
- Enable debug mode for detailed error reporting

## Troubleshooting

### Server Won't Start

1. Check that CommandBox is installed: `box version`
2. Ensure port 8080 is available
3. Check the server logs: `box server log`

### Module Not Loading

1. Verify the PDFGenerator module is in the parent directory
2. Check the ModuleConfig.cfc for syntax errors
3. Review the ColdBox application logs

### PDF Generation Fails

1. Check that OpenPDF JARs are present in the `lib/` directory
2. Verify Java classpath configuration
3. Check BoxLang Java integration settings

For more help, see the main module documentation in the parent directory.
