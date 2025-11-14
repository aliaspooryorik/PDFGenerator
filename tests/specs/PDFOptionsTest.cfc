/**
 * Test Suite for PDFOptions Model
 *
 * Tests for the PDFOptions builder pattern model including validation,
 * fluent API methods, and configuration handling.
 *
 * @author John Whish
 * @version v0.1.0
 */
component extends="testbox.system.BaseSpec" {

    function run() {
        describe('PDFOptions Model', function() {
            describe('Initialization', function() {
                it('should initialize with default values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    expect(options).toBeComponent();
                    expect(options.getOrientation()).toBe('portrait');
                    expect(options.getMarginTop()).toBe(20);
                    expect(options.getMarginBottom()).toBe(20);
                    expect(options.getMarginLeft()).toBe(20);
                    expect(options.getMarginRight()).toBe(20);
                    expect(options.getMarginUnit()).toBe('mm');
                    expect(options.getEmbedFonts()).toBeFalse();
                    expect(options.getHeader()).toBe('');
                    expect(options.getFooter()).toBe('');
                    expect(options.getOutputPath()).toBe('');
                });
            });

            describe('Builder Pattern Methods', function() {
                it('should support fluent orientation setting', function() {
                    var options = new pdfgenerator.models.PDFOptions().setOrientation('landscape');

                    expect(options).toBeComponent();
                    expect(options.getOrientation()).toBe('landscape');
                });

                it('should support fluent page size setting', function() {
                    var options = new pdfgenerator.models.PDFOptions().setPageSize('A3');

                });

                it('should support fluent margin setting', function() {
                    var options = new pdfgenerator.models.PDFOptions().setMargins(30, 40, 25, 35, 'pt');

                    expect(options.getMarginTop()).toBe(30);
                    expect(options.getMarginBottom()).toBe(40);
                    expect(options.getMarginLeft()).toBe(25);
                    expect(options.getMarginRight()).toBe(35);
                    expect(options.getMarginUnit()).toBe('pt');
                });

                it('should support method chaining', function() {
                    var options = new pdfgenerator.models.PDFOptions()
                        .setOrientation('landscape')
                        .setPageSize('A3')
                        .setMargins(10, 10, 10, 10, 'mm')
                        .setEmbedFonts(true)
                        .setHeader('Test Header')
                        .setFooter('Page {currentpage} of {totalpages}');

                    expect(options.getOrientation()).toBe('landscape');
                    expect(options.getMarginTop()).toBe(10);
                    expect(options.getEmbedFonts()).toBeTrue();
                    expect(options.getHeader()).toBe('Test Header');
                    expect(options.getFooter()).toBe('Page {currentpage} of {totalpages}');
                });
            });

            describe('Validation', function() {
                it('should validate orientation values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Valid orientations should pass
                    options.setOrientation('portrait');
                    expect(options.isValid()).toBeTrue();

                    options.setOrientation('landscape');
                    expect(options.isValid()).toBeTrue();

                    // Invalid orientation should fail
                    options.setOrientation('invalid');
                    expect(options.isValid()).toBeFalse();
                });

                it('should validate page size values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Valid page sizes should pass
                    var validSizes = ['A3', 'A4', 'A5', 'letter', 'legal'];
                    for (var size in validSizes) {
                        options.setPageSize(size);
                        expect(options.isValid()).toBeTrue('Page size ''#size#'' should be valid');
                    }

                    // Invalid page size should fail
                    options.setPageSize('InvalidSize');
                    expect(options.isValid()).toBeFalse();
                });

                it('should validate margin unit values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Valid margin units should pass
                    var validUnits = ['mm', 'in', 'pt'];
                    for (var unit in validUnits) {
                        options.setMargins(20, 20, 20, 20, unit);
                        expect(options.isValid()).toBeTrue('Margin unit ''#unit#'' should be valid');
                    }

                    // Invalid margin unit should fail
                    options.setMargins(20, 20, 20, 20, 'invalid');
                    expect(options.isValid()).toBeFalse();
                });

                it('should validate margin numeric values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Positive margins should be valid
                    options.setMargins(10, 20, 30, 40, 'mm');
                    expect(options.isValid()).toBeTrue();

                    // Zero margins should be valid
                    options.setMargins(0, 0, 0, 0, 'mm');
                    expect(options.isValid()).toBeTrue();

                    // Negative margins should be invalid
                    options.setMargins(-10, 20, 30, 40, 'mm');
                    expect(options.isValid()).toBeFalse();
                });

                it('should validate reasonable margin ranges', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Extremely large margins should be invalid
                    options.setMargins(1000, 1000, 1000, 1000, 'mm');
                    expect(options.isValid()).toBeFalse();

                    // Reasonable margins should be valid
                    options.setMargins(50, 50, 50, 50, 'mm');
                    expect(options.isValid()).toBeTrue();
                });
            });

            describe('String Representation', function() {
                it('should provide meaningful toString output', function() {
                    var options = new pdfgenerator.models.PDFOptions()
                        .setOrientation('landscape')
                        .setPageSize('A3')
                        .setMargins(15, 15, 15, 15, 'mm');

                    var stringRep = options.toString();

                    expect(stringRep).toBeString();
                    expect(stringRep).toInclude('landscape');
                    expect(stringRep).toInclude('A3');
                    expect(stringRep).toInclude('15');
                    expect(stringRep).toInclude('mm');
                });

                it('should include all configuration options in toString', function() {
                    var options = new pdfgenerator.models.PDFOptions()
                        .setOrientation('portrait')
                        .setPageSize('A4')
                        .setEmbedFonts(true)
                        .setHeader('Test Header')
                        .setFooter('Test Footer');

                    var stringRep = options.toString();

                    expect(stringRep).toInclude('portrait');
                    expect(stringRep).toInclude('A4');
                    expect(stringRep).toInclude('true');
                    expect(stringRep).toInclude('Test Header');
                    expect(stringRep).toInclude('Test Footer');
                });
            });

            describe('Edge Cases', function() {
                it('should handle null values gracefully', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Setting null should not break the object
                    expectToThrow(function() {
                        options.setOrientation(javacast('null', ''));
                    });
                });

                it('should handle empty string values', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Empty strings should be handled appropriately
                    options.setHeader('');
                    options.setFooter('');
                    options.setOutputPath('');

                    expect(options.getHeader()).toBe('');
                    expect(options.getFooter()).toBe('');
                    expect(options.getOutputPath()).toBe('');
                    expect(options.isValid()).toBeTrue();
                });

                it('should handle very long string values', function() {
                    var options = new pdfgenerator.models.PDFOptions();
                    var longString = repeatString('A', 10000);

                    options.setHeader(longString);
                    expect(len(options.getHeader())).toBe(10000);

                    // Should still be valid (no length restrictions in base model)
                    expect(options.isValid()).toBeTrue();
                });

                it('should handle case sensitivity correctly', function() {
                    var options = new pdfgenerator.models.PDFOptions();

                    // Test case variations
                    options.setOrientation('LANDSCAPE');
                    expect(options.isValid()).toBeFalse('Orientation should be case sensitive');

                    options.setOrientation('landscape');
                    expect(options.isValid()).toBeTrue();

                    options.setPageSize('a4');
                    expect(options.isValid()).toBeFalse('Page size should be case sensitive');

                    options.setPageSize('A4');
                    expect(options.isValid()).toBeTrue();
                });
            });

            describe('Header and Footer Placeholders', function() {
                it('should accept page number placeholders in headers', function() {
                    var options = new pdfgenerator.models.PDFOptions().setHeader('Document - Page {currentpage} of {totalpages}');

                    expect(options.getHeader()).toInclude('{currentpage}');
                    expect(options.getHeader()).toInclude('{totalpages}');
                    expect(options.isValid()).toBeTrue();
                });

                it('should accept page number placeholders in footers', function() {
                    var options = new pdfgenerator.models.PDFOptions().setFooter('Page {currentpage} | Total: {totalpages}');

                    expect(options.getFooter()).toInclude('{currentpage}');
                    expect(options.getFooter()).toInclude('{totalpages}');
                    expect(options.isValid()).toBeTrue();
                });

                it('should accept headers and footers without placeholders', function() {
                    var options = new pdfgenerator.models.PDFOptions()
                        .setHeader('Static Header')
                        .setFooter('Static Footer');

                    expect(options.getHeader()).toBe('Static Header');
                    expect(options.getFooter()).toBe('Static Footer');
                    expect(options.isValid()).toBeTrue();
                });
            });
        });
    }

}
