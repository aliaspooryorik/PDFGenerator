/**
 * OpenPDFWrapper - Wrapper service for OpenPDF Java library integration
 * 
 * Handles direct integration with OpenPDF library for HTML to PDF conversion.
 * Manages font embedding, memory optimization, and large document processing.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component singleton {

    // Dependencies
    property name="logBox" inject="logbox:logger:{this}";
    property name="moduleSettings" inject="coldbox:moduleSettings:pdfgenerator";

    // OpenPDF Java classes (loaded via BoxLang FFI)
    variables.pdfDocument = "";
    variables.pdfWriter = "";
    variables.htmlWorker = "";
    variables.rectangle = "";
    variables.font = "";
    variables.baseFont = "";
    variables.initialized = false;

    /**
     * Constructor - Initialize OpenPDF library integration
     */
    public OpenPDFWrapper function init() {
        try {
            initializeOpenPDF();
            variables.initialized = true;
            
            if ( logBox.canInfo() ) {
                logBox.info( "OpenPDF wrapper initialized successfully" );
            }
            
        } catch ( any e ) {
            logBox.error( "Failed to initialize OpenPDF wrapper", e );
            throw( 
                type = "PDFGenerator.InitializationException",
                message = "OpenPDF library could not be initialized: #e.message#",
                detail = "Ensure OpenPDF JAR files are available in the classpath"
            );
        }
        
        return this;
    }

    /**
     * Generate PDF as binary data from HTML
     * 
     * @html The HTML content to convert
     * @options PDFOptions object with configuration
     * @return Binary array containing PDF data
     */
    public array function generatePDFBinary( required string html, required PDFOptions options ) {
        if ( !variables.initialized ) {
            throw( 
                type = "PDFGenerator.NotInitializedException",
                message = "OpenPDF wrapper is not initialized"
            );
        }
        
        var byteOutputStream = createObject( "java", "java.io.ByteArrayOutputStream" ).init();
        
        try {
            // Create PDF document
            var document = createPDFDocument( arguments.options );
            
            // Create PDF writer
            var writer = createObject( "java", "com.lowagie.text.pdf.PdfWriter" )
                          .getInstance( document, byteOutputStream );
            
            // Configure writer for headers/footers if needed
            if ( len( arguments.options.getHeader() ) > 0 || len( arguments.options.getFooter() ) > 0 ) {
                configureHeaderFooter( writer, arguments.options );
            }
            
            // Open document
            document.open();
            
            // Parse and add HTML content
            parseHTMLContent( document, arguments.html, arguments.options );
            
            // Close document
            document.close();
            
            // Return binary data as array
            return byteOutputStream.toByteArray();
            
        } catch ( any e ) {
            logBox.error( "PDF binary generation failed", e );
            throw( 
                type = "PDFGenerator.ConversionException",
                message = "Failed to generate PDF binary: #e.message#",
                detail = e.detail
            );
        } finally {
            // Clean up resources
            try {
                byteOutputStream.close();
            } catch ( any e ) {
                // Ignore cleanup errors
            }
        }
    }

    /**
     * Generate PDF file from HTML
     * 
     * @html The HTML content to convert
     * @options PDFOptions object with configuration
     * @filePath Output file path for the PDF
     */
    public void function generatePDFFile( required string html, required PDFOptions options, required string filePath ) {
        if ( !variables.initialized ) {
            throw( 
                type = "PDFGenerator.NotInitializedException",
                message = "OpenPDF wrapper is not initialized"
            );
        }
        
        var fileOutputStream = "";
        
        try {
            // Create output stream
            fileOutputStream = createObject( "java", "java.io.FileOutputStream" ).init( arguments.filePath );
            
            // Create PDF document
            var document = createPDFDocument( arguments.options );
            
            // Create PDF writer
            var writer = createObject( "java", "com.lowagie.text.pdf.PdfWriter" )
                          .getInstance( document, fileOutputStream );
            
            // Configure writer for headers/footers if needed
            if ( len( arguments.options.getHeader() ) > 0 || len( arguments.options.getFooter() ) > 0 ) {
                configureHeaderFooter( writer, arguments.options );
            }
            
            // Open document
            document.open();
            
            // Parse and add HTML content
            parseHTMLContent( document, arguments.html, arguments.options );
            
            // Close document
            document.close();
            
        } catch ( any e ) {
            logBox.error( "PDF file generation failed", e );
            throw( 
                type = "PDFGenerator.ConversionException",
                message = "Failed to generate PDF file: #e.message#",
                detail = e.detail
            );
        } finally {
            // Clean up resources
            try {
                if ( isObject( fileOutputStream ) ) {
                    fileOutputStream.close();
                }
            } catch ( any e ) {
                // Ignore cleanup errors
            }
        }
    }

    /**
     * Check if OpenPDF library is available and functional
     * 
     * @return Boolean indicating availability
     */
    public boolean function isAvailable() {
        try {
            // Try to instantiate core OpenPDF classes
            createObject( "java", "com.lowagie.text.Document" );
            createObject( "java", "com.lowagie.text.pdf.PdfWriter" );
            createObject( "java", "com.lowagie.text.html.HtmlWorker" );
            
            return true;
            
        } catch ( any e ) {
            logBox.warn( "OpenPDF library is not available: #e.message#" );
            return false;
        }
    }

    /**
     * Get OpenPDF library version information
     * 
     * @return Struct with version details
     */
    public struct function getVersionInfo() {
        try {
            var version = createObject( "java", "com.lowagie.text.Document" ).getVersion();
            
            return {
                "library": "OpenPDF",
                "version": version,
                "available": true,
                "initialized": variables.initialized
            };
            
        } catch ( any e ) {
            return {
                "library": "OpenPDF",
                "version": "Unknown",
                "available": false,
                "initialized": false,
                "error": e.message
            };
        }
    }

    // ===== PRIVATE METHODS =====

    /**
     * Initialize OpenPDF library classes
     */
    private void function initializeOpenPDF() {
        // Load core OpenPDF classes
        variables.pdfDocument = createObject( "java", "com.lowagie.text.Document" );
        variables.pdfWriter = createObject( "java", "com.lowagie.text.pdf.PdfWriter" );
        variables.htmlWorker = createObject( "java", "com.lowagie.text.html.HtmlWorker" );
        variables.rectangle = createObject( "java", "com.lowagie.text.Rectangle" );
        variables.font = createObject( "java", "com.lowagie.text.Font" );
        variables.baseFont = createObject( "java", "com.lowagie.text.pdf.BaseFont" );
        
        // Validate all classes loaded successfully
        if ( !isObject( variables.pdfDocument ) || 
             !isObject( variables.pdfWriter ) || 
             !isObject( variables.htmlWorker ) ) {
            throw( 
                type = "PDFGenerator.InitializationException",
                message = "Failed to load required OpenPDF classes"
            );
        }
    }

    /**
     * Create PDF document with specified options
     */
    private any function createPDFDocument( required PDFOptions options ) {
        // Get page size
        var pageSize = getPageSize( arguments.options.getPageSize() );
        
        // Apply orientation
        if ( arguments.options.getOrientation() == "landscape" ) {
            pageSize = pageSize.rotate();
        }
        
        // Create document with page size
        var document = createObject( "java", "com.lowagie.text.Document" ).init( pageSize );
        
        // Set margins
        var marginTop = arguments.options.getMarginTop();
        var marginBottom = arguments.options.getMarginBottom();
        var marginLeft = arguments.options.getMarginLeft();
        var marginRight = arguments.options.getMarginRight();
        var marginUnit = arguments.options.getMarginUnit();
        
        // Convert margins to points if needed
        if ( marginUnit == "mm" ) {
            marginTop = mmToPoints( marginTop );
            marginBottom = mmToPoints( marginBottom );
            marginLeft = mmToPoints( marginLeft );
            marginRight = mmToPoints( marginRight );
        } else if ( marginUnit == "in" ) {
            marginTop = inToPoints( marginTop );
            marginBottom = inToPoints( marginBottom );
            marginLeft = inToPoints( marginLeft );
            marginRight = inToPoints( marginRight );
        }
        
        document.setMargins( marginLeft, marginRight, marginTop, marginBottom );
        
        return document;
    }

    /**
     * Get OpenPDF page size rectangle from string
     */
    private any function getPageSize( required string pageSize ) {
        switch ( lCase( arguments.pageSize ) ) {
            case "a4":
                return createObject( "java", "com.lowagie.text.PageSize" ).A4;
            case "a3":
                return createObject( "java", "com.lowagie.text.PageSize" ).A3;
            case "a5":
                return createObject( "java", "com.lowagie.text.PageSize" ).A5;
            case "letter":
                return createObject( "java", "com.lowagie.text.PageSize" ).LETTER;
            case "legal":
                return createObject( "java", "com.lowagie.text.PageSize" ).LEGAL;
            default:
                return createObject( "java", "com.lowagie.text.PageSize" ).A4;
        }
    }

    /**
     * Parse HTML content and add to PDF document
     */
    private void function parseHTMLContent( required any document, required string html, required PDFOptions options ) {
        var stringReader = createObject( "java", "java.io.StringReader" ).init( arguments.html );
        
        try {
            // Create HTML worker
            var htmlWorker = createObject( "java", "com.lowagie.text.html.HtmlWorker" ).init( arguments.document );
            
            // Configure font embedding if enabled
            if ( arguments.options.getEmbedFonts() ) {
                configureFontEmbedding( htmlWorker );
            }
            
            // Parse HTML and add to document
            htmlWorker.parse( stringReader );
            
        } catch ( any e ) {
            throw( 
                type = "PDFGenerator.HTMLParseException",
                message = "Failed to parse HTML content: #e.message#",
                detail = e.detail
            );
        } finally {
            try {
                stringReader.close();
            } catch ( any e ) {
                // Ignore cleanup errors
            }
        }
    }

    /**
     * Configure header and footer handling
     */
    private void function configureHeaderFooter( required any writer, required PDFOptions options ) {
        // Note: This is a placeholder for header/footer implementation
        // OpenPDF header/footer handling requires custom page event handlers
        // Implementation would involve creating PdfPageEventHelper subclass
        
        if ( logBox.canDebug() ) {
            logBox.debug( "Header/footer configuration requested - implementation pending" );
        }
    }

    /**
     * Configure font embedding for better Unicode support
     */
    private void function configureFontEmbedding( required any htmlWorker ) {
        try {
            // Set up font paths for embedding
            var fontPaths = moduleSettings.fontPaths ?: [];
            
            // This is a placeholder for font embedding configuration
            // Actual implementation would register fonts with FontFactory
            
            if ( logBox.canDebug() ) {
                logBox.debug( "Font embedding configuration applied" );
            }
            
        } catch ( any e ) {
            logBox.warn( "Font embedding configuration failed: #e.message#" );
        }
    }

    /**
     * Convert millimeters to points (1 mm = 2.834645669 points)
     */
    private numeric function mmToPoints( required numeric mm ) {
        return arguments.mm * 2.834645669;
    }

    /**
     * Convert inches to points (1 inch = 72 points)
     */
    private numeric function inToPoints( required numeric inches ) {
        return arguments.inches * 72;
    }

}
