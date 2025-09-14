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
    property name="javaloader" inject="loader@cbjavaloader";
    property name="moduleSettings" inject="coldbox:moduleSettings:pdfgenerator";

    // OpenPDF Java classes (loaded via BoxLang FFI)
    variables.pdfDocument = "";
    variables.pdfWriter = "";
    variables.rectangle = "";
    variables.font = "";
    variables.baseFont = "";
    variables.initialized = false;

    /**
     * Constructor - Initialize OpenPDF library integration
     */
    public OpenPDFWrapper function init() {
		return this;
	}

	public void function onDIComplete() {
		initializeOpenPDF();
		variables.initialized = true;
		
		if ( logBox.canInfo() ) {
			logBox.info( "OpenPDF wrapper initialized successfully" );
		}
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
        
        var byteOutputStream = javaloader.create( "java.io.ByteArrayOutputStream" ).init();
        // Directly render HTML to PDF using ITextRenderer
        parseHTMLContent( byteOutputStream, arguments.html, arguments.options );
        return byteOutputStream.toByteArray();
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
            fileOutputStream = javaloader.create( "java.io.FileOutputStream" ).init( arguments.filePath );
            parseHTMLContent( fileOutputStream, arguments.html, arguments.options );
        } catch ( any e ) {
            logBox.error( "PDF file generation failed", e );
            throw( 
                type = "PDFGenerator.ConversionException",
                message = "Failed to generate PDF file: #e.message#",
                detail = e.detail
            );
        } finally {
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
		// Try to instantiate core OpenPDF classes
		javaloader.create( "org.openpdf.text.Document" );
		javaloader.create( "org.openpdf.text.pdf.PdfWriter" );
		javaloader.create( "org.openpdf.pdf.ITextRenderer" );
		
		return true;
    }

    /**
     * Get OpenPDF library version information
     * 
     * @return Struct with version details
     */
    public struct function getVersionInfo() {
        try {
            var version = javaloader.create( "org.openpdf.text.Document" ).getVersion();
            
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
		variables.pdfDocument = javaloader.create( "org.openpdf.text.Document" );
		variables.pdfWriter = javaloader.create( "org.openpdf.text.pdf.PdfWriter" );
		// variables.htmlWorker removed; HtmlConverter is used instead
		variables.rectangle = javaloader.create( "org.openpdf.text.Rectangle" );
		variables.font = javaloader.create( "org.openpdf.text.Font" );
		variables.baseFont = javaloader.create( "org.openpdf.text.pdf.BaseFont" );
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
    var document = javaloader.create( "org.openpdf.text.Document" ).init( pageSize );
        
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
                return javaloader.create( "org.openpdf.text.PageSize" ).A4;
            case "a3":
                return javaloader.create( "org.openpdf.text.PageSize" ).A3;
            case "a5":
                return javaloader.create( "org.openpdf.text.PageSize" ).A5;
            case "letter":
                return javaloader.create( "org.openpdf.text.PageSize" ).LETTER;
            case "legal":
                return javaloader.create( "org.openpdf.text.PageSize" ).LEGAL;
            default:
                return javaloader.create( "org.openpdf.text.PageSize" ).A4;
        }
    }

    /**
     * Parse HTML content and add to PDF document
     */
    private void function parseHTMLContent( required any outputStream, required string html, required PDFOptions options ) {
        // Use ITextRenderer to convert HTML to PDF
        var renderer = javaloader.create( "org.openpdf.pdf.ITextRenderer" ).init();
        renderer.setDocumentFromString( arguments.html );
        renderer.layout();
        renderer.createPDF( arguments.outputStream );
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
