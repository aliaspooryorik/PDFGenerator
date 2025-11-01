/**
 * PDFResult - Result object returned from PDF generation operations
 *
 * Contains details about the PDF generation result including file information,
 * performance metrics, and error details if generation failed.
 *
 * @author John Whish
 * @version v0.1.0
 */
component {

    // Properties
    variables.success = true;
    variables.filePath = '';
    variables.base64String = '';
    variables.fileSize = 0;
    variables.generationTime = 0;
    variables.pageCount = 0;
    variables.error = '';
    variables.errorDetail = '';
    variables.metadata = {};

    /**
     * Constructor
     */
    public PDFResult function init() {
        variables.metadata = {};
        return this;
    }

    /**
     * Set success status
     * @success Whether the operation was successful
     */
    public PDFResult function setSuccess(required boolean success) {
        variables.success = arguments.success;
        return this;
    }

    /**
     * Set file path for file-based results
     * @filePath Full path to the generated PDF file
     */
    public PDFResult function setFilePath(required string filePath) {
        variables.filePath = arguments.filePath;
        return this;
    }

    /**
     * Set base64 string representation of the PDF
     * @base64String The PDF base64 string
     */
    public PDFResult function setBase64String(required string base64String) {
        variables.base64String = arguments.base64String;
        return this;
    }

    /**
     * Set file size in bytes
     * @fileSize The size of the generated PDF in bytes
     */
    public PDFResult function setFileSize(required numeric fileSize) {
        variables.fileSize = arguments.fileSize;
        return this;
    }

    /**
     * Set generation time in milliseconds
     * @generationTime Time taken to generate the PDF in milliseconds
     */
    public PDFResult function setGenerationTime(required numeric generationTime) {
        variables.generationTime = arguments.generationTime;
        return this;
    }

    /**
     * Set page count
     * @pageCount Number of pages in the generated PDF
     */
    public PDFResult function setPageCount(required numeric pageCount) {
        variables.pageCount = arguments.pageCount;
        return this;
    }

    /**
     * Set error message for failed operations
     * @error Error message
     * @errorDetail Detailed error information
     */
    public PDFResult function setError(required string error, string errorDetail = '') {
        variables.error = arguments.error;
        variables.errorDetail = arguments.errorDetail;
        variables.success = false;
        return this;
    }

    /**
     * Add metadata
     * @key Metadata key
     * @value Metadata value
     */
    public PDFResult function addMetadata(required string key, required any value) {
        variables.metadata[arguments.key] = arguments.value;
        return this;
    }

    /**
     * Set multiple metadata properties
     * @metadata Struct of metadata key-value pairs
     */
    public PDFResult function setMetadata(required struct metadata) {
        variables.metadata = arguments.metadata;
        return this;
    }

    /**
     * Check if the operation was successful
     */
    public boolean function isSuccess() {
        return variables.success;
    }

    /**
     * Check if there was an error
     */
    public boolean function hasError() {
        return !variables.success || len(variables.error) > 0;
    }

    /**
     * Get formatted file size in human-readable format
     */
    public string function getFormattedFileSize() {
        if (variables.fileSize == 0) return '0 bytes';

        var units = ['bytes', 'KB', 'MB', 'GB'];
        var size = variables.fileSize;
        var unitIndex = 1;

        while (size >= 1024 && unitIndex < arrayLen(units)) {
            size = size / 1024;
            unitIndex++;
        }

        return numberFormat(size, '0.##') & ' ' & units[unitIndex];
    }

    /**
     * Get formatted generation time
     */
    public string function getFormattedGenerationTime() {
        if (variables.generationTime == 0) return '0ms';

        if (variables.generationTime >= 1000) {
            return numberFormat(variables.generationTime / 1000, '0.##') & 's';
        } else {
            return numberFormat(variables.generationTime, '0') & 'ms';
        }
    }


    // Getters
    public boolean function getSuccess() {
        return variables.success;
    }
    public string function getFilePath() {
        return variables.filePath;
    }
    public string function getBase64String() {
        return variables.base64String;
    }
    public numeric function getFileSize() {
        return variables.fileSize;
    }
    public numeric function getGenerationTime() {
        return variables.generationTime;
    }
    public numeric function getPageCount() {
        return variables.pageCount;
    }
    public string function getError() {
        return variables.error;
    }
    public string function getErrorDetail() {
        return variables.errorDetail;
    }
    public struct function getMetadata() {
        return variables.metadata;
    }

}
