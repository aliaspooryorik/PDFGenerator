# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-09-09

### Added
- Initial release of PDFGenerator ColdBox module
- HTML to PDF conversion using OpenPDF 3.0.0 library
- Support for large documents (500k+ HTML elements)
- Configurable page formats (A3, A4, A5, letter, legal)
- Portrait and landscape orientation support
- Custom margins in mm, inches, or points
- Headers and footers with page number placeholders (`{currentpage}`, `{totalpages}`)
- Font embedding for UTF-8 character support
- RESTful API endpoints:
  - `POST /pdfgenerator/binary` - Generate PDF as binary download
  - `POST /pdfgenerator/file` - Generate PDF file with metadata
  - `GET /pdfgenerator/health` - Health check endpoint
  - `GET /pdfgenerator/test` - Test endpoint with sample PDF
- ColdBox dependency injection and LogBox logging integration
- Builder pattern PDFOptions model with validation
- Comprehensive PDFResult object with metadata and error handling
- Main PDFGeneratorService with `htmlToPDFBinary()` and `htmlToPDFFile()` methods
- OpenPDFWrapper service for Java library integration
- Automated JAR download script (`download-openpdf-jars.sh`)
- Complete test suite with 55+ test cases covering:
  - Service functionality and initialization
  - HTML to PDF conversion (binary and file)
  - Configuration options and validation
  - Error handling and edge cases
  - Performance and memory management
- Comprehensive documentation with usage examples
- Installation guide with classpath configuration
- Performance optimization for enterprise-scale usage
- Thread-safe concurrent operation support
- Fail-fast error handling with detailed reporting
- Resource management and memory cleanup

### Dependencies
- OpenPDF 3.0.0 (core library)
- OpenPDF HTML 3.0.0 (HTML to PDF conversion)

### Requirements
- BoxLang >= 1.5.0 OR Lucee >= 6.2.1 OR Adobe ColdFusion >= 2025
- ColdBox Framework
- Java 8+

[Unreleased]: https://github.com/aliaspooryorik/PDFGenerator/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/aliaspooryorik/PDFGenerator/releases/tag/v0.1.0
