/**
 * My Main Handler for PDFGenerator Test Harness
 */
component {

	// Index
	any function index( event, rc, prc ){
		prc.welcomeMessage = "Welcome to the PDFGenerator Test Harness!";
		// Get loaded modules from ColdBox
		prc.loadedModules = [];
		try {
			var modules = controller.getModuleService().getLoadedModules();
			for ( var moduleName in modules ) {
				prc.loadedModules.append( moduleName );
			}
		} catch ( any e ) {
			prc.loadedModules = ["Error retrieving modules: " & e.message];
		}
		event.setView( "main/index" );
	}

	/**
	 * Test HTML to PDF conversion with basic options
	 */
	function testBasicConversion( event, rc, prc ){
		try {
			var pdfGenerator = getInstance( "PDFGeneratorService@PDFGenerator" );
			var html = "<html><body><h1>Test PDF</h1><p>This is a test PDF document.</p></body></html>";
			
			var result = pdfGenerator.htmlToPDFBinary( html );
			
			if ( result.getSuccess() ) {
				event.setHTTPHeader( name="Content-Type", value="application/pdf" );
				event.setHTTPHeader( name="Content-Disposition", value="attachment; filename=test.pdf" );
				event.renderData( data=result.getBinaryData(), type="binary" );
			} else {
				prc.error = result.getError();
				event.setView( "main/error" );
			}
		} catch ( any e ) {
			prc.error = e;
			event.setView( "main/error" );
		}
	}

	/**
	 * Test HTML to PDF conversion with custom options
	 */
	function testAdvancedConversion( event, rc, prc ){
		try {
			var pdfGenerator = getInstance( "PDFGeneratorService@PDFGenerator" );
			var pdfOptions = getInstance( "PDFOptions@PDFGenerator" )
				.setOrientation( "landscape" )
				.setPageSize( "A4" )
				.setMargins( 20, 20, 20, 20 );
			
			var html = "<html><body><h1>Advanced Test PDF</h1><p>This is a landscape A4 PDF with custom margins.</p></body></html>";
			
			var result = pdfGenerator.htmlToPDFBinary( html, pdfOptions );
			
			if ( result.getSuccess() ) {
				event.setHTTPHeader( name="Content-Type", value="application/pdf" );
				event.setHTTPHeader( name="Content-Disposition", value="attachment; filename=advanced-test.pdf" );
				event.renderData( data=result.getBinaryData(), type="binary" );
			} else {
				prc.error = result.getError();
				event.setView( "main/error" );
			}
		} catch ( any e ) {
			prc.error = e;
			event.setView( "main/error" );
		}
	}

	/**
	 * Test service health check
	 */
	function testHealthCheck( event, rc, prc ){
		var healthResult = {};
		try {
			var pdfGenerator = getInstance( "PDFGeneratorService@PDFGenerator" );
			healthResult = pdfGenerator.healthCheck();
		} catch ( any e ) {
			healthResult = { success: false, message: "Exception: " & e.message };
		}
		prc.healthResult = healthResult;
		event.setView( "main/health" );
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}
