
<cfoutput>
<h2>PDF Playground</h2>
<p>More examples at: <a href="https://sandbox.openhtmltopdf.com/">https://sandbox.openhtmltopdf.com/</a></p>
<form action="#event.buildLink('Main.generatePDF')#" method="post">
	<label for="template">Choose a template:</label>
	<select id="template" name="template">
		<option value="basic" <cfif rc.template eq "basic">selected</cfif>>Basic</option>
		<option value="advanced" <cfif rc.template eq "advanced">selected</cfif>>Advanced</option>
		<option value="health" <cfif rc.template eq "health">selected</cfif>>Health Check</option>
	</select>
	<br><br>
	<label for="html">XHTML:</label><br>
	<textarea name="html" id="html" rows="15" cols="80"></textarea><br>
	<input type="submit" value="Generate PDF">
</form>
<script>
const templates = #serializeJSON(prc.templates)#;

function setTemplate() {
	const selected = document.getElementById('template').value;
	document.getElementById('html').value = templates[selected];
}

document.getElementById('template').addEventListener('change', setTemplate);
window.addEventListener('DOMContentLoaded', setTemplate);
</script>
</cfoutput>