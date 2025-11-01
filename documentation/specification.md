I want to create a ColdBox module using BoxLang that will convert an HTML document into a PDF.

**IMPORTANT: This module must run on BoxLang as the primary target. The test harness and all development should use BoxLang runtime. If the module also works on ACF and/or Lucee, that is a bonus, but BoxLang compatibility is the primary requirement.**

The requirements are:

- Support for A4 portrait and A4 landscape per request
- Support for optional headers and footers per request
- Headers and footers will be defined using HTML strings
	- if the string is blank do not reader that header or footer
	- support for page numbers as placeholders, these should include {currentpage} {totalpages}
	- the header and footer (if present) should not overlap the content
	- headers and footers may contain images
- where the content is too long to fit onto one page it should dynamically create more pages in the PDF
- the PDF should be able to handle CSS styles defined in the given HTML document including but not limited to
	- colours
	- font-family
	- font-size
	- borders
	- border-radius
	- padding
	- margin
- styles could be in-line (using style attribute) or defined as CSS classes
- the document could be returned as:
	- a binary (so that it can be saved to disk as a PDF)
	- a filename with fullpath
- any libraries used should be
	- actively maintained
	- the latest versions 
- any business logic should have good code coverage with tests (TestBox)
- **Test Harness**: A complete test harness should be provided that runs on BoxLang runtime with CommandBox, allowing for easy testing and demonstration of the module functionality

I am interesed in https://github.com/LibrePDF/OpenPDF/releases/tag/3.0.0 with https://github.com/LibrePDF/OpenPDF/tree/master/openpdf-html but would consider alternatives.

## Library Choice Analysis

### OpenPDF + openpdf-html Advantages
- Direct HTML-to-PDF conversion in one step
- Supports all required CSS features (colors, fonts, borders, padding, margin)
- Designed for large document processing
- Single library dependency
- Good memory management for large documents
- Fast cold start for AWS Lambda
- Active maintenance by LibrePDF organization

### Alternative Considerations
Other libraries like Flying Saucer or iText 7 offer more advanced CSS3 features (flexbox, grid, advanced selectors) but add complexity and dependencies that aren't needed for this use case. OpenPDF with openpdf-html appears to be the optimal choice for the specified requirements.


## Clarifying Questions to Address

### Performance and Limits
- What is the expected maximum size of HTML content to be processed?

The document will be based on comments provided by end users grouped by question. The comments will be presented as an HTML list (ol). There could be 500 or 500,000 comments of varying lengths. Previous attempts to do this in Playwright have failed as the document is too bit to process.

- Should there be any timeout limits for PDF generation?

No

- What is the expected concurrent usage/load?

Intially it'll be one at a time however the ultimate goal would be to run this as a lambda on AWS so it can spin up multiple lambdas on demand as and when needed.

### CSS and External Resources
- Should external CSS files be supported (linked stylesheets)?

That would be nice but not essential. The CSS could be provided inline inside a `<style>` tag.

- How should external images be handled (URLs vs local paths)?

I'm open to using base64 encoded images or URLs or local paths depending on which is best / most robust / maintainable.

- Should web fonts be supported? If so, how should font loading be managed?

There is no need to support web fonts, but if they could be that is a bonus.

- Are there specific CSS features that should NOT be supported?

No

### Headers and Footers
- What should be the default margins when headers/footers are present?

I don't know, whatever is common.

- Should headers and footers support different content for first page vs subsequent pages?

Not required but that would be an nice option if it doesn't complicate things.

- What CSS styling options should be available for headers and footers?

Basic text styling, colours, fonts, font size and alignment. For example you may have 2 logos on the left an right and centre aligned text in the middle. The layout can be HTML tables if there isn't support for flexbox etc.

- Should headers/footers be repeated on every page or configurable per page?

Repeated on every page.

### Output and Storage
- When returning a filename, where should the file be stored? (temp directory, configurable path, etc.)

A configurable path for the module. The directory doesn't need to change per request.

- Should temporary files be automatically cleaned up? If so, when?

No

- What file naming convention should be used for generated PDFs?

I would suggest a timestamp, but a UUID is fine.

- Should there be options for PDF metadata (title, author, subject, etc.)?

Not required but a nice option.

### Error Handling
- How should malformed HTML be handled?

Reject it with an error

- What should happen if external resources (images, fonts) fail to load?

Reject it with an error

- Should there be validation of HTML input before processing?

Not a requirement

