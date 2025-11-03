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

	any function playground(event, rc, prc) {
		event.paramValue("template", "health");
		prc.templates = 
			{ 
				"basic": fileRead("../views/main/templates/basic.html"),
				"advanced": fileRead("../views/main/templates/advanced.html"),
				"health": fileRead("../views/main/templates/health.html")
			}
		event.setView('main/playground');
	}

    /**
     * Test HTML to PDF conversion with basic options
     */
    function generatePDF(event, rc, prc) {
        if ( !structKeyExists(rc, "html")) {
			event.redirect( "main.playground" );
		}

        var result = PDFGeneratorService.htmlToPDFResult(rc.html);

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

}
