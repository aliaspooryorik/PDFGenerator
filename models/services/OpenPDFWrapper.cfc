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
    variables.pdfDocument = '';
    variables.pdfWriter = '';
    variables.rectangle = '';
    variables.font = '';
    variables.baseFont = '';
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

        if (logBox.canInfo()) {
            logBox.info('OpenPDF wrapper initialized successfully');
        }
    }

    /**
     * Generate PDF as base64 string from HTML
     *
     * @html The HTML content to convert
     * @options PDFOptions object with configuration
     * @return Base64 string containing PDF data
     */
    public string function generatePDFBase64(required string html, required PDFOptions options) {
        if (!variables.initialized) {
            throw(type = 'PDFGenerator.NotInitializedException', message = 'OpenPDF wrapper is not initialized');
        }
        var byteOutputStream = javaloader.create('java.io.ByteArrayOutputStream').init();
        // Directly render HTML to PDF using ITextRenderer
        parseHTMLContent(byteOutputStream, arguments.html, arguments.options);
        var bytes = byteOutputStream.toByteArray();
        // Return as base64 string for safe transport/storage
        return binaryEncode(bytes, 'base64');
    }

    /**
     * Check if OpenPDF library is available and functional
     *
     * @return Boolean indicating availability
     */
    public boolean function isAvailable() {
        // Try to instantiate core OpenPDF classes
        javaloader.create('org.openpdf.text.Document');
        javaloader.create('org.openpdf.text.pdf.PdfWriter');
        javaloader.create('org.openpdf.pdf.ITextRenderer');

        return true;
    }

    /**
     * Get OpenPDF library version information
     *
     * @return String with version details
     */
    public string function getVersionInfo() {
        return javaloader.create('org.openpdf.text.Document').getVersion();
    }

    // ===== PRIVATE METHODS =====

    /**
     * Initialize OpenPDF library classes
     */
    private void function initializeOpenPDF() {
        // Load core OpenPDF classes
        variables.pdfDocument = javaloader.create('org.openpdf.text.Document');
        variables.pdfWriter = javaloader.create('org.openpdf.text.pdf.PdfWriter');
        // variables.htmlWorker removed; HtmlConverter is used instead
        variables.rectangle = javaloader.create('org.openpdf.text.Rectangle');
        variables.font = javaloader.create('org.openpdf.text.Font');
        variables.baseFont = javaloader.create('org.openpdf.text.pdf.BaseFont');
    }

    /**
     * Parse HTML content and add to PDF document
     */
    private void function parseHTMLContent(required any outputStream, required string html, required PDFOptions options) {
        // Register fonts before rendering
        var renderer = javaloader.create('org.openpdf.pdf.ITextRenderer').init();
        if (options.getEmbedFonts()) {
			embedFonts(renderer)
        }
        renderer.setDocumentFromString(arguments.html);
        renderer.layout();
        renderer.createPDF(arguments.outputStream);
    }


    /**
     * Scan /fonts directory and embed fonts for better Unicode support
     */
    private void function embedFonts(required any renderer) {
		var fontDir = moduleSettings.fontsPath;
		var fontFiles = directoryList(fontDir, false, "path", "*.ttf|*.otf");
		for (var fontPath in fontFiles) {
			renderer.getFontResolver().addFont(fontPath, "Identity-H", true);
			if (logBox.canDebug()) {
				logBox.debug('Registered font with renderer for embedding: ' & fontPath);
			}
		}
    }

}
