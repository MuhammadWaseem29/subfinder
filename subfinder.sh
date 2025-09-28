#!/bin/bash

# Usage: ./subfinder.sh -d domain.com OR ./subfinder.sh -dL domains.txt

OUTPUT_FILE="all_subdomains.txt"

if [ "$1" = "-d" ] && [ -n "$2" ]; then
    echo "Running subfinder for domain: $2"
    subfinder -d "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running subdominator for domain: $2"
    subdominator -d "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running amass for domain: $2"
    amass enum -passive -d "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running assetfinder for domain: $2"
    assetfinder --subs-only "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running findomain for domain: $2"
    findomain -t "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running sublist3r for domain: $2"
    sublist3r -d "$2" >> "$OUTPUT_FILE"
    
elif [ "$1" = "-dL" ] && [ -n "$2" ]; then
    echo "Running subfinder for domain list: $2"
    subfinder -dL "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running subdominator for domain list: $2"
    subdominator -dL "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running amass for domain list: $2"
    while read -r domain; do
        [ -n "$domain" ] && amass enum -passive -d "$domain" >> "$OUTPUT_FILE"
    done < "$2"
    echo ""
    echo "Running assetfinder for domain list: $2"
    while read -r domain; do
        [ -n "$domain" ] && assetfinder --subs-only "$domain" >> "$OUTPUT_FILE"
    done < "$2"
    echo ""
    echo "Running findomain for domain list: $2"
    findomain -f "$2" >> "$OUTPUT_FILE"
    echo ""
    echo "Running sublist3r for domain list: $2"
    while read -r domain; do
        [ -n "$domain" ] && sublist3r -d "$domain" >> "$OUTPUT_FILE"
    done < "$2"
    
else
    echo "Usage:"
    echo "$0 -d <domain>       # Single domain"
    echo "$0 -dL <file>        # Domain list file"
    exit 1
fi

# Remove duplicates and sort
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
echo "All subdomains saved to: $OUTPUT_FILE"