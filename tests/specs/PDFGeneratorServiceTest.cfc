/**
 * Test Suite for PDFGeneratorService
 * 
 * Comprehensive tests for HTML to PDF conversion functionality.
 * Tests both binary and file generation with various configurations.
 * 
 * @author John Whish
 * @version v0.1.0
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        // Setup test environment
        variables.pdfGenerator = new pdfgenerator.services.PDFGeneratorService();
        variables.testOutputDir = getTempDirectory() & "/pdfgenerator-tests";
        
        // Create test output directory
        if ( !directoryExists( variables.testOutputDir ) ) {
            directoryCreate( variables.testOutputDir, true );
        }
    }

    function afterAll() {
        // Clean up test files
        if ( directoryExists( variables.testOutputDir ) ) {
            directoryDelete( variables.testOutputDir, true );
        }
    }

    function run() {
        describe( "PDFGeneratorService", function() {
            
            describe( "Service Initialization", function() {
                
                it( "should initialize successfully", function() {
                    expect( variables.pdfGenerator ).toBeComponent();
                    expect( variables.pdfGenerator ).toHaveKey( "htmlToPDFBinary" );
                    expect( variables.pdfGenerator ).toHaveKey( "htmlToPDFFile" );
                    expect( variables.pdfGenerator ).toHaveKey( "isHealthy" );
                });
                
                it( "should pass health check", function() {
                    var isHealthy = variables.pdfGenerator.isHealthy();
                    expect( isHealthy ).toBeTrue( "PDFGenerator service should be healthy" );
                });
                
            });

            describe( "HTML to PDF Binary Conversion", function() {
                
                it( "should convert simple HTML to PDF binary", function() {
                    var html = "<html><body><h1>Test Document</h1><p>Hello, World!</p></body></html>";
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    expect( result ).toBeComponent();
                    expect( result.isSuccess() ).toBeTrue();
                    expect( result.getBinaryData() ).toBeArray();
                    expect( arrayLen( result.getBinaryData() ) ).toBeGT( 0 );
                    expect( result.getFileSize() ).toBeGT( 0 );
                    expect( result.getGenerationTime() ).toBeGTE( 0 );
                });
                
                it( "should handle complex HTML with CSS", function() {
                    var html = "
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <style>
                                body { font-family: Arial; margin: 20px; }
                                h1 { color: blue; }
                                table { border-collapse: collapse; width: 100%; }
                                th, td { border: 1px solid black; padding: 8px; }
                            </style>
                        </head>
                        <body>
                            <h1>Complex Document</h1>
                            <table>
                                <tr><th>Name</th><th>Value</th></tr>
                                <tr><td>Test</td><td>123</td></tr>
                            </table>
                        </body>
                        </html>
                    ";
                    
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    expect( result.isSuccess() ).toBeTrue();
                    expect( result.getFileSize() ).toBeGT( 1000, "Complex HTML should generate larger PDF" );
                });
                
                it( "should handle UTF-8 characters", function() {
                    var html = "<html><body><h1>UTF-8 Test</h1><p>Special chars: àáâãäåæçèéêë ñüö €£¥</p></body></html>";
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    expect( result.isSuccess() ).toBeTrue();
                    expect( result.getFileSize() ).toBeGT( 0 );
                });
                
                it( "should handle large HTML documents", function() {
                    // Generate a large HTML document
                    var html = "<html><body><h1>Large Document Test</h1>";
                    for ( var i = 1; i <= 100; i++ ) {
                        html &= "<p>Paragraph #i# - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>";
                    }
                    html &= "</body></html>";
                    
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    expect( result.isSuccess() ).toBeTrue();
                    expect( result.getFileSize() ).toBeGT( 10000, "Large document should generate substantial PDF" );
                    expect( result.getGenerationTime() ).toBeGT( 0 );
                });
                
                it( "should handle empty HTML gracefully", function() {
                    var html = "";
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    // Should either succeed with minimal PDF or fail gracefully
                    if ( result.isSuccess() ) {
                        expect( result.getFileSize() ).toBeGTE( 0 );
                    } else {
                        expect( result.getErrorMessage() ).toInclude( "HTML" );
                    }
                });
                
                it( "should handle malformed HTML", function() {
                    var html = "<html><body><h1>Malformed HTML<p>Missing closing tags";
                    var result = variables.pdfGenerator.htmlToPDFBinary( html );
                    
                    // Should either succeed by auto-correcting or fail gracefully
                    expect( result ).toBeComponent();
                    if ( !result.isSuccess() ) {
                        expect( result.getErrorMessage() ).toBeString();
                    }
                });
                
            });

            describe( "HTML to PDF File Generation", function() {
                
                it( "should convert HTML to PDF file", function() {
                    var html = "<html><body><h1>File Test</h1><p>Testing file generation</p></body></html>";
                    var result = variables.pdfGenerator.htmlToPDFFile( html );
                    
                    expect( result.isSuccess() ).toBeTrue();
                    expect( result.getFilePath() ).toBeString();
                    expect( fileExists( result.getFilePath() ) ).toBeTrue();
                    expect( result.getFileSize() ).toBeGT( 0 );
                    
                    // Clean up
                    if ( fileExists( result.getFilePath() ) ) {
                        fileDelete( result.getFilePath() );
                    }
                });
                
                it( "should create file with valid PDF structure", function() {
                    var html = "<html><body><h1>PDF Structure Test</h1></body></html>";
                    var result = variables.pdfGenerator.htmlToPDFFile( html );
                    
                    expect( result.isSuccess() ).toBeTrue();
                    
                    // Check file starts with PDF header
                    var fileContent = fileReadBinary( result.getFilePath() );
                    var header = binaryEncode( arraySlice( fileContent, 1, 4 ), "base64" );
                    var headerString = binaryDecode( header, "base64" );
                    
                    expect( left( toString( headerString ), 4 ) ).toBe( "%PDF" );
                    
                    // Clean up
                    fileDelete( result.getFilePath() );
                });
                
            });

            describe( "PDF Options Configuration", function() {
                
                it( "should respect orientation settings", function() {
                    var html = "<html><body><h1>Orientation Test</h1></body></html>";
                    
                    // Test portrait
                    var portraitOptions = new pdfgenerator.models.PDFOptions()
                                           .setOrientation( "portrait" )
                                           .setPageSize( "A4" );
                    var portraitResult = variables.pdfGenerator.htmlToPDFBinary( html, portraitOptions );
                    
                    // Test landscape  
                    var landscapeOptions = new pdfgenerator.models.PDFOptions()
                                            .setOrientation( "landscape" )
                                            .setPageSize( "A4" );
                    var landscapeResult = variables.pdfGenerator.htmlToPDFBinary( html, landscapeOptions );
                    
                    expect( portraitResult.isSuccess() ).toBeTrue();
                    expect( landscapeResult.isSuccess() ).toBeTrue();
                    
                    // Files should be different sizes due to orientation
                    expect( portraitResult.getFileSize() ).toNotBe( landscapeResult.getFileSize() );
                });
                
                it( "should respect page size settings", function() {
                    var html = "<html><body><h1>Page Size Test</h1></body></html>";
                    
                    // Test A4
                    var a4Options = new pdfgenerator.models.PDFOptions().setPageSize( "A4" );
                    var a4Result = variables.pdfGenerator.htmlToPDFBinary( html, a4Options );
                    
                    // Test A3
                    var a3Options = new pdfgenerator.models.PDFOptions().setPageSize( "A3" );
                    var a3Result = variables.pdfGenerator.htmlToPDFBinary( html, a3Options );
                    
                    expect( a4Result.isSuccess() ).toBeTrue();
                    expect( a3Result.isSuccess() ).toBeTrue();
                    
                    // A3 should typically result in different file size than A4
                    expect( a4Result.getFileSize() ).toNotBe( a3Result.getFileSize() );
                });
                
                it( "should respect margin settings", function() {
                    var html = "<html><body><h1>Margin Test</h1><p>Testing margin configuration</p></body></html>";
                    
                    // Test small margins
                    var smallMarginsOptions = new pdfgenerator.models.PDFOptions()
                                               .setMargins( 10, 10, 10, 10, "mm" );
                    var smallResult = variables.pdfGenerator.htmlToPDFBinary( html, smallMarginsOptions );
                    
                    // Test large margins
                    var largeMarginsOptions = new pdfgenerator.models.PDFOptions()
                                               .setMargins( 50, 50, 50, 50, "mm" );
                    var largeResult = variables.pdfGenerator.htmlToPDFBinary( html, largeMarginsOptions );
                    
                    expect( smallResult.isSuccess() ).toBeTrue();
                    expect( largeResult.isSuccess() ).toBeTrue();
                    
                    // Different margins should result in different layouts/sizes
                    expect( smallResult.getFileSize() ).toNotBe( largeResult.getFileSize() );
                });
                
            });

            describe( "Error Handling", function() {
                
                it( "should handle invalid PDF options gracefully", function() {
                    var html = "<html><body><h1>Error Test</h1></body></html>";
                    var invalidOptions = new pdfgenerator.models.PDFOptions()
                                           .setOrientation( "invalid" );
                    
                    var result = variables.pdfGenerator.htmlToPDFBinary( html, invalidOptions );
                    
                    expect( result.isSuccess() ).toBeFalse();
                    expect( result.getErrorMessage() ).toInclude( "Invalid" );
                });
                
                it( "should handle null HTML input", function() {
                    expectToThrow( function() {
                        variables.pdfGenerator.htmlToPDFBinary( javaCast( "null", "" ) );
                    });
                });
                
                it( "should provide detailed error information", function() {
                    var invalidOptions = new pdfgenerator.models.PDFOptions()
                                           .setPageSize( "InvalidSize" );
                    var result = variables.pdfGenerator.htmlToPDFBinary( "<html></html>", invalidOptions );
                    
                    if ( !result.isSuccess() ) {
                        expect( result.getErrorMessage() ).toBeString();
                        expect( len( result.getErrorMessage() ) ).toBeGT( 0 );
                        expect( result.getErrorDetail() ).toBeString();
                    }
                });
                
            });

            describe( "Performance and Memory", function() {
                
                it( "should handle multiple consecutive conversions", function() {
                    var html = "<html><body><h1>Performance Test</h1><p>Testing multiple conversions</p></body></html>";
                    var results = [];
                    
                    // Perform 5 conversions
                    for ( var i = 1; i <= 5; i++ ) {
                        var result = variables.pdfGenerator.htmlToPDFBinary( html );
                        arrayAppend( results, result );
                        
                        expect( result.isSuccess() ).toBeTrue();
                        expect( result.getGenerationTime() ).toBeGTE( 0 );
                    }
                    
                    // All conversions should succeed
                    expect( arrayLen( results ) ).toBe( 5 );
                    
                    // Check that generation times are reasonable (< 10 seconds each)
                    for ( var result in results ) {
                        expect( result.getGenerationTime() ).toBeLT( 10000 );
                    }
                });
                
                it( "should clean up resources properly", function() {
                    var html = "<html><body><h1>Resource Test</h1></body></html>";
                    
                    // Multiple conversions should not cause memory leaks
                    // This is a basic test - more sophisticated memory testing would require JVM monitoring
                    for ( var i = 1; i <= 10; i++ ) {
                        var result = variables.pdfGenerator.htmlToPDFBinary( html );
                        expect( result.isSuccess() ).toBeTrue();
                    }
                    
                    // Service should still be healthy after multiple operations
                    expect( variables.pdfGenerator.isHealthy() ).toBeTrue();
                });
                
            });
            
        });
    }

}