### Configuration and Customization
- Should margins be configurable per request?

Yes

- Should there be options for different paper sizes beyond A4?

Not a requirement but nice to have

- Should there be support for custom page breaks in the HTML?

Yes, this is a good point. I would like each question to start on a new page.

- Should there be options for PDF compression levels?

Not a requirement but nice to have

### Integration Requirements
- Should this integrate with existing ColdBox logging systems?

Not a requirement but it can use LogBox

- Are there specific ColdBox interceptors or events that should be fired?

No

- Should there be built-in caching mechanisms for frequently generated PDFs?

No

- What BoxLang/ColdBox version compatibility is required?

BoxLang 1.5+ (primary target)
ColdBox 7.4.2+
ACF/Lucee compatibility: Nice to have bonus, but not required 

### Security Considerations
- Should there be restrictions on HTML content (XSS prevention)?

HTML will be from a trusted source

- Should there be file size limits for generated PDFs?

No

- How should sensitive content in PDFs be handled?

Render the content provided

## Additional Technical Questions

### Large Document Processing
- Should the processing provide progress callbacks or status updates for long-running operations?

Not required but nice to have

- If processing fails partway through a large document, should there be resume/retry capabilities?

Not required but nice to have

- Should there be a maximum processing time limit before giving up?

Not required but nice to have. It should default to just waiting until done if a time limit option is added

- How should memory usage be monitored and controlled during processing?

What ever works best

### Page Break and Question Handling
- Should each question have a specific header format or styling?

Not really, they will all be rendered using a HTML header tag (probably an h2) so there could be styling of that element but that is all.

- Should there be a table of contents generated automatically?

No

- How should comments within a question be numbered or formatted?

Probably rendered as a HTML ordered list with sequential integer numbering. The start of each comment should align vertically though although it could be comment 1, 10 or 10000

- Should there be visual separators between questions beyond page breaks?

No, they would be done in the HTML provided anyway. I just want this module to convert the HTML to PDF. The styling will be done in the HTML provided.

### AWS Lambda Specific
- What is the expected maximum Lambda execution time needed?

For now it won't be deployed as a Lamba but I think that is a potential use case in the future so worth mentioned at this stage in case it has any impact on architecture.

- Should the module support both synchronous and asynchronous processing modes?

For now it won't be deployed as a Lamba but I think that is a potential use case in the future so worth mentioned at this stage in case it has any impact on architecture.

- What Lambda memory allocation is anticipated (affects library choice)?

For now it won't be deployed as a Lamba but I think that is a potential use case in the future so worth mentioned at this stage in case it has any impact on architecture.

- Should there be CloudWatch logging integration?

For now it won't be deployed as a Lamba but I think that is a potential use case in the future so worth mentioned at this stage in case it has any impact on architecture.

### HTML Structure and Content
- What is the typical structure of the HTML input (complete document vs fragment)?

It will be a complete document for the body of the PDF. Headers and footers (if supplied) I don't really mind. It should be consistent though, whichever makes integration with this module simplest.

- Should the module handle DOCTYPE declarations and HTML validation?

Not a requirement

- Are there specific HTML tags that are commonly used that need special handling?

I am expecting ol, li, p, h1, h2, h3, table, thead, tbody, tfoot, tr, th, td, hr to be commonly used

- Should there be support for HTML entities and special characters?

Yes, good point, The text could be in english and have emojis or it could also be in Japanese so needs to support rendering multiple languages.

### File Management
- Should the module support generating multiple output formats simultaneously (e.g., PDF + preview image)?

Not a requirement

- When using configurable paths, should subdirectories be created automatically?

Not a requirement but would probably make sense

- Should there be file naming collision handling?

I previously suggest using UUIDs which should cover this, but sub folders as well etc would probably be a good idea.

- What should happen if the output directory becomes full or inaccessible?

Not a consideration at this stage

### CSS and Styling Edge Cases
- How should CSS print media queries be handled?

There doesn't need to be support for CSS print media queries. The HTML documents being generated will be exclusively for conversion to PDF. Doing it as HTML as that is easy to work with and preview before conversion to a PDF. 

- Should there be fallback fonts if specified fonts are unavailable?

It only needs to support standard CSS font-family definitions.

- How should CSS grid and flexbox be handled if not fully supported?

Don't handle them - just tell me that you can't support them and the HTML documents can use tables or divs for alignment,

- Should there be CSS sanitization to remove potentially problematic styles?

No

### Error Recovery and Robustness
- If a single comment contains malformed HTML, should the entire document fail or skip that comment?

Fail the whole document

- Should there be graceful degradation for unsupported CSS features?

No

- How should character encoding issues be handled?

The text could be in english and have emojis or it could also be in Japanese so needs to support rendering multiple languages.

- Should there be validation of the final PDF before returning it?

No

## Implementation Architecture Questions

### Module Structure and API Design
- What should the main service method signature look like (parameters and return type)?

Something like `htmlToPDFFile( required string html, PDFOptions options )` PDFOptions will be optional allowing you to override the defaults. Will need a PDFOptions model.

- Should the module expose multiple methods (e.g., htmlToPDFBinary(), htmlToPDFFile()) or a single configurable method?

htmlToPDFBinary() and htmlToPDFFile()

- How should configuration be passed - as a struct, dedicated config object, or method parameters?

 dedicated config object as mentioned above

- Should there be separate methods for different output types (binary vs file) or one method with a flag?

Seperate methods

### OpenPDF Integration Specifics
- Should the module handle OpenPDF jar dependencies automatically or require manual installation?

The jars should be bundled with the module.

- How should OpenPDF logging be configured to integrate with LogBox?

Just inject LogBox and then logbox.info calls etc where approrpriate

- Should there be version compatibility checks for OpenPDF libraries on startup?

No, use the latest and greatest

### Page Break Implementation
- How should the module detect question boundaries in the HTML to insert page breaks?

The page breaks will be included in the provided HTML string. As long as the library supports page breaks (using CSS) then that is all we need.

- Should page breaks be inserted by HTML manipulation or PDF API calls?

No need to manipulate the HTML the page breaks (if wanted) will be in the HTML source string.

- What HTML element or pattern should trigger a new page (e.g., `<h2>` tags, specific CSS classes)?

No need to manipulate the HTML the page breaks (if wanted) will be in the HTML source string.

### Unicode and Multi-language Support
- Should the module auto-detect character encoding or require UTF-8?

UTF-8

- Are there specific fonts that should be bundled for Japanese character support?

Only if the library can't handle Japanese / Chinese characters etc.

- How should emoji rendering be handled if the default fonts don't support them?

I intend to use web-safe fonts which I believe will handle all emojis.

### File Naming and Organization
- Should the UUID-based filename include any prefix or suffix (e.g., "pdf_" prefix, ".pdf" extension)?

It must have a .pdf extension. Other than that it doesn't matter.

- Should subdirectories be organized by date, user, or other criteria?

I think folder based on date makes sense.

- What should the configurable base path default to if not specified?

Just create a folder in the module and use as the default

### Error Handling Specifics
- What specific exception types should be thrown for different error conditions?

Thrown errors should be prefixed with the module name followed by a `.` then the specific exception (probably method name) with a message and detail

- Should error messages include details about which part of the HTML caused the failure?

Yes, where possible give details.

- How detailed should error logging be for troubleshooting large document failures?

We can use logbox debug,info,warn and fatal. Debug will be supressed in production.

### Performance and Resource Management
- Should there be configurable limits on processing batch sizes for large documents?

Not required for now.

- How should the module handle memory pressure warnings during processing?

Log it

- Should there be metrics collection for processing time and memory usage?

Not a requirement but would be a nice to have.

## Final Implementation Details

### PDFOptions Configuration Object
- What properties should the PDFOptions object include?

orientation:string (portrait|landscape), pagesize:string, header:string, footer:string, marginunit:string (pt|in) margintop:numeric, marginbottom:numeric, marginleft:numeric, marginright:numeric, embedfonts:boolean and any others you think would be useful.

- Should there be validation on PDFOptions properties (e.g., valid orientation values)?

Yes, maybe use an ENUM?

- Should PDFOptions have a builder pattern or simple property setting?

Builder would be nice.

- What should the default values be for each option?

orientation:portrait, pagesize:A4, header:, footer:, marginunit:pt margintop:20, marginbottom:20, embedfonts:true


### Module Configuration and Defaults
- Should the module have a ModuleConfig.cfc for setting default values?

Yes

- What ColdBox conventions should be followed for module structure?

Use conventions where possible

- Should there be environment-specific default configurations?

No

- How should the default output path be configured (module setting vs application setting)?

module setting

### Testing Strategy
- Should there be separate test suites for unit tests vs integration tests?

No, but put them in seperate folders in the test suite

- What test HTML documents should be created for testing large document scenarios?

