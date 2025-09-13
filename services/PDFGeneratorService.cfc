    /**
     * Health check - returns struct with health status and details
     */
    public struct function healthCheck() {
        var result = {};
        try {
            if ( isHealthy() ) {
                result["success"] = true;
                result["message"] = "PDFGenerator is healthy.";
            } else {
                result["success"] = false;
                result["message"] = "PDFGenerator failed health check.";
            }
        } catch ( any e ) {
            result["success"] = false;
            result["message"] = "Exception during health check: " & e.message;
        }
        return result;
    }
/**
 * PDFGeneratorService - Main service for HTML to PDF conversion
 * 
 * Primary interface for converting HTML documents to PDF using OpenPDF library.
 * Provides both binary and file-based output options with comprehensive configuration.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component singleton {

    // Dependencies
    property name="logBox" inject="logbox:logger:{this}";
    property name="moduleSettings" inject="coldbox:moduleSettings:pdfgenerator";
    property name="openPDFWrapper" inject="pdfgenerator.services.OpenPDFWrapper";

    /**
     * Constructor
     */
    public PDFGeneratorService function init() {
        return this;
    }

    /**
     * Convert HTML to PDF and return as binary data
     * 
     * @html The HTML content to convert
     * @options PDFOptions object with configuration (optional)
     * @return PDFResult object with binary data and metadata
     */
    public PDFResult function htmlToPDFBinary( required string html, PDFOptions options ) {
        var startTime = getTickCount();
        var result = new pdfgenerator.models.PDFResult();
        
        try {
            // Use provided options or create default
            if ( isNull( arguments.options ) ) {
                arguments.options = createDefaultPDFOptions();
            }
            
            // Validate options
            if ( !arguments.options.isValid() ) {
                return result.setError( 
                    "Invalid PDF options provided",
                    "PDFOptions validation failed: #arguments.options.toString()#"
                );
            }
            
            // Log operation start
            if ( logBox.canDebug() ) {
                logBox.debug( "Starting HTML to PDF binary conversion. Options: #arguments.options.toString()#" );
            }
            
            // Process placeholders in headers/footers
            var processedOptions = processPlaceholders( arguments.options, arguments.html );
            
            // Generate PDF binary data
            var binaryData = openPDFWrapper.generatePDFBinary( arguments.html, processedOptions );
            
            // Calculate metrics
            var generationTime = getTickCount() - startTime;
            var fileSize = arrayLen( binaryData );
            
            // Build successful result
            result.setSuccess( true )
                  .setBinaryData( binaryData )
                  .setFileSize( fileSize )
                  .setGenerationTime( generationTime );
            
            // Log success
            if ( logBox.canInfo() ) {
                logBox.info( "PDF binary generation completed successfully. " & result.toString() );
            }
            
            return result;
            
        } catch ( any e ) {
            var generationTime = getTickCount() - startTime;
            
            logBox.error( "PDF binary generation failed", e );
            
            return result.setError( 
                "PDFGenerator.ConversionException: #e.message#",
                "Error detail: #e.detail# | Stack trace: #e.stackTrace#"
            ).setGenerationTime( generationTime );
        }
    }

    /**
     * Convert HTML to PDF and save to file
     * 
     * @html The HTML content to convert
     * @options PDFOptions object with configuration (optional)
     * @return PDFResult object with file path and metadata
     */
    public PDFResult function htmlToPDFFile( required string html, PDFOptions options ) {
        var startTime = getTickCount();
        var result = new pdfgenerator.models.PDFResult();
        
        try {
            // Use provided options or create default
            if ( isNull( arguments.options ) ) {
                arguments.options = createDefaultPDFOptions();
            }
            
            // Validate options
            if ( !arguments.options.isValid() ) {
                return result.setError( 
                    "Invalid PDF options provided",
                    "PDFOptions validation failed: #arguments.options.toString()#"
                );
            }
            
            // Generate output file path
            var filePath = generateOutputFilePath( arguments.options );
            
            // Log operation start
            if ( logBox.canDebug() ) {
                logBox.debug( "Starting HTML to PDF file conversion. Target: #filePath# | Options: #arguments.options.toString()#" );
            }
            
            // Process placeholders in headers/footers
            var processedOptions = processPlaceholders( arguments.options, arguments.html );
            
            // Generate PDF file
            openPDFWrapper.generatePDFFile( arguments.html, processedOptions, filePath );
            
            // Calculate metrics
            var generationTime = getTickCount() - startTime;
            var fileSize = 0;
            
            if ( fileExists( filePath ) ) {
                var fileInfo = getFileInfo( filePath );
                fileSize = fileInfo.size;
            }
            
            // Build successful result
            result.setSuccess( true )
                  .setFilePath( filePath )
                  .setFileSize( fileSize )
                  .setGenerationTime( generationTime );
            
            // Log success
            if ( logBox.canInfo() ) {
                logBox.info( "PDF file generation completed successfully. " & result.toString() );
            }
            
            return result;
            
        } catch ( any e ) {
            var generationTime = getTickCount() - startTime;
            
            logBox.error( "PDF file generation failed", e );
            
            return result.setError( 
                "PDFGenerator.ConversionException: #e.message#",
                "Error detail: #e.detail# | Stack trace: #e.stackTrace#"
            ).setGenerationTime( generationTime );
        }
    }

    /**
     * Health check - verify PDF generation capability
     * 
     * @return Boolean indicating if the service is healthy
     */
    public boolean function isHealthy() {
        try {
            // Simple HTML test
            var testHTML = "<html><body><h1>Health Check</h1><p>PDF Generator is working!</p></body></html>";
            var options = createDefaultPDFOptions();
            
            // Try to generate a small PDF
            var result = htmlToPDFBinary( testHTML, options );
            
            return result.isSuccess() && result.getFileSize() > 0;
            
        } catch ( any e ) {
            logBox.error( "PDF Generator health check failed", e );
            return false;
        }
    }

    /**
     * Create default PDFOptions from module settings
     */
    private PDFOptions function createDefaultPDFOptions() {
        var options = new pdfgenerator.models.PDFOptions();
        var defaults = moduleSettings.defaultPDFOptions;
        
        return options.setOrientation( defaults.orientation )
                     .setPageSize( defaults.pageSize )
                     .setMargins( 
                         top = defaults.marginTop,
                         bottom = defaults.marginBottom,
                         left = defaults.marginLeft,
                         right = defaults.marginRight,
                         unit = defaults.marginUnit
                     )
                     .setEmbedFonts( defaults.embedFonts )
                     .setHeader( defaults.header )
                     .setFooter( defaults.footer );
    }

    /**
     * Generate unique output file path
     */
    private string function generateOutputFilePath( required PDFOptions options ) {
        var basePath = len( arguments.options.getOutputPath() ) > 0 ? 
                       arguments.options.getOutputPath() : 
                       moduleSettings.defaultOutputPath;
        
        // Create date-based subdirectory (YYYY/MM/DD)
        var dateFormat = dateFormat( now(), "yyyy/mm/dd" );
        var outputDir = basePath & "/" & dateFormat;
        
        // Ensure directory exists
        if ( !directoryExists( outputDir ) ) {
            directoryCreate( outputDir, true );
        }
        
        // Generate UUID-based filename
        var filename = createUUID() & ".pdf";
        
        return outputDir & "/" & filename;
    }

    /**
     * Process page number placeholders in headers and footers
     */
    private PDFOptions function processPlaceholders( required PDFOptions options, required string html ) {
        // Note: Actual page number replacement will be handled by OpenPDF
        // This method can be extended for pre-processing if needed
        
        var processedOptions = arguments.options;
        
        // For now, just return the options as-is
        // OpenPDF will handle {currentpage} and {totalpages} placeholders
        
        return processedOptions;
    }

}
