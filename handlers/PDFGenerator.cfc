/**
 * PDFGenerator Handler - RESTful API endpoints for PDF generation
 * 
 * Provides HTTP endpoints for converting HTML to PDF with various output options.
 * Supports both GET (for testing) and POST (for production) requests.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component extends="coldbox.system.EventHandler" {

    // Dependencies
    property name="pdfGeneratorService" inject="pdfgenerator.services.PDFGeneratorService";
    property name="logBox" inject="logbox:logger:{this}";

    /**
     * Generate PDF from HTML and return as binary download
     * 
     * Expected POST body (JSON):
     * {
     *   "html": "<html>...</html>",
     *   "options": {
     *     "orientation": "portrait|landscape",
     *     "pageSize": "A4|A3|A5|letter|legal",
     *     "marginTop": 20,
     *     "marginBottom": 20,
     *     "marginLeft": 20,
     *     "marginRight": 20,
     *     "marginUnit": "mm|in|pt",
     *     "embedFonts": true,
     *     "header": "Header text with {currentpage} and {totalpages}",
     *     "footer": "Footer text with {currentpage} and {totalpages}"
     *   }
     * }
     */
    function binary( event, rc, prc ) {
        try {
            // Validate request method
            if ( !listFind( "POST,PUT", event.getHTTPMethod() ) ) {
                return renderErrorResponse( 
                    event, 
                    405, 
                    "Method Not Allowed", 
                    "Use POST or PUT to generate PDFs" 
                );
            }
            
            // Get request body
            var requestBody = event.getHTTPRequestData().content;
            
            if ( !len( requestBody ) ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "Request body is required with HTML content" 
                );
            }
            
            // Parse JSON request
            var requestData = "";
            try {
                requestData = deserializeJSON( requestBody );
            } catch ( any e ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "Invalid JSON in request body: #e.message#" 
                );
            }
            
            // Validate required fields
            if ( !structKeyExists( requestData, "html" ) || !len( requestData.html ) ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "HTML content is required" 
                );
            }
            
            // Build PDF options
            var pdfOptions = buildPDFOptions( structKeyExists( requestData, "options" ) ? requestData.options : {} );
            
            // Generate PDF
            var result = pdfGeneratorService.htmlToPDFBinary( requestData.html, pdfOptions );
            
            if ( !result.isSuccess() ) {
                logBox.error( "PDF generation failed: #result.getErrorMessage()#" );
                return renderErrorResponse( 
                    event, 
                    500, 
                    "PDF Generation Failed", 
                    result.getErrorMessage() 
                );
            }
            
            // Return binary PDF
            var fileName = "document_#dateFormat( now(), 'yyyymmdd' )#_#timeFormat( now(), 'HHmmss' )#.pdf";
            
            event.setHTTPHeader( name="Content-Type", value="application/pdf" );
            event.setHTTPHeader( name="Content-Disposition", value="attachment; filename=""#fileName#""" );
            event.setHTTPHeader( name="Content-Length", value="#result.getFileSize()#" );
            event.setHTTPHeader( name="X-Generation-Time", value="#result.getGenerationTime()#ms" );
            
            // Log successful generation
            if ( logBox.canInfo() ) {
                logBox.info( "PDF binary generated successfully. " & result.toString() );
            }
            
            event.renderData( 
                type = "binary",
                data = result.getBinaryData()
            );
            
        } catch ( any e ) {
            logBox.error( "PDF binary endpoint error", e );
            return renderErrorResponse( 
                event, 
                500, 
                "Internal Server Error", 
                "An unexpected error occurred during PDF generation" 
            );
        }
    }

    /**
     * Generate PDF from HTML and save to file, return file information
     */
    function file( event, rc, prc ) {
        try {
            // Validate request method
            if ( !listFind( "POST,PUT", event.getHTTPMethod() ) ) {
                return renderErrorResponse( 
                    event, 
                    405, 
                    "Method Not Allowed", 
                    "Use POST or PUT to generate PDFs" 
                );
            }
            
            // Get request body
            var requestBody = event.getHTTPRequestData().content;
            
            if ( !len( requestBody ) ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "Request body is required with HTML content" 
                );
            }
            
            // Parse JSON request
            var requestData = "";
            try {
                requestData = deserializeJSON( requestBody );
            } catch ( any e ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "Invalid JSON in request body: #e.message#" 
                );
            }
            
            // Validate required fields
            if ( !structKeyExists( requestData, "html" ) || !len( requestData.html ) ) {
                return renderErrorResponse( 
                    event, 
                    400, 
                    "Bad Request", 
                    "HTML content is required" 
                );
            }
            
            // Build PDF options
            var pdfOptions = buildPDFOptions( structKeyExists( requestData, "options" ) ? requestData.options : {} );
            
            // Generate PDF file
            var result = pdfGeneratorService.htmlToPDFFile( requestData.html, pdfOptions );
            
            if ( !result.isSuccess() ) {
                logBox.error( "PDF file generation failed: #result.getErrorMessage()#" );
                return renderErrorResponse( 
                    event, 
                    500, 
                    "PDF Generation Failed", 
                    result.getErrorMessage() 
                );
            }
            
            // Log successful generation
            if ( logBox.canInfo() ) {
                logBox.info( "PDF file generated successfully. " & result.toString() );
            }
            
            // Return file information
            event.renderData( 
                type = "json",
                data = {
                    "success": true,
                    "filePath": result.getFilePath(),
                    "fileSize": result.getFileSize(),
                    "formattedFileSize": result.getFormattedFileSize(),
                    "generationTime": result.getGenerationTime(),
                    "formattedGenerationTime": result.getFormattedGenerationTime(),
                    "timestamp": now()
                },
                statusCode = 201
            );
            
        } catch ( any e ) {
            logBox.error( "PDF file endpoint error", e );
            return renderErrorResponse( 
                event, 
                500, 
                "Internal Server Error", 
                "An unexpected error occurred during PDF generation" 
            );
        }
    }

    /**
     * Health check endpoint
     */
    function health( event, rc, prc ) {
        try {
            var isHealthy = pdfGeneratorService.isHealthy();
            var statusCode = isHealthy ? 200 : 503;
            
            event.renderData( 
                type = "json",
                data = {
                    "status": isHealthy ? "healthy" : "unhealthy",
                    "service": "PDFGenerator",
                    "version": "v0.1.0",
                    "timestamp": now(),
                    "checks": {
                        "pdfGeneration": isHealthy
                    }
                },
                statusCode = statusCode
            );
            
        } catch ( any e ) {
            logBox.error( "Health check error", e );
            event.renderData( 
                type = "json",
                data = {
                    "status": "unhealthy",
                    "service": "PDFGenerator",
                    "version": "v0.1.0",
                    "timestamp": now(),
                    "error": e.message
                },
                statusCode = 503
            );
        }
    }

    /**
     * Simple test endpoint with sample HTML
     */
    function test( event, rc, prc ) {
        // Only allow GET for test endpoint
        if ( event.getHTTPMethod() != "GET" ) {
            return renderErrorResponse( 
                event, 
                405, 
                "Method Not Allowed", 
                "Use GET for test endpoint" 
            );
        }
        
        try {
            // Sample HTML content
            var testHTML = "
                <!DOCTYPE html>
                <html>
                <head>
                    <title>PDF Generator Test</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 40px; }
                        h1 { color: ##333; border-bottom: 2px solid ##007acc; }
                        .highlight { background-color: ##f0f8ff; padding: 10px; border-left: 4px solid ##007acc; }
                        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
                        th, td { border: 1px solid ##ddd; padding: 8px; text-align: left; }
                        th { background-color: ##f2f2f2; }
                    </style>
                </head>
                <body>
                    <h1>PDF Generator Test Document</h1>
                    <p>This is a test document to verify PDF generation capabilities.</p>
                    
                    <div class='highlight'>
                        <strong>Generated:</strong> #dateFormat( now(), 'mmmm dd, yyyy' )# at #timeFormat( now(), 'h:mm:ss tt' )#
                    </div>
                    
                    <h2>Features Tested</h2>
                    <table>
                        <tr><th>Feature</th><th>Status</th></tr>
                        <tr><td>HTML Parsing</td><td>✓ Working</td></tr>
                        <tr><td>CSS Styling</td><td>✓ Working</td></tr>
                        <tr><td>Tables</td><td>✓ Working</td></tr>
                        <tr><td>UTF-8 Text</td><td>✓ Working: àáâãäåæçèéêë</td></tr>
                    </table>
                    
                    <h2>Lorem Ipsum</h2>
                    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
                </body>
                </html>
            ";
            
            // Use default options
            var pdfOptions = new pdfgenerator.models.PDFOptions();
            
            // Generate PDF
            var result = pdfGeneratorService.htmlToPDFBinary( testHTML, pdfOptions );
            
            if ( !result.isSuccess() ) {
                return renderErrorResponse( 
                    event, 
                    500, 
                    "PDF Generation Failed", 
                    result.getErrorMessage() 
                );
            }
            
            // Return binary PDF
            var fileName = "pdfgenerator_test_#dateFormat( now(), 'yyyymmdd' )#_#timeFormat( now(), 'HHmmss' )#.pdf";
            
            event.setHTTPHeader( name="Content-Type", value="application/pdf" );
            event.setHTTPHeader( name="Content-Disposition", value="attachment; filename=""#fileName#""" );
            event.setHTTPHeader( name="Content-Length", value="#result.getFileSize()#" );
            event.setHTTPHeader( name="X-Generation-Time", value="#result.getGenerationTime()#ms" );
            
            event.renderData( 
                type = "binary",
                data = result.getBinaryData()
            );
            
        } catch ( any e ) {
            logBox.error( "PDF test endpoint error", e );
            return renderErrorResponse( 
                event, 
                500, 
                "Internal Server Error", 
                "Test PDF generation failed: #e.message#" 
            );
        }
    }

    // ===== PRIVATE METHODS =====

    /**
     * Build PDFOptions object from request data
     */
    private PDFOptions function buildPDFOptions( required struct optionsData ) {
        var options = new pdfgenerator.models.PDFOptions();
        
        // Set orientation
        if ( structKeyExists( arguments.optionsData, "orientation" ) ) {
            options.setOrientation( arguments.optionsData.orientation );
        }
        
        // Set page size
        if ( structKeyExists( arguments.optionsData, "pageSize" ) ) {
            options.setPageSize( arguments.optionsData.pageSize );
        }
        
        // Set margins
        if ( structKeyExists( arguments.optionsData, "marginTop" ) || 
             structKeyExists( arguments.optionsData, "marginBottom" ) ||
             structKeyExists( arguments.optionsData, "marginLeft" ) ||
             structKeyExists( arguments.optionsData, "marginRight" ) ) {
            
            var marginTop = structKeyExists( arguments.optionsData, "marginTop" ) ? arguments.optionsData.marginTop : 20;
            var marginBottom = structKeyExists( arguments.optionsData, "marginBottom" ) ? arguments.optionsData.marginBottom : 20;
            var marginLeft = structKeyExists( arguments.optionsData, "marginLeft" ) ? arguments.optionsData.marginLeft : 20;
            var marginRight = structKeyExists( arguments.optionsData, "marginRight" ) ? arguments.optionsData.marginRight : 20;
            var marginUnit = structKeyExists( arguments.optionsData, "marginUnit" ) ? arguments.optionsData.marginUnit : "mm";
            
            options.setMargins( marginTop, marginBottom, marginLeft, marginRight, marginUnit );
        }
        
        // Set font embedding
        if ( structKeyExists( arguments.optionsData, "embedFonts" ) ) {
            options.setEmbedFonts( arguments.optionsData.embedFonts );
        }
        
        // Set header
        if ( structKeyExists( arguments.optionsData, "header" ) ) {
            options.setHeader( arguments.optionsData.header );
        }
        
        // Set footer
        if ( structKeyExists( arguments.optionsData, "footer" ) ) {
            options.setFooter( arguments.optionsData.footer );
        }
        
        // Set output path
        if ( structKeyExists( arguments.optionsData, "outputPath" ) ) {
            options.setOutputPath( arguments.optionsData.outputPath );
        }
        
        return options;
    }

    /**
     * Render standardized error response
     */
    private void function renderErrorResponse( required event, required numeric statusCode, required string error, required string message ) {
        arguments.event.renderData( 
            type = "json",
            data = {
                "success": false,
                "error": arguments.error,
                "message": arguments.message,
                "timestamp": now()
            },
            statusCode = arguments.statusCode
        );
    }

}
