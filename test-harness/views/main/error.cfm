<cfoutput>
<div class="row">
    <div class="col-md-12">
        <h1>Error</h1>
        <div class="alert alert-danger">
            <h4>An error occurred:</h4>
            <cfif structKeyExists(prc, "error") and isStruct(prc.error)>
                <p><strong>Message:</strong> #prc.error.message#</p>
                <cfif structKeyExists(prc.error, "detail") and len(prc.error.detail)>
                    <p><strong>Detail:</strong> #prc.error.detail#</p>
                </cfif>
                <cfif structKeyExists(prc.error, "stackTrace") and len(prc.error.stackTrace)>
                    <details>
                        <summary>Stack Trace</summary>
                        <pre>#prc.error.stackTrace#</pre>
                    </details>
                </cfif>
            <cfelseif structKeyExists(prc, "error")>
                <p>#prc.error#</p>
            <cfelse>
                <p>An unknown error occurred.</p>
            </cfif>
        </div>
        
        <a href="#event.buildLink('')#" class="btn btn-primary">Back to Home</a>
    </div>
</div>
</cfoutput>
