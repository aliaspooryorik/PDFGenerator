# Security Policy

## Supported Versions

We actively support the following versions of PDFGenerator with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in PDFGenerator, please report it responsibly.

### How to Report

1. **Email**: Send details to john@aliaspooryorik.com
2. **Subject**: Include "SECURITY" in the subject line
3. **Details**: Provide as much information as possible about the vulnerability

### What to Include

Please include the following information in your report:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** and attack scenarios
- **Suggested fix** if you have one
- **Your contact information** for follow-up

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt within 24 hours
- **Initial Assessment**: We'll provide an initial assessment within 72 hours
- **Updates**: We'll keep you informed of our progress
- **Resolution**: We aim to resolve critical vulnerabilities within 7 days
- **Credit**: We'll credit you in the security advisory (if desired)

### Please Do Not

- **Disclose publicly** until we've had a chance to address the issue
- **Access or modify** data that doesn't belong to you
- **Perform destructive testing** or denial of service attacks
- **Social engineer** our team members or users

## Security Considerations

### OpenPDF Library

PDFGenerator uses the OpenPDF library for PDF generation. Security considerations include:

- **Input Validation**: All HTML input is processed through OpenPDF's HTML parser
- **File System Access**: PDF output files are written with restricted permissions
- **Memory Management**: Large documents are processed with memory optimization
- **Resource Cleanup**: Proper disposal of temporary resources and streams

### Common Security Best Practices

When using PDFGenerator in your applications:

1. **Validate Input**: Always validate and sanitize HTML input before PDF generation
2. **Access Control**: Implement proper authentication/authorization for PDF endpoints
3. **Rate Limiting**: Consider rate limiting for PDF generation endpoints
4. **File Permissions**: Ensure generated PDF files have appropriate access permissions
5. **Temporary Files**: Monitor and clean up temporary files in production
6. **Error Handling**: Avoid exposing sensitive information in error messages
7. **Logging**: Log PDF generation activities for audit purposes

### Dependencies

We regularly monitor our dependencies for security vulnerabilities:

- **OpenPDF**: Core PDF generation library
- **OpenPDF HTML**: HTML to PDF conversion support

### Updates

- Security updates will be released as patch versions (e.g., 0.1.1)
- Critical security fixes may result in immediate releases
- Security advisories will be published on GitHub

## Questions?

If you have questions about this security policy, please contact john@aliaspooryorik.com.
