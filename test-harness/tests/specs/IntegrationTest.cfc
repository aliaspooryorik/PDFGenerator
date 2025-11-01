component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    this.unLoadColdBox = false;

    /*********************************** LIFE CYCLE Methods ***********************************/

    function beforeAll() {
        super.beforeAll();
    }

    function afterAll() {
        super.afterAll();
    }

    /*********************************** BDD SUITES ***********************************/

    function run() {
        describe('PDFGenerator Integration Tests', function() {
            beforeEach(function(currentSpec) {
                // Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
                setup();
            });

            story('PDF Generation via Handler', function() {
                given('a request for basic PDF generation', function() {
                    then('it should generate a PDF successfully', function() {
                        var event = this.request(route = '/main/testBasicConversion', method = 'GET');

                        // Should not throw an error
                        expect(event).notToBeNull();
                    });
                });

                given('a request for advanced PDF generation', function() {
                    then('it should generate a PDF with custom options', function() {
                        var event = this.request(route = '/main/testAdvancedConversion', method = 'GET');

                        // Should not throw an error
                        expect(event).notToBeNull();
                    });
                });
            });

            story('Health Check via Handler', function() {
                given('a request for health check', function() {
                    then('it should return health status', function() {
                        var event = this.request(route = '/main/testHealthCheck', method = 'GET');

                        // Should not throw an error and should set healthResult
                        expect(event).notToBeNull();
                        var prc = event.getCollection(private = true);
                        expect(prc).toHaveKey('healthResult');
                    });
                });
            });
        });
    }

}