Dynamically create one - use something like repeatString or a loop to generate one.

- Should there be performance benchmarks included in the test suite?

No

- How should multi-language and emoji support be tested?

Yes

### Documentation and Examples
- Should the module include sample HTML templates for common use cases?

Yes, this could be in the readme.

- What level of API documentation is needed (JavaDoc style comments)?

JavaDoc style please

- Should there be example integration code for common ColdBox patterns?

Yes in the readme

- Should there be troubleshooting guides for common OpenPDF issues?

Optional

### Module Packaging and Distribution
- Should the module be packaged for ForgeBox distribution?

Yes

- What versioning strategy should be used?

semver

- Should there be compatibility matrices for different BoxLang/ColdBox versions?

No

- How should OpenPDF library updates be handled in future versions?

Will be new development work. Updating the Jars and changes (if any) required

### Cross-Platform and Engine Compatibility

- **Primary Target**: BoxLang 1.5+ with full feature support and comprehensive testing
- **Secondary Targets**: ACF/Lucee compatibility as bonus features where possible
- **Test Strategy**: Primary test suite runs on BoxLang; optional compatibility tests for other engines
- **Feature Parity**: Core functionality should work across engines, advanced features may be BoxLang-specific
- **Documentation**: Clearly indicate any engine-specific requirements or limitations

## Technical Implementation Considerations

### OpenPDF Specific Requirements
- Which specific OpenPDF JAR files need to be bundled (core + HTML module)?

All that are required to meet the requirements

- Should the module verify OpenPDF compatibility on startup?

No

- How should OpenPDF-specific configuration be handled (font directories, temp paths)?

Add it to the ModuleConfig so it can be overridden if needed but the defauls should work out-of-the-box.

### Page Number Placeholder Implementation
- Should placeholder replacement happen before or after OpenPDF processing?

Either, whichever is the cleanest, most robust, efficient approach

- How should the module handle edge cases like {currentpage} in main content vs headers?

Do not support placeholders token replacement in the main content, only headers and footers.

- Should there be validation that placeholders are only used in headers/footers?

No - if there are any placeholders then they will be rendered as is in the main content.

### Large Document Memory Management
- Should there be memory usage logging at specific processing milestones?

We could capture memory usage at the pre and post pdf generation but it isn't a requirement.

- How should the module detect and handle out-of-memory conditions gracefully?

I don't know. This isn't a requirement so if it's not natively supported don't worry about it.

- Should there be automatic garbage collection triggers for very large documents?

No. Transients should be used where possible to allow for garbage collection to work efficiently.

### Module Integration Points
- Should the module register any custom ColdBox DSL aliases for easy injection?

I think that Coldbox does this already (module name as the suffix?) but if not then yes please.

- How should the module handle ColdBox application restarts (cleanup, reinitialization)?

Cleanup and java objects that could cause memory leaks on reinitialization etc

- Should there be health check endpoints for monitoring PDF generation capability?

Yes

### Error Context and Debugging
- Should error messages include sanitized HTML snippets showing the problematic area?

Not a requirement, probably easier to debug if it's the raw HTML

- How much of the original HTML should be logged for debugging large document failures?

Up to 100 characters if it's the HTML causing the issue

- Should there be a debug mode that preserves intermediate processing files?

Not a requirement but a nice to have.

## Final Technical Specifications

### Recommended Module Structure
```
HTMLToPDF/
├── ModuleConfig.cfc (default settings, OpenPDF config)
├── models/
│   ├── PDFOptions.cfc (builder pattern with enums)
│   └── PDFResult.cfc (return object with file path/binary data)
├── services/
│   ├── HTMLToPDFService.cfc (main API)
│   └── OpenPDFWrapper.cfc (OpenPDF integration)
├── handlers/ (if health check needed)
│   └── HealthHandler.cfc
├── lib/
│   ├── openpdf-3.0.0.jar
│   ├── openpdf-html-3.0.0.jar
│   └── openpdf-fonts-3.0.0.jar (required for font embedding option)
├── output/ (default output directory)
├── tests/
│   ├── unit/
│   └── integration/
└── README.md (with examples and troubleshooting)
```

### API Method Signatures
```javascript
// Main service methods
public binary function htmlToPDFBinary(required string html, PDFOptions options)
public string function htmlToPDFFile(required string html, PDFOptions options)

// Health check
public boolean function isHealthy()
```

### PDFOptions Builder Pattern
```javascript
component {
    // Properties with defaults
    property name="orientation" type="string" default="portrait"; // enum: portrait|landscape
    property name="pageSize" type="string" default="A4";
    property name="header" type="string" default="";
    property name="footer" type="string" default="";
    property name="marginUnit" type="string" default="pt"; // enum: pt|in
    property name="marginTop" type="numeric" default="20";
    property name="marginBottom" type="numeric" default="20";
    property name="marginLeft" type="numeric" default="20";
    property name="marginRight" type="numeric" default="20";
    property name="embedFonts" type="boolean" default="true"; // embed fonts for cross-platform consistency
    
    // Builder methods
    public PDFOptions function setOrientation(required string orientation)
    public PDFOptions function setPageSize(required string pageSize) 
    public PDFOptions function setMargins(numeric top, numeric bottom, numeric left, numeric right, string unit)
    public PDFOptions function setHeader(required string header)
    public PDFOptions function setFooter(required string footer)
    public PDFOptions function setEmbedFonts(required boolean embedFonts)
}
```

### Error Handling Conventions
```javascript
// Exception naming: HTMLToPDF.{MethodName}Exception
throw(
    type = "HTMLToPDF.ConversionException",
    message = "Failed to convert HTML to PDF",
    detail = "OpenPDF error: Invalid CSS property at line 45"
);
```

### File Organization Implementation
- **Date-based folders**: `{outputPath}/YYYY/MM/DD/`
- **UUID filenames**: `{uuid}.pdf`
- **Auto-create directories**: Ensure folder structure exists
- **Example**: `/module/output/2025/09/09/550e8400-e29b-41d4-a716-446655440000.pdf`

### Memory and Performance Monitoring
```javascript
// Optional memory logging
var memBefore = getMemoryUsage();
// PDF generation
var memAfter = getMemoryUsage();
logBox.info("PDF generation used #(memAfter-memBefore)# MB");
```

### Unicode and Multi-language Support
- **UTF-8 encoding**: Default for all string processing
- **Web-safe fonts**: Should handle most emoji/international characters
- **Font fallback**: Let OpenPDF use system fonts for missing characters
- **Test coverage**: Include Japanese text and emoji in integration tests

This specification is now complete and implementation-ready with clear technical guidance for all aspects of the HTML-to-PDF conversion module.

## Implementation Notes from Discussion

### Font Embedding Details
- **Without embedFonts=true**: PDF references system fonts but doesn't include font data; may look different on systems without specified fonts
- **With embedFonts=true**: Font data is embedded in PDF for identical appearance across all systems; results in larger file sizes
- **Use case**: Enable embedding by default for consistency, disable for very large documents (500k+ comments) to reduce file size

### OpenPDF Library Rationale
- **Chosen over alternatives**: Flying Saucer/iText 7 offer more advanced CSS3 features (flexbox, grid) but add unnecessary complexity
- **Perfect fit**: OpenPDF handles all required CSS features (colors, fonts, borders, padding, margin) with simpler integration
- **Large document capability**: Specifically designed for enterprise-scale PDF generation where Playwright failed
- **AWS Lambda ready**: Smaller footprint and faster cold starts compared to browser-based solutions

### CSS Support Strategy
- **Supported**: All basic CSS features needed for the use case (typography, colors, borders, spacing)
- **Not supported**: CSS Grid and Flexbox - use HTML tables or divs for layout instead
- **No graceful degradation**: Fail fast on unsupported features rather than producing unexpected output
- **Print media queries**: Not needed since HTML is generated exclusively for PDF conversion

### Large Document Processing Approach
- **Memory management**: Use transient objects and let Java garbage collection work efficiently
- **No chunking needed**: Let OpenPDF handle large documents natively rather than implementing custom batching
- **Page breaks**: Include CSS page breaks directly in HTML source rather than programmatic insertion
- **Progress tracking**: Optional memory logging before/after generation but not required

### Error Handling Philosophy
- **Fail-fast approach**: Reject entire document on any malformed HTML or missing resources
- **No error recovery**: Don't skip problematic sections, fail the whole operation for data integrity
- **Detailed context**: Include up to 100 characters of problematic HTML in error messages
- **Module-prefixed exceptions**: Use "HTMLToPDF.{MethodName}Exception" naming pattern

### Multi-language Support Implementation
- **UTF-8 encoding**: Required for all string processing
- **Web-safe fonts**: Should handle Japanese, Chinese, emojis without additional font bundles
- **System font fallback**: OpenPDF automatically uses system fonts for missing characters
- **No custom font management**: Rely on standard CSS font-family definitions

