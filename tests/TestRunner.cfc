/**
 * Test Runner Configuration for PDFGenerator Module
 * 
 * Configures TestBox for running PDFGenerator module tests.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component {

    /**
     * Configure TestBox for this module
     */
    function configure() {
        
        // TestBox configuration
        testbox = {
            // Test directory mapping
            directory = {
                mapping = "pdfgenerator.tests.specs",
                recurse = true
            },
            
            // Reporters
            reporter = "simple",
            
            // Test bundles to execute
            bundles = [
                "pdfgenerator.tests.specs.PDFOptionsTest",
                "pdfgenerator.tests.specs.PDFGeneratorServiceTest"
            ],
            
            // Test labels to include/exclude
            labels = {
                include = [],
                exclude = []
            },
            
            // Test options
            options = {
                coverage = {
                    enabled = false,
                    pathToCapture = "pdfgenerator"
                }
            }
        };
        
        return this;
    }

    /**
     * Life-cycle method called before any tests are run
     */
    function beforeAll() {
        // Module-level setup if needed
    }

    /**
     * Life-cycle method called after all tests are run  
     */
    function afterAll() {
        // Module-level cleanup if needed
    }

}
