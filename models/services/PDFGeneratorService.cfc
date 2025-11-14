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
    property name="openPDFWrapper" inject="OpenPDFWrapper@pdfgenerator";

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
    public PDFResult function htmlToPDFResult(required string html, PDFOptions options) {
        var startTime = getTickCount();
        var result = new pdfgenerator.models.PDFResult();

        // Use provided options or create default
        if (isNull(arguments.options)) {
            arguments.options = createDefaultPDFOptions();
        }

        // Log operation start
        if (logBox.canDebug()) {
            logBox.debug('Starting HTML to PDF binary conversion.');
        }

        // Generate PDF as base64 string (OpenPDFWrapper now returns base64)
        var base64String = openPDFWrapper.generatePDFBase64(arguments.html, arguments.options);

        // Calculate metrics
        var generationTime = getTickCount() - startTime;
        var fileSize = len(base64String);

        // Build successful result
        result
            .setSuccess(true)
            .setBase64String(base64String)
            .setFileSize(fileSize)
            .setGenerationTime(generationTime);

        // Log success
        if (logBox.canInfo()) {
            logBox.info('PDF binary generation completed successfully. ');
        }

        return result;
    }

    /**
     * Health check - verify PDF generation capability
     *
     * @return Boolean indicating if the service is healthy
     */
    public boolean function isHealthy() {
        // Simple HTML test
        var testHTML = '<html><body><h1>Health Check</h1><p>PDF Generator is working!</p></body></html>';
        var options = createDefaultPDFOptions();

        // Try to generate a small PDF
        var result = htmlToPDFResult(testHTML, options);

        return result.isSuccess() && result.getFileSize() > 0;
    }

    /**
     * Health check - returns struct with health status and details
     */
    public struct function healthCheck() {
        var result = {};
        if (isHealthy()) {
            result['success'] = true;
            result['message'] = 'PDFGenerator is healthy.';
        } else {
            result['success'] = false;
            result['message'] = 'PDFGenerator failed health check.';
        }
        return result;
    }

    /**
     * Create default PDFOptions from module settings
     */
    private PDFOptions function createDefaultPDFOptions() {
        var options = new pdfgenerator.models.PDFOptions();
        var defaults = moduleSettings.defaultPDFOptions;

		options.setEmbedFonts(defaults.embedFonts);
        return options;
    }

    /**
     * Generate unique output file path
     */
    private string function generateOutputFilePath(required PDFOptions options) {
        var basePath = len(arguments.options.getOutputPath()) > 0 ? arguments.options.getOutputPath() : moduleSettings.defaultOutputPath;

        // Create date-based subdirectory (YYYY/MM/DD)
        var dateFormat = dateFormat(now(), 'yyyy/mm/dd');
        var outputDir = basePath & '/' & dateFormat;

        // Ensure directory exists
        if (!directoryExists(outputDir)) {
            directoryCreate(outputDir, true);
        }

        // Generate UUID-based filename
        var filename = createUUID() & '.pdf';

        return outputDir & '/' & filename;
    }

}
