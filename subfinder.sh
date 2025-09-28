#!/bin/bash

# Usage: ./subfinder.sh -d domain.com [-o output.txt]
# Usage: ./subfinder.sh -dL domains.txt [-o output.txt]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
            echo -e "${RED}Usage:${NC}"
            echo -e "${YELLOW}$0 -d <domain> [-o output_file]${NC}"
            echo -e "${YELLOW}$0 -dL <file> [-o output_file]${NC}"
            exit 1
            ;;
    esac
done

# Create temp directory
mkdir -p "$TEMP_DIR"

if [ -n "$DOMAIN" ]; then
    echo -e "${BLUE}[1/6]${NC} Running ${GREEN}subfinder${NC} for domain: ${CYAN}$DOMAIN${NC}"
    subfinder -d "$DOMAIN" -silent > "$TEMP_DIR/subfinder.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[2/6]${NC} Running ${GREEN}subdominator${NC} for domain: ${CYAN}$DOMAIN${NC}"
    subdominator -d "$DOMAIN" > "$TEMP_DIR/subdominator.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[3/6]${NC} Running ${GREEN}amass${NC} for domain: ${CYAN}$DOMAIN${NC}"
    amass enum -passive -d "$DOMAIN" > "$TEMP_DIR/amass.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[4/6]${NC} Running ${GREEN}assetfinder${NC} for domain: ${CYAN}$DOMAIN${NC}"
    assetfinder --subs-only "$DOMAIN" > "$TEMP_DIR/assetfinder.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[5/6]${NC} Running ${GREEN}findomain${NC} for domain: ${CYAN}$DOMAIN${NC}"
    findomain -t "$DOMAIN" > "$TEMP_DIR/findomain.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[6/6]${NC} Running ${GREEN}sublist3r${NC} for domain: ${CYAN}$DOMAIN${NC}"
    sublist3r -d "$DOMAIN" -o "$TEMP_DIR/sublist3r.txt" > /dev/null 2>&1
    
elif [ -n "$DOMAIN_FILE" ]; then
    echo -e "${BLUE}[1/6]${NC} Running ${GREEN}subfinder${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    subfinder -dL "$DOMAIN_FILE" -silent > "$TEMP_DIR/subfinder.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[2/6]${NC} Running ${GREEN}subdominator${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    subdominator -dL "$DOMAIN_FILE" > "$TEMP_DIR/subdominator.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[3/6]${NC} Running ${GREEN}amass${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    while read -r domain; do
        [ -n "$domain" ] && amass enum -passive -d "$domain" >> "$TEMP_DIR/amass.txt" 2>/dev/null
    done < "$DOMAIN_FILE"
    echo ""
    echo -e "${BLUE}[4/6]${NC} Running ${GREEN}assetfinder${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    while read -r domain; do
        [ -n "$domain" ] && assetfinder --subs-only "$domain" >> "$TEMP_DIR/assetfinder.txt" 2>/dev/null
    done < "$DOMAIN_FILE"
    echo ""
    echo -e "${BLUE}[5/6]${NC} Running ${GREEN}findomain${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    findomain -f "$DOMAIN_FILE" > "$TEMP_DIR/findomain.txt" 2>/dev/null
    echo ""
    echo -e "${BLUE}[6/6]${NC} Running ${GREEN}sublist3r${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}"
    while read -r domain; do
        [ -n "$domain" ] && sublist3r -d "$domain" -o "$TEMP_DIR/sublist3r_$domain.txt" > /dev/null 2>&1
    done < "$DOMAIN_FILE"
    
else
    echo -e "${RED}Usage:${NC}"
    echo -e "${YELLOW}$0 -d <domain> [-o output_file]${NC}"
    echo -e "${YELLOW}$0 -dL <file> [-o output_file]${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Merge all results, remove duplicates and sort
echo ""
echo -e "${PURPLE}Merging results and removing duplicates...${NC}"
cat "$TEMP_DIR"/*.txt 2>/dev/null | grep -v '^$' | sort -u > "$OUTPUT_FILE"

# Clean up temporary files
rm -rf "$TEMP_DIR"

# Count results
total_subs=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")
echo -e "${GREEN}✓ Total unique subdomains found: ${YELLOW}$total_subs${NC}"
echo -e "${GREEN}✓ All subdomains saved to: ${CYAN}$OUTPUT_FILE${NC}"