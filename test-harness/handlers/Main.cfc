/**
 * My Main Handler for PDFGenerator Test Harness
 */
component {

    property name="PDFGeneratorService" inject="PDFGeneratorService@PDFGenerator";

    // Index
    any function index(event, rc, prc) {
        prc.welcomeMessage = 'Welcome to the PDFGenerator Test Harness!';
        // Get loaded modules from ColdBox
        prc.loadedModules = [];
        try {
            var modules = controller.getModuleService().getLoadedModules();
            for (var moduleName in modules) {
                prc.loadedModules.append(moduleName);
            }
        } catch (any e) {
            prc.loadedModules = ['Error retrieving modules: ' & e.message];
        }
        event.setView('main/index');
    }

    /**
     * Test HTML to PDF conversion with basic options
     */
    function testBasicConversion(event, rc, prc) {
        var html = '<html><body><h1>Test PDF</h1><p>Generated #dateTimeFormat(now(), 'iso')#</p></body></html>';
        var result = PDFGeneratorService.htmlToPDFResult(html);

        if (result.getSuccess()) {
            event.setHTTPHeader(name = 'Content-Type', value = 'application/pdf');
            event.setHTTPHeader(name = 'Content-Disposition', value = 'attachment; filename=test-#getTickCount()#.pdf');

            event.renderData(
                data = toBinary(result.getBase64String()),
                type = 'pdf'
            );
        } else {
            prc.error = result.getError();
            event.setView('main/error');
        }
    }

    /**
     * Test HTML to PDF conversion with custom options
     */
    function testAdvancedConversion(event, rc, prc) {
		var pdfOptions = getInstance('PDFOptions@PDFGenerator')
			.setOrientation('landscape')
			.setPageSize('A5')
			.setMargins(20, 20, 20, 20);

		var html = '<html><head><style>@page { size: A5 landscape; } body { margin: 10mm 50mm; }</style></head><body><h1>Advanced Test PDF</h1><p>This is a landscape A5 PDF with custom margins.</p><p>Generated #dateTimeFormat(now(), 'iso')#</p></body></html>';
		var result = PDFGeneratorService.htmlToPDFResult(html, pdfOptions);

        if (result.getSuccess()) {
            event.setHTTPHeader(name = 'Content-Type', value = 'application/pdf');
            event.setHTTPHeader(name = 'Content-Disposition', value = 'attachment; filename=test-#getTickCount()#.pdf');

            event.renderData(
                data = toBinary(result.getBase64String()),
                type = 'pdf'
            );
        } else {
            prc.error = result.getError();
            event.setView('main/error');
        }
    }

    /**
     * Test service health check
     */
    function testHealthCheck(event, rc, prc) {
        var healthResult = {};
        var pdfGenerator = getInstance('PDFGeneratorService@PDFGenerator');
        prc.healthResult = pdfGenerator.healthCheck();
        event.setView('main/health');
    }

    // Run on first init
    any function onAppInit(event, rc, prc) {
    }

}