### File Organization Strategy
- **UUID naming**: Prevents collisions better than timestamps
- **Date-based folders**: YYYY/MM/DD structure for organization
- **Auto-directory creation**: Module should create folder structure as needed
- **No cleanup**: Don't automatically delete generated PDFs

### Testing Strategy Details
- **Dynamic test generation**: Use loops/repeatString to create large test documents rather than static files
- **Multi-language testing**: Include Japanese text and emoji scenarios in test suite
- **No performance benchmarks**: Focus on functional correctness rather than performance metrics
- **Separate test folders**: Unit and integration tests in different directories within test suite

### Module Integration Considerations
- **ColdBox DSL**: Module should register for injection (ColdBox handles this automatically)
- **Memory leak prevention**: Clean up Java objects on application restart
- **Health check endpoint**: Simple verification that OpenPDF can generate basic PDFs
- **LogBox integration**: Use standard debug/info/warn/fatal levels with debug suppressed in production

## Final Configuration Questions

### Module Identity and Versioning
- What should the actual module name be?

Options: "HTMLToPDF", "PDFGenerator", "DocumentConverter", or other suggestions?

Let's call it PDFGenerator as we could potentially want other ways to generate (such as docx-to-pdf, image-to-pdf or pptx-to-pdf etc)

- Should the initial release be v1.0.0 or start with v0.1.0 during development?

Let's go with v0.1.0 until production ready and battle tested!

- Are there any specific BoxLang/Java version requirements beyond BoxLang 1.5?

No

### API Design Details
- Should individual method calls be able to override module-level defaults, or just use the PDFOptions object?

For example, should there be a way to override the default output path at the module level vs per-request?

just use the PDFOptions object

- Should the file method return just the file path string, or a more detailed result object with metadata?

Options: Simple string path vs object with {filePath, fileSize, generationTime, etc.}

A object would be nice and gives flexibility in the future without calling code needing to change

## Final Implementation Specifications Based on Answers

### Module Identity
- **Module Name**: PDFGenerator
- **Initial Version**: v0.1.0 (development/testing phase)
- **ColdBox Registration**: `PDFGenerator@PDFGenerator`
- **ForgeBox ID**: `pdfgenerator`

### Updated Module Structure
```
PDFGenerator/
├── ModuleConfig.cfc (default settings, OpenPDF config)
├── models/
│   ├── PDFOptions.cfc (builder pattern with enums)
│   └── PDFResult.cfc (detailed return object)
├── services/
│   ├── PDFGeneratorService.cfc (main API)
│   └── OpenPDFWrapper.cfc (OpenPDF integration)
├── handlers/ (if health check needed)
│   └── HealthHandler.cfc
├── lib/
│   ├── openpdf-3.0.0.jar
│   ├── openpdf-html-3.0.0.jar
│   └── openpdf-fonts-3.0.0.jar (required for font embedding option)
├── output/ (default output directory)
├── tests/
│   ├── unit/
│   └── integration/
└── README.md (with examples and troubleshooting)
```

### Updated API Method Signatures
```javascript
// Main service methods - return detailed result objects
public PDFResult function generatePDFBase64(required string html, PDFOptions options)
public PDFResult function htmlToPDFFile(required string html, PDFOptions options)

// Health check
public boolean function isHealthy()
```

### PDFResult Object Design
```javascript
component {
    property name="success" type="boolean" default="true";
    property name="filePath" type="string" default=""; // for file method
    property name="binaryData" type="any" default=""; // for binary method
    property name="fileSize" type="numeric" default="0"; // in bytes
    property name="generationTime" type="numeric" default="0"; // in milliseconds
    property name="pageCount" type="numeric" default="0";
    property name="error" type="string" default=""; // if success=false
    property name="metadata" type="struct" default="{}"; // extensible for future features
}
```

### Configuration Override Strategy
- **Module-level defaults**: Set in ModuleConfig.cfc
- **Per-request overrides**: Only through PDFOptions object
- **No method-level overrides**: Keeps API clean and predictable
- **Consistent approach**: All configuration flows through PDFOptions

### Future Extensibility Considerations
- **Additional generators**: Module name allows for DocxToPDFGenerator, ImageToPDFGenerator, etc.
- **Result object**: Metadata struct allows new properties without breaking changes
- **API stability**: v0.1.0 → v1.0.0 transition allows for final API refinements


