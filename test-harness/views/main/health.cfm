<cfoutput>
<div class="row">
    <div class="col-md-12">
        <h1>Health Check Results</h1>
        
        <cfif structKeyExists(prc, "healthResult")>
            <div class="alert alert-#prc.healthResult.success ? 'success' : 'danger'#">
                <h4>Service Status: #prc.healthResult.success ? 'Healthy' : 'Unhealthy'#</h4>
                <p><strong>Message:</strong> #prc.healthResult.message#</p>
                
                <cfif structKeyExists(prc.healthResult, "details") and isStruct(prc.healthResult.details)>
                    <h5>Details:</h5>
                    <ul>
                        <cfloop collection="#prc.healthResult.details#" item="key">
                            <li><strong>#key#:</strong> #prc.healthResult.details[key]#</li>
                        </cfloop>
                    </ul>
                </cfif>
            </div>
        <cfelse>
            <div class="alert alert-warning">
                <p>No health check results available.</p>
            </div>
        </cfif>
        
        <a href="#event.buildLink('')#" class="btn btn-primary">Back to Home</a>
    </div>
</div>
</cfoutput>
