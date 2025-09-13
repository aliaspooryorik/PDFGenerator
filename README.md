# PDFGenerator Module

A ColdBox module for converting HTML documents to PDF using the OpenPDF library. Designed for high-performance PDF generation with support for large documents, custom styling, and extensive configuration options.

## Features

- **HTML to PDF Conversion**: Convert HTML documents to PDF with CSS styling support
- **Multiple Output Formats**: Generate PDF as binary data or save to file
- **Large Document Support**: Handle documents with 500k+ elements efficiently
- **Flexible Page Configuration**: Support for A3, A4, A5, letter, and legal page sizes
- **Orientation Control**: Portrait and landscape orientation support
- **Custom Margins**: Configurable margins in mm, inches, or points
- **Headers and Footers**: Optional headers and footers with page number placeholders
- **Font Embedding**: UTF-8 character support with font embedding options
- **RESTful API**: HTTP endpoints for integration with any system
- **Health Monitoring**: Built-in health checks and performance metrics
- **ColdBox Integration**: Full dependency injection and logging support

## Project Status

**Last Updated: 2025-09-13**

This project is currently in the initial development phase. The foundational structure has been laid out, but the core functionality is not yet complete or verified.

Our immediate priority is to establish a robust testing framework to enable a Test-Driven Development (TDD) workflow. No new features will be implemented until a reliable test suite is in place to validate the core PDF generation logic. This approach will ensure high-quality, maintainable code as the project progresses.

For more details on our development strategy, please see the [Development Guide](documentation/development-guide.md).

## Troubleshooting & Known Issues

**BoxLang Version:** The project is configured to always use the latest stable BoxLang by specifying `"boxlang"` in `server.json`. This ensures you benefit from the newest features and fixes automatically.
**ColdBox Compatibility:** The `bx-compat-cfml` module must be installed for ColdBox to run correctly on BoxLang. If you see metadata or struct key errors, install it with `box install bx-compat-cfml`.
**TestBox CLI Error:** Running tests with `box testbox run` may fail due to a known compatibility issue (`Can't cast Complex Object Type Struct to String`).
**Workaround:** Start the server (`box server start --debug --verbose`) and run tests in your browser at `http://localhost:[port]/tests/runner.cfm`.
**Debugging:** Always use the `--debug --verbose` flags for detailed error output during development.
**Logs:** Check the server logs for module loading errors and other issues.
**Common Error:** If you see `The key [NAME] was not found in the struct. Valid keys are ([])`, it usually means ColdBox is missing bx-compat-cfml or a handler inheritance/config issue. Install the module and restart the server.

## Requirements

- **BoxLang**: Compatible with BoxLang runtime
- **ColdBox Framework**: Module designed for ColdBox applications
- **OpenPDF Library**: Requires OpenPDF 3.0.0 JAR files (see Installation)
- **Java 8+**: Minimum Java version for OpenPDF compatibility

## Installation

### 1. Download OpenPDF JARs

Run the provided download script to get the required JAR files:

```bash
cd PDFGenerator/scripts
./download-openpdf-jars.sh
```

This will download:
- `openpdf-3.0.0.jar` - Core OpenPDF library
- `openpdf-html-3.0.0.jar` - HTML to PDF conversion support

### 2. Configure Classpath

Add the downloaded JARs to your application classpath. See `lib/INSTALLATION.md` for detailed instructions.

### 3. Install Module

Place the PDFGenerator module in your ColdBox application's `modules` directory.

### 4. Configure Module

Add configuration to your `config/ColdBox.cfc`:

```cfml
moduleSettings = {
    pdfgenerator = {
        defaultOutputPath = expandPath("./pdf-output"),
        defaultPDFOptions = {
            orientation = "portrait",
            pageSize = "A4",
            marginTop = 20,
            marginBottom = 20,
            marginLeft = 20,
            marginRight = 20,
            marginUnit = "mm",
            embedFonts = true,
            header = "",
            footer = ""
        }
    }
};
```

## Quick Start

### Basic HTML to PDF Conversion

```cfml
// Inject the service
property name="pdfGenerator" inject="pdfgenerator.services.PDFGeneratorService";

// HTML content
var html = "
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial; margin: 20px; }
            h1 { color: #333; }
        </style>
    </head>
    <body>
        <h1>My Document</h1>
        <p>This will be converted to PDF!</p>
    </body>
    </html>
";

// Generate PDF binary
var result = pdfGenerator.htmlToPDFBinary( html );

if ( result.isSuccess() ) {
    // Return as download
    event.renderData( 
        type = "binary",
        data = result.getBinaryData()
    );
} else {
    // Handle error
    writeDump( result.getErrorMessage() );
}
```

### Advanced Configuration

```cfml
// Create custom options
var options = new pdfgenerator.models.PDFOptions()
               .setOrientation( "landscape" )
               .setPageSize( "A3" )
               .setMargins( 15, 15, 15, 15, "mm" )
               .setEmbedFonts( true )
               .setHeader( "Company Report - Page {currentpage} of {totalpages}" )
               .setFooter( "Generated on #dateFormat( now(), 'mmmm dd, yyyy' )#" );

// Generate PDF file
var result = pdfGenerator.htmlToPDFFile( html, options );

if ( result.isSuccess() ) {
    writeOutput( "PDF saved to: " & result.getFilePath() );
    writeOutput( "File size: " & result.getFormattedFileSize() );
    writeOutput( "Generation time: " & result.getFormattedGenerationTime() );
}
```

## API Endpoints

### Generate PDF Binary
```
POST /pdfgenerator/binary
Content-Type: application/json

{
  "html": "<html>...</html>",
  "options": {
    "orientation": "portrait",
    "pageSize": "A4",
    "marginTop": 20,
    "marginBottom": 20,
    "marginLeft": 20,
    "marginRight": 20,
    "marginUnit": "mm",
    "embedFonts": true,
    "header": "Header with {currentpage} and {totalpages}",
    "footer": "Footer text"
  }
}
```

### Generate PDF File
```
POST /pdfgenerator/file
```
Same request format as binary endpoint, returns file information instead of binary data.

### Health Check
```
GET /pdfgenerator/health
```

### Test Endpoint
```
GET /pdfgenerator/test
```
Generates a test PDF to verify functionality.

## Configuration Options

### PDFOptions Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `orientation` | String | "portrait" | Page orientation: "portrait" or "landscape" |
| `pageSize` | String | "A4" | Page size: "A3", "A4", "A5", "letter", "legal" |
| `marginTop` | Numeric | 20 | Top margin |
| `marginBottom` | Numeric | 20 | Bottom margin |
| `marginLeft` | Numeric | 20 | Left margin |
| `marginRight` | Numeric | 20 | Right margin |
| `marginUnit` | String | "mm" | Margin unit: "mm", "in", "pt" |
| `embedFonts` | Boolean | false | Embed fonts for better Unicode support |
| `header` | String | "" | Header text (supports {currentpage}, {totalpages}) |
| `footer` | String | "" | Footer text (supports {currentpage}, {totalpages}) |
| `outputPath` | String | "" | Custom output directory for file generation |

### Module Settings

```cfml
moduleSettings = {
    pdfgenerator = {
        // Default output directory for generated files
        defaultOutputPath = expandPath("./pdf-output"),
        
        // Font paths for embedding (optional)
        fontPaths = [
            expandPath("./fonts/arial.ttf"),
            expandPath("./fonts/times.ttf")
        ],
        
        // Default PDF options
        defaultPDFOptions = {
            orientation = "portrait",
            pageSize = "A4",
            marginTop = 20,
            marginBottom = 20,
            marginLeft = 20,
            marginRight = 20,
            marginUnit = "mm",
            embedFonts = true,
            header = "",
            footer = ""
        }
    }
};
```

## Testing

Run the test suite using TestBox:

```cfml
// In your test browser or test runner
new pdfgenerator.tests.TestRunner().run();
```

Test coverage includes:
- Service initialization and health checks
- HTML to PDF binary conversion
- PDF file generation
- Configuration option validation
- Error handling and edge cases
- Performance and memory management

## Performance

The module is designed for high-performance PDF generation:

- **Large Documents**: Tested with 500k+ HTML elements
- **Memory Efficient**: Proper resource cleanup and memory management
- **Concurrent Safe**: Thread-safe operations for multi-user environments
- **Fast Processing**: Optimized for server-side batch processing

## Error Handling

The module uses a fail-fast approach with detailed error information:

```cfml
var result = pdfGenerator.htmlToPDFBinary( html );

if ( !result.isSuccess() ) {
    // Get error details
    var errorMessage = result.getErrorMessage();
    var errorDetail = result.getErrorDetail();
    
    // Log or handle error appropriately
    logBox.error( "PDF generation failed: #errorMessage#", errorDetail );
}
```

## Troubleshooting

### Common Issues

1. **ClassNotFoundException**: Ensure OpenPDF JAR files are in the classpath
2. **NoClassDefFoundError**: Verify all three JAR files are present
3. **Memory Issues**: Increase JVM heap size for large documents
4. **Font Issues**: Use font embedding for Unicode character support

### Debug Mode

Enable debug logging in your LogBox configuration:

```cfml
logBox = {
    config = {
        loggers = {
            pdfgenerator = { levelMin="DEBUG", levelMax="FATAL" }
        }
    }
};
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This module is open source. Please check the license file for specific terms.

## Support

For issues and questions:
- Check the module documentation
- Review test cases for usage examples  
- Check application logs for detailed error information
- Use the health check endpoint to verify module status

## Version History

### v0.1.0 (Initial Release)
- HTML to PDF conversion using OpenPDF 3.0.0
- Binary and file output options
- Configurable page settings and margins
- Header and footer support with page numbers
- RESTful API endpoints
- Comprehensive test suite
- Performance optimization for large documents
