# PDFGenerator

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/aliaspooryorik/PDFGenerator)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![BoxLang](https://img.shields.io/badge/BoxLang-1.5+-orange.svg)](https://boxlang.io)
[![ColdBox](https://img.shields.io/badge/ColdBox-Module-red.svg)](https://coldbox.org)

> A comprehensive ColdBox module for converting HTML to PDF using the OpenPDF library

## Quick Start

```bash
# Install the module
box install pdfgenerator

# Download required JAR files  
box run-script download:jars

# Basic usage
var result = pdfGenerator.htmlToPDFBinary( "<html><body><h1>Hello PDF!</h1></body></html>" );
```

## Features

🎯 **HTML to PDF Conversion** - Convert any HTML content to PDF  
📄 **Multiple Formats** - A3, A4, A5, letter, legal page sizes  
🔄 **Orientations** - Portrait and landscape support  
📏 **Custom Margins** - Configurable in mm, inches, or points  
📝 **Headers & Footers** - With page number placeholders  
🌐 **RESTful API** - HTTP endpoints for external integration  
⚡ **High Performance** - Optimized for large documents (500k+ elements)  
🧪 **Comprehensive Tests** - 55+ test cases with full coverage  
🛠️ **Builder Pattern** - Fluent API for easy configuration  

## Installation

### 1. Install Module
```bash
box install pdfgenerator
```

### 2. Download Dependencies
```bash
box run-script download:jars
```

### 3. Configure Classpath
Add to your `Application.cfc`:
```cfml
this.javaSettings = {
    loadPaths: [
        expandPath("./modules/pdfgenerator/lib/openpdf-3.0.0.jar"),
        expandPath("./modules/pdfgenerator/lib/openpdf-html-3.0.0.jar")
    ]
};
```

## Usage

### Basic PDF Generation
```cfml
// Inject the service
property name="pdfGenerator" inject="pdfgenerator.services.PDFGeneratorService";

// Simple HTML to PDF
var html = "<html><body><h1>My Document</h1><p>Content here...</p></body></html>";
var result = pdfGenerator.htmlToPDFBinary( html );

if ( result.isSuccess() ) {
    event.renderData( type="binary", data=result.getBinaryData() );
}
```

### Advanced Configuration
```cfml
// Create custom options
var options = new pdfgenerator.models.PDFOptions()
               .setOrientation( "landscape" )
               .setPageSize( "A3" )
               .setMargins( 20, 20, 15, 15, "mm" )
               .setHeader( "Report - Page {currentpage} of {totalpages}" )
               .setFooter( "Generated: #dateFormat(now(), 'yyyy-mm-dd')#" );

// Generate PDF with options
var result = pdfGenerator.htmlToPDFFile( html, options );
```

### RESTful API
```bash
# Generate PDF via HTTP
curl -X POST http://localhost/pdfgenerator/binary \
  -H "Content-Type: application/json" \
  -d '{
    "html": "<html><body><h1>API PDF</h1></body></html>",
    "options": {
      "orientation": "portrait",
      "pageSize": "A4",
      "marginTop": 20
    }
  }'
```

## API Reference

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/pdfgenerator/binary` | Generate PDF as download |
| POST | `/pdfgenerator/file` | Generate PDF file with metadata |
| GET | `/pdfgenerator/health` | Health check |
| GET | `/pdfgenerator/test` | Test with sample PDF |

### Configuration Options

```cfml
var options = new PDFOptions()
    .setOrientation( "portrait" | "landscape" )
    .setPageSize( "A3" | "A4" | "A5" | "letter" | "legal" )
    .setMargins( top, bottom, left, right, "mm" | "in" | "pt" )
    .setEmbedFonts( true | false )
    .setHeader( "Header with {currentpage} and {totalpages}" )
    .setFooter( "Footer text" )
    .setOutputPath( "/custom/path" );
```

## Requirements

- **BoxLang** >= 1.5.0 OR **Lucee** >= 6.2.1 OR **Adobe CF** >= 2025
- **ColdBox Framework**
- **Java** 8+

## Testing

```bash
# Run all tests
box run-script test

# Watch mode
box run-script test:watch

# Format code
box run-script format
```

## Performance

✅ **Large Documents** - Tested with 500k+ HTML elements  
✅ **Memory Efficient** - Optimized resource management  
✅ **Thread Safe** - Concurrent operation support  
✅ **Fast Processing** - Enterprise-grade performance  

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

For security issues, please see [SECURITY.md](SECURITY.md) for our security policy.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📖 **Documentation**: [README.md](README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/aliaspooryorik/PDFGenerator/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/aliaspooryorik/PDFGenerator/discussions)

---

Made with ❤️ by [John Whish](https://github.com/aliaspooryorik)
