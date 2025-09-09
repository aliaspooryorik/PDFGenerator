# OpenPDF Installation Guide

## Downloaded JARs

The following OpenPDF library JARs have been downloaded:

- `openpdf-3.0.0.jar` - Core OpenPDF library
- `openpdf-html-3.0.0.jar` - HTML to PDF conversion support

## Installation Options

### Option 1: BoxLang Application Classpath

Add the JAR files to your BoxLang application's classpath by copying them to:
```
{boxlang-installation}/lib/
```

### Option 2: Application-Specific Classpath

For application-specific installation, add the JARs to your application's lib directory and configure the classpath in your Application.cfc:

```cfml
this.javaSettings = {
    loadPaths: [
        expandPath("./lib/openpdf-3.0.0.jar"),
        expandPath("./lib/openpdf-html-3.0.0.jar")
    ]
};
```

### Option 3: CommandBox Installation

If using CommandBox, you can place the JARs in your server's lib directory:
```bash
cp *.jar {server-home}/lib/
```

## Verification

To verify the installation is working, use the PDFGenerator module's health check endpoint:
```
GET /pdfgenerator/health
```

Or run the test endpoint:
```
GET /pdfgenerator/test
```

## Troubleshooting

1. **ClassNotFoundException**: Ensure JARs are in the classpath and restart your application
2. **NoClassDefFoundError**: Check that both JAR files are present
3. **Permission Issues**: Ensure the application has read access to the JAR files

## Support

For issues with the PDFGenerator module, check the module documentation or logs.
For OpenPDF library issues, visit: https://github.com/LibrePDF/OpenPDF
