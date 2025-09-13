<cfoutput>
<div class="row">
    <div class="col-md-12">
        <h1>PDFGenerator Test Harness</h1>
        <p class="lead">#prc.welcomeMessage#</p>
        <div class="card mb-3">
            <div class="card-body">
                <h5 class="card-title">Loaded Modules</h5>
                <ul>
                    <cfloop array="#prc.loadedModules#" index="moduleName">
                        <li>#moduleName#</li>
                    </cfloop>
                </ul>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Basic PDF Test</h5>
                        <p class="card-text">Test basic HTML to PDF conversion with default settings.</p>
                        <a href="#event.buildLink('main.testBasicConversion')#" class="btn btn-primary">Test Basic Conversion</a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Advanced PDF Test</h5>
                        <p class="card-text">Test HTML to PDF conversion with custom options (landscape, margins).</p>
                        <a href="#event.buildLink('main.testAdvancedConversion')#" class="btn btn-success">Test Advanced Conversion</a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Health Check</h5>
                        <p class="card-text">Check if the PDF service is properly configured and working.</p>
                        <a href="#event.buildLink('main.testHealthCheck')#" class="btn btn-info">Run Health Check</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-12">
                <h3>Test APIs</h3>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">REST API Endpoints</h5>
                        <p class="card-text">You can also test the REST API endpoints directly:</p>
                        <ul>
                            <li><code>POST /api/pdf/generate</code> - Generate PDF from HTML</li>
                            <li><code>GET /api/pdf/health</code> - Health check endpoint</li>
                        </ul>
                        <p class="text-muted">Use tools like Postman or curl to test these endpoints.</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-12">
                <h3>Run Tests</h3>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Unit Tests</h5>
                        <p class="card-text">Run the complete test suite for the PDFGenerator module.</p>
                        <a href="/tests/runner.cfm" class="btn btn-warning" target="_blank">Run Unit Tests</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>
