/**
 * PDFGenerator Module Configuration
 *
 * ColdBox module for converting HTML to PDF using OpenPDF library.
 *
 * @author John Whish
 * @version v0.1.0
 */
component {

    // Module Properties
    this.title = 'PDFGenerator';
    this.author = 'John Whish';
    this.webURL = 'https://github.com/aliaspooryorik/PDFGenerator';
    this.description = 'ColdBox module for converting HTML to PDF using OpenPDF library';
    this.version = '0.1.0';
    this.cfmapping = 'pdfgenerator';
    this.autoMapModels = true;
    this.modelNamespace = 'pdfgenerator';
    this.dependencies = ['cbjavaloader'];

    /**
     * Configure the module
     */
    function configure() {
        // Module Settings
        settings = {
            // Default output directory (relative to module root)
            defaultOutputPath: expandPath('./output'),
            // Default PDF options
            defaultPDFOptions: {
                orientation: 'portrait',
                pageSize: 'A4',
                marginUnit: 'pt',
                marginTop: 20,
                marginBottom: 20,
                marginLeft: 20,
                marginRight: 20,
                embedFonts: true,
                header: '',
                footer: ''
            },
            // OpenPDF Configuration
            openPDFConfig: {
                // Font directories (OpenPDF will use system fonts by default)
                fontDirectories: [],
                // Temporary file directory
                tempDirectory: getTempDirectory(),
                // Enable debug logging for OpenPDF
                debugMode: false
            },
            // Memory monitoring
            memoryMonitoring: {enabled: false, logThresholdMB: 100}
        };
    }

    /**
     * Fired when the module is registered and activated.
     */
    function onLoad() {
        var moduleSettings = controller.getConfigSettings().modules.pdfgenerator.settings;

        // Create default output directory if it doesn't exist
        if (!directoryExists(moduleSettings.defaultOutputPath)) {
            directoryCreate(moduleSettings.defaultOutputPath, true);
        }

        // Log module startup
        if (
            controller
                .getLogBox()
                .getRootLogger()
                .canInfo()
        ) {
            controller
                .getLogBox()
                .getRootLogger()
                .info('PDFGenerator module loaded successfully. Output directory: #moduleSettings.defaultOutputPath#');
        }

        // Setup JavaLoader to load OpenPDF JARs from /lib
        controller
            .getWireBox()
            .getInstance('loader@cbjavaloader')
            .appendPaths(variables.modulePath & '/lib');
    }

    /**
     * Fired when the module is unregistered and unloaded
     */
    function onUnload() {
    }

}
