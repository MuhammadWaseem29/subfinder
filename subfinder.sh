#!/bin/bash

# Usage: ./subfinder.sh -d domain.com [-o output.txt]
# Usage: ./subfinder.sh -dL domains.txt [-o output.txt]

OUTPUT_FILE="subs.txt"
TEMP_DIR="temp_subs_$$"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            DOMAIN="$2"
            shift 2
            ;;
        -dL)
            DOMAIN_FILE="$2"
            shift 2
            ;;
        -o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Usage:"
            echo "$0 -d <domain> [-o output_file]"
            echo "$0 -dL <file> [-o output_file]"
            exit 1
            ;;
    esac
done

# Create temp directory
mkdir -p "$TEMP_DIR"

if [ -n "$DOMAIN" ]; then
    echo "Running subfinder for domain: $DOMAIN"
    subfinder -d "$DOMAIN" -silent > "$TEMP_DIR/subfinder.txt" 2>/dev/null
    echo ""
    echo "Running subdominator for domain: $DOMAIN"
    subdominator -d "$DOMAIN" > "$TEMP_DIR/subdominator.txt" 2>/dev/null
    echo ""
    echo "Running amass for domain: $DOMAIN"
    amass enum -passive -d "$DOMAIN" > "$TEMP_DIR/amass.txt" 2>/dev/null
    echo ""
    echo "Running assetfinder for domain: $DOMAIN"
    assetfinder --subs-only "$DOMAIN" > "$TEMP_DIR/assetfinder.txt" 2>/dev/null
    echo ""
    echo "Running findomain for domain: $DOMAIN"
    findomain -t "$DOMAIN" > "$TEMP_DIR/findomain.txt" 2>/dev/null
    echo ""
    echo "Running sublist3r for domain: $DOMAIN"
    sublist3r -d "$DOMAIN" -o "$TEMP_DIR/sublist3r.txt" > /dev/null 2>&1
    
elif [ -n "$DOMAIN_FILE" ]; then
    echo "Running subfinder for domain list: $DOMAIN_FILE"
    subfinder -dL "$DOMAIN_FILE" -silent > "$TEMP_DIR/subfinder.txt" 2>/dev/null
    echo ""
    echo "Running subdominator for domain list: $DOMAIN_FILE"
    subdominator -dL "$DOMAIN_FILE" > "$TEMP_DIR/subdominator.txt" 2>/dev/null
    echo ""
    echo "Running amass for domain list: $DOMAIN_FILE"
    while read -r domain; do
        [ -n "$domain" ] && amass enum -passive -d "$domain" >> "$TEMP_DIR/amass.txt" 2>/dev/null
    done < "$DOMAIN_FILE"
    echo ""
    echo "Running assetfinder for domain list: $DOMAIN_FILE"
    while read -r domain; do
        [ -n "$domain" ] && assetfinder --subs-only "$domain" >> "$TEMP_DIR/assetfinder.txt" 2>/dev/null
    done < "$DOMAIN_FILE"
    echo ""
    echo "Running findomain for domain list: $DOMAIN_FILE"
    findomain -f "$DOMAIN_FILE" > "$TEMP_DIR/findomain.txt" 2>/dev/null
    echo ""
    echo "Running sublist3r for domain list: $DOMAIN_FILE"
    while read -r domain; do
        [ -n "$domain" ] && sublist3r -d "$domain" -o "$TEMP_DIR/sublist3r_$domain.txt" > /dev/null 2>&1
    done < "$DOMAIN_FILE"
    
else
    echo "Usage:"
    echo "$0 -d <domain> [-o output_file]"
    echo "$0 -dL <file> [-o output_file]"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Merge all results, remove duplicates and sort
echo "Merging results and removing duplicates..."
cat "$TEMP_DIR"/*.txt 2>/dev/null | grep -v '^$' | sort -u > "$OUTPUT_FILE"

# Clean up temporary files
rm -rf "$TEMP_DIR"

# Count results
total_subs=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")
echo "Total unique subdomains found: $total_subs"
echo "All subdomains saved to: $OUTPUT_FILE"