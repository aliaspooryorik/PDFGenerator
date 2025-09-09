#!/bin/bash

# OpenPDF JAR Download Script
# 
# Downloads the required OpenPDF library JAR files for the PDFGenerator module.
# These JARs provide HTML to PDF conversion capabilities using the OpenPDF library.
#
# Usage: ./download-openpdf-jars.sh
#
# Author: John Whish
# Version: v0.1.0

set -e  # Exit on any error

# Configuration
OPENPDF_VERSION="3.0.0"
LIB_DIR="$(cd "$(dirname "$0")/../lib" && pwd)"
TEMP_DIR="/tmp/openpdf-download"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# URLs for JAR files
OPENPDF_BASE_URL="https://repo1.maven.org/maven2/com/github/librepdf"
JARS=(
    "openpdf:${OPENPDF_VERSION}:openpdf-${OPENPDF_VERSION}.jar"
    "openpdf-html:${OPENPDF_VERSION}:openpdf-html-${OPENPDF_VERSION}.jar"
)

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is required but not installed. Please install $1."
        exit 1
    fi
}

create_directories() {
    log_info "Creating directories..."
    
    # Create lib directory if it doesn't exist
    if [ ! -d "$LIB_DIR" ]; then
        mkdir -p "$LIB_DIR"
        log_info "Created lib directory: $LIB_DIR"
    fi
    
    # Create temp directory
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    mkdir -p "$TEMP_DIR"
    log_info "Created temp directory: $TEMP_DIR"
}

download_jar() {
    local artifact="$1"
    local version="$2"
    local filename="$3"
    
    local url="${OPENPDF_BASE_URL}/${artifact}/${version}/${filename}"
    local temp_file="${TEMP_DIR}/${filename}"
    local target_file="${LIB_DIR}/${filename}"
    
    log_info "Downloading $filename..."
    
    if curl -L -o "$temp_file" "$url"; then
        # Verify the download
        if [ -s "$temp_file" ]; then
            mv "$temp_file" "$target_file"
            log_success "Downloaded: $filename"
            
            # Show file size
            local size=$(du -h "$target_file" | cut -f1)
            log_info "File size: $size"
        else
            log_error "Downloaded file is empty: $filename"
            return 1
        fi
    else
        log_error "Failed to download: $url"
        return 1
    fi
}

verify_jars() {
    log_info "Verifying downloaded JARs..."
    
    for jar_info in "${JARS[@]}"; do
        IFS=':' read -r artifact version filename <<< "$jar_info"
        local jar_path="${LIB_DIR}/${filename}"
        
        if [ -f "$jar_path" ]; then
            # Check if it's a valid ZIP/JAR file
            if file "$jar_path" | grep -q "Zip archive\|Java archive"; then
                log_success "Valid JAR: $filename"
            else
                log_error "Invalid JAR file: $filename"
                return 1
            fi
        else
            log_error "Missing JAR file: $filename"
            return 1
        fi
    done
}

generate_classpath() {
    log_info "Generating classpath configuration..."
    
    local classpath_file="${LIB_DIR}/classpath.txt"
    
    cat > "$classpath_file" << EOF
# OpenPDF Classpath Configuration
# Generated: $(date)
# Version: ${OPENPDF_VERSION}

# Add these paths to your BoxLang/CFML application classpath:
EOF
    
    for jar_info in "${JARS[@]}"; do
        IFS=':' read -r artifact version filename <<< "$jar_info"
        echo "${LIB_DIR}/${filename}" >> "$classpath_file"
    done
    
    log_success "Created classpath configuration: $classpath_file"
}

create_installation_guide() {
    log_info "Creating installation guide..."
    
    local guide_file="${LIB_DIR}/INSTALLATION.md"
    
    cat > "$guide_file" << 'EOF'
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
EOF

    log_success "Created installation guide: $guide_file"
}

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  OpenPDF JAR Downloader                     ║"
    echo "║                     Version ${OPENPDF_VERSION}                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check prerequisites
    log_info "Checking prerequisites..."
    check_command "curl"
    check_command "file"
    
    # Create directories
    create_directories
    
    # Download JARs
    log_info "Downloading OpenPDF JAR files..."
    local download_failed=false
    
    for jar_info in "${JARS[@]}"; do
        IFS=':' read -r artifact version filename <<< "$jar_info"
        
        if ! download_jar "$artifact" "$version" "$filename"; then
            download_failed=true
        fi
    done
    
    if [ "$download_failed" = true ]; then
        log_error "Some downloads failed. Please check the errors above."
        exit 1
    fi
    
    # Verify downloads
    verify_jars
    
    # Generate additional files
    generate_classpath
    create_installation_guide
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Success summary
    echo ""
    log_success "OpenPDF JAR download completed successfully!"
    echo ""
    echo -e "${GREEN}Downloaded files:${NC}"
    for jar_info in "${JARS[@]}"; do
        IFS=':' read -r artifact version filename <<< "$jar_info"
        echo "  ✓ $filename"
    done
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Review the installation guide: ${LIB_DIR}/INSTALLATION.md"
    echo "  2. Add JARs to your application classpath"
    echo "  3. Restart your BoxLang/CFML application"
    echo "  4. Test the PDFGenerator module health check"
    echo ""
    log_info "Installation guide and classpath configuration created in: $LIB_DIR"
}

# Run main function
main "$@"
