/**
 * PDFOptions - Configuration object for PDF generation
 *
 * Builder pattern implementation for configuring PDF generation options.
 * Provides fluent API for setting orientation, margins, headers, footers, and other options.
 *
 * @author John Whish
 * @version v0.1.0
 */
component accessors="true" {

    // Properties - manual getters/setters for builder pattern
    property name="embedFonts" type="boolean";
    property name="outputPath" type="string";
    property name="metadata" type="struct";

    /**
     * Constructor
     */
    public PDFOptions function init() {
        // Initialize metadata struct
        variables.embedFonts = true;
        variables.outputPath = '';
        variables.metadata = {};
        return this;
    }

    /**
     * Add metadata to the PDF
     * @key Metadata key
     * @value Metadata value
     */
    public PDFOptions function addMetadata(required string key, required string value) {
        variables.metadata[arguments.key] = arguments.value;
        return this;
    }

}
