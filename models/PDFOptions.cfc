/**
 * PDFOptions - Configuration object for PDF generation
 * 
 * Builder pattern implementation for configuring PDF generation options.
 * Provides fluent API for setting orientation, margins, headers, footers, and other options.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component {

    // Properties - manual getters/setters for builder pattern
    variables.orientation = "portrait";
    variables.pageSize = "A4";
    variables.header = "";
    variables.footer = "";
    variables.marginUnit = "pt";
    variables.marginTop = 20;
    variables.marginBottom = 20; 
    variables.marginLeft = 20;
    variables.marginRight = 20;
    variables.embedFonts = true;
    variables.outputPath = "";
    variables.metadata = {};

    // Valid enum values
    variables.validOrientations = [ "portrait", "landscape" ];
    variables.validPageSizes = [ "A4", "A3", "A5", "LETTER", "LEGAL" ];
    variables.validMarginUnits = [ "pt", "in", "mm", "cm" ];

    /**
     * Constructor
     */
    public PDFOptions function init() {
        // Initialize metadata struct
        variables.metadata = {};
        return this;
    }

    /**
     * Set orientation with validation
     * @orientation The page orientation (portrait or landscape)
     */
    public PDFOptions function setOrientation( required string orientation ) {
        if ( !arrayContains( variables.validOrientations, arguments.orientation ) ) {
            throw(
                type = "PDFGenerator.InvalidOrientationException",
                message = "Invalid orientation specified",
                detail = "Orientation must be one of: #arrayToList( variables.validOrientations )#. Received: #arguments.orientation#"
            );
        }
        variables.orientation = arguments.orientation;
        return this;
    }

    /**
     * Set page size with validation
     * @pageSize The page size (A4, A3, A5, LETTER, LEGAL)
     */
    public PDFOptions function setPageSize( required string pageSize ) {
        if ( !arrayContains( variables.validPageSizes, ucase( arguments.pageSize ) ) ) {
            throw(
                type = "PDFGenerator.InvalidPageSizeException", 
                message = "Invalid page size specified",
                detail = "Page size must be one of: #arrayToList( variables.validPageSizes )#. Received: #arguments.pageSize#"
            );
        }
        variables.pageSize = ucase( arguments.pageSize );
        return this;
    }

    /**
     * Set all margins at once
     * @top Top margin
     * @bottom Bottom margin  
     * @left Left margin
     * @right Right margin
     * @unit Margin unit (pt, in, mm, cm)
     */
    public PDFOptions function setMargins( 
        numeric top = 20,
        numeric bottom = 20, 
        numeric left = 20,
        numeric right = 20,
        string unit = "pt"
    ) {
        if ( !arrayContains( variables.validMarginUnits, arguments.unit ) ) {
            throw(
                type = "PDFGenerator.InvalidMarginUnitException",
                message = "Invalid margin unit specified", 
                detail = "Margin unit must be one of: #arrayToList( variables.validMarginUnits )#. Received: #arguments.unit#"
            );
        }
        
        variables.marginTop = arguments.top;
        variables.marginBottom = arguments.bottom;
        variables.marginLeft = arguments.left;
        variables.marginRight = arguments.right;
        variables.marginUnit = arguments.unit;
        return this;
    }

    /**
     * Set header HTML content
     * @header HTML content for header
     */
    public PDFOptions function setHeader( required string header ) {
        variables.header = arguments.header;
        return this;
    }

    /**
     * Set footer HTML content  
     * @footer HTML content for footer
     */
    public PDFOptions function setFooter( required string footer ) {
        variables.footer = arguments.footer;
        return this;
    }

    /**
     * Set font embedding option
     * @embedFonts Whether to embed fonts for cross-platform consistency
     */
    public PDFOptions function setEmbedFonts( required boolean embedFonts ) {
        variables.embedFonts = arguments.embedFonts;
        return this;
    }

    /**
     * Set custom output path (overrides module default)
     * @outputPath Full path to output directory
     */
    public PDFOptions function setOutputPath( required string outputPath ) {
        variables.outputPath = arguments.outputPath;
        return this;
    }

    /**
     * Add metadata to the PDF
     * @key Metadata key
     * @value Metadata value
     */
    public PDFOptions function addMetadata( required string key, required string value ) {
        variables.metadata[ arguments.key ] = arguments.value;
        return this;
    }

    /**
     * Set multiple metadata properties
     * @metadata Struct of metadata key-value pairs
     */
    public PDFOptions function setMetadata( required struct metadata ) {
        variables.metadata = arguments.metadata;
        return this;
    }

    /**
     * Validate all settings
     */
    public boolean function isValid() {
        try {
            // Validate orientation
            if ( !arrayContains( variables.validOrientations, variables.orientation ) ) {
                return false;
            }
            
            // Validate page size  
            if ( !arrayContains( variables.validPageSizes, variables.pageSize ) ) {
                return false;
            }
            
            // Validate margin unit
            if ( !arrayContains( variables.validMarginUnits, variables.marginUnit ) ) {
                return false;
            }
            
            // Validate margin values are positive
            if ( variables.marginTop < 0 || variables.marginBottom < 0 || 
                 variables.marginLeft < 0 || variables.marginRight < 0 ) {
                return false;
            }
            
            return true;
        } catch ( any e ) {
            return false;
        }
    }

    /**
     * Get a summary of current settings for debugging
     */
    public string function toString() {
        return "PDFOptions[orientation=#variables.orientation#, pageSize=#variables.pageSize#, " &
               "margins=#variables.marginTop#/#variables.marginRight#/#variables.marginBottom#/#variables.marginLeft# #variables.marginUnit#, " &
               "embedFonts=#variables.embedFonts#, hasHeader=#len( variables.header ) > 0#, hasFooter=#len( variables.footer ) > 0#]";
    }

    // Simple getters
    public string function getOrientation() { return variables.orientation; }
    public string function getPageSize() { return variables.pageSize; }
    public string function getHeader() { return variables.header; }
    public string function getFooter() { return variables.footer; }
    public string function getMarginUnit() { return variables.marginUnit; }
    public numeric function getMarginTop() { return variables.marginTop; }
    public numeric function getMarginBottom() { return variables.marginBottom; }
    public numeric function getMarginLeft() { return variables.marginLeft; }
    public numeric function getMarginRight() { return variables.marginRight; }
    public boolean function getEmbedFonts() { return variables.embedFonts; }
    public string function getOutputPath() { return variables.outputPath; }
    public struct function getMetadata() { return variables.metadata; }

}
