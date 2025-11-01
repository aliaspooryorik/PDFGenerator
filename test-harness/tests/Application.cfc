/**
 * Copyright 2025 PDFGenerator Test Harness
 * ---
 */
component {

    // UPDATE THE NAME OF THE MODULE IN TESTING BELOW
    request.MODULE_NAME = 'PDFGenerator';
    request.MODULE_PATH = 'PDFGenerator';

    // APPLICATION CFC PROPERTIES
    this.name = 'PDFGeneratorTestSuite';
    this.sessionManagement = true;
    this.setClientCookies = true;
    this.sessionTimeout = createTimespan(0, 0, 15, 0);
    this.applicationTimeout = createTimespan(0, 0, 15, 0);
    // Turn on/off white space management
    this.whiteSpaceManagement = 'smart';

    // Create testing mapping
    this.mappings['/tests'] = getDirectoryFromPath(getCurrentTemplatePath());

    // The application root
    rootPath = reReplaceNoCase(this.mappings['/tests'], 'tests(\\|/)', '');
    this.mappings['/root'] = rootPath;

    // The module root path
    moduleRootPath = reReplaceNoCase(this.mappings['/root'], '#request.module_name#(\\|/)test-harness(\\|/)', '');
    this.mappings['/moduleroot'] = moduleRootPath;
    this.mappings['/#request.MODULE_NAME#'] = moduleRootPath & '#request.MODULE_PATH#';

    // request start
    public boolean function onRequestStart(String targetPage) {
        // Set a high timeout for long running tests
        setting requestTimeout="9999";
        // New ColdBox Virtual Application Starter
        request.coldBoxVirtualApp = new coldbox.system.testing.VirtualApp(appMapping = '/root');

        // If hitting the runner or specs, prep our virtual app
        if (getBaseTemplatePath().replace(expandPath('/tests'), '').reFindNoCase('(runner|specs)')) {
            request.coldBoxVirtualApp.startup();
        }

        // ORM Reload for fresh results
        if (structKeyExists(url, 'fwreinit')) {
            if (structKeyExists(server, 'lucee')) {
                pagePoolClear();
            }
            request.coldBoxVirtualApp.restart();
        }

        return true;
    }

    public void function onRequestEnd(required targetPage) {
        request.coldBoxVirtualApp.shutdown();
    }

}
