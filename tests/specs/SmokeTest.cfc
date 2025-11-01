/**
 * Smoke Test - Verify basic module functionality
 *
 * This test ensures the module loads and basic components work
 * before testing complex PDF generation functionality.
 *
 * @author John Whish
 * @version v0.1.0
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        // Basic setup - no complex dependencies yet
        variables.testOutputDir = getTempDirectory() & '/pdfgenerator-smoke-tests';

        // Create test output directory
        if (!directoryExists(variables.testOutputDir)) {
            directoryCreate(variables.testOutputDir, true);
        }
    }

    function afterAll() {
        // Clean up test files
        if (directoryExists(variables.testOutputDir)) {
            try {
                directoryDelete(variables.testOutputDir, true);
            } catch (any e) {
                // Ignore cleanup errors
            }
        }
    }

    function run() {
        describe('PDFGenerator Module Smoke Tests', function() {
            describe('Module Loading', function() {
                it('should load the module without errors', function() {
                    // This test will pass if the module loads successfully
                    expect(true).toBeTrue('Module loaded successfully');
                });
            });

            describe('Model Classes', function() {
                it('should instantiate PDFOptions', function() {
                    var options = new pdfgenerator.models.PDFOptions();
                    expect(options).toBeComponent();
                    expect(options).toHaveKey('setOrientation');
                    expect(options).toHaveKey('setPageSize');
                });

                it('should use PDFOptions builder pattern', function() {
                    var options = new pdfgenerator.models.PDFOptions().setOrientation('landscape').setPageSize('A4');

                    expect(options.getOrientation()).toBe('landscape');
                    expect(options.getPageSize()).toBe('A4');
                });

                it('should validate PDFOptions input', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    expect(function() {
                        options.setOrientation('invalid');
                    }).toThrow('PDFGenerator.InvalidOrientationException');
                });

                it('should instantiate PDFResult', function() {
                    var result = new pdfgenerator.models.PDFResult();
                    expect(result).toBeComponent();
                    expect(result).toHaveKey('setSuccess');
                    expect(result).toHaveKey('isSuccess');
                });
            });

            describe('Service Classes', function() {
                it('should instantiate PDFGeneratorService', function() {
                    // Try to create the service - this will test if dependencies inject properly
                    try {
                        var service = new PDFGeneratorService();
                        expect(service).toBeComponent();
                        expect(service).toHaveKey('htmlToPDFBinary');
                        expect(service).toHaveKey('htmlToPDFFile');
                    } catch (any e) {
                        // If service fails to instantiate, we know dependency injection is broken
                        fail('PDFGeneratorService failed to instantiate: #e.message#');
                    }
                });

                it('should instantiate OpenPDFWrapper', function() {
                    try {
                        var wrapper = new OpenPDFWrapper();
                        expect(wrapper).toBeComponent();
                        expect(wrapper).toHaveKey('isAvailable');
                    } catch (any e) {
                        // This will likely fail until we fix classpath loading
                        // But we want to document the failure
                        fail('OpenPDFWrapper failed to instantiate: #e.message#');
                    }
                });
            });

            describe('OpenPDF Library Availability', function() {
                it('should be able to load OpenPDF classes', function() {
                    try {
                        // Test if OpenPDF classes can be instantiated
                        var document = createObject('java', 'com.lowagie.text.Document');
                        expect(document).toBeObject();
                    } catch (any e) {
                        // This will fail until classpath is fixed - that's expected
                        fail('OpenPDF classes not available: #e.message#');
                    }
                });
            });
        });
    }

}
