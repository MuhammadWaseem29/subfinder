#!/bin/bash

# Multi-tool subdomain enumeration script - FINDER
# Usage: ./finder.sh -d domain.com [-o output.txt]
# Usage: ./finder.sh -dL domains.txt [-o output.txt]

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

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR" 2>/dev/null
    # Also clean up any orphaned temp directories
    rm -rf temp_subs_* 2>/dev/null
    echo -e "${GREEN}✓ Cleanup completed${NC}"
    exit 1
}

# Set trap to cleanup on script interruption
trap cleanup INT TERM

# Domain validation function
validate_domain() {
    local domain="$1"
    if [[ ! "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}Error: Invalid domain format: $domain${NC}"
        return 1
    fi
    return 0
}

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

# Clean up any existing orphaned temp directories
rm -rf temp_subs_* 2>/dev/null

# Create temp directory
mkdir -p "$TEMP_DIR"

if [ -n "$DOMAIN" ]; then
    echo -e "${BLUE}[1/7]${NC} ${YELLOW}Running${NC} ${GREEN}subfinder${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    subfinder -d "$DOMAIN" | tee "$TEMP_DIR/subfinder.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subfinder"
    echo ""
    
    echo -e "${BLUE}[2/7]${NC} ${YELLOW}Running${NC} ${GREEN}subdominator${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    subdominator -d "$DOMAIN" | tee "$TEMP_DIR/subdominator.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subdominator"
    echo ""
    
    echo -e "${BLUE}[3/7]${NC} ${YELLOW}Running${NC} ${GREEN}amass${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    amass enum -passive -d "$DOMAIN" | tee "$TEMP_DIR/amass.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} amass"
    echo ""
    
    echo -e "${BLUE}[4/7]${NC} ${YELLOW}Running${NC} ${GREEN}assetfinder${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    assetfinder --subs-only "$DOMAIN" | tee "$TEMP_DIR/assetfinder.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} assetfinder"
    echo ""
    
    echo -e "${BLUE}[5/7]${NC} ${YELLOW}Running${NC} ${GREEN}findomain${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    findomain -t "$DOMAIN" | tee "$TEMP_DIR/findomain.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} findomain"
    echo ""
    
    echo -e "${BLUE}[6/7]${NC} ${YELLOW}Running${NC} ${GREEN}sublist3r${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    # Try multiple locations for sublist3r
    if command -v sublist3r >/dev/null 2>&1; then
        sublist3r -d "$DOMAIN" | tee "$TEMP_DIR/sublist3r.txt"
    elif [ -f "Sublist3r/sublist3r.py" ]; then
        python3 Sublist3r/sublist3r.py -d "$DOMAIN" | tee "$TEMP_DIR/sublist3r.txt"
    elif [ -f "/opt/Sublist3r/sublist3r.py" ]; then
        python3 /opt/Sublist3r/sublist3r.py -d "$DOMAIN" | tee "$TEMP_DIR/sublist3r.txt"
    else
        echo -e "${YELLOW}Warning: sublist3r not found, skipping...${NC}"
        touch "$TEMP_DIR/sublist3r.txt"
    fi
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} sublist3r"
    echo ""
    
    echo -e "${BLUE}[7/7]${NC} ${YELLOW}Running${NC} ${GREEN}subscraper${NC} for domain: ${CYAN}$DOMAIN${NC}..."
    echo "================================================================================================"
    # Try multiple locations for subscraper
    if [ -f "/opt/subscraper/subscraper.py" ]; then
        python3 /opt/subscraper/subscraper.py -d "$DOMAIN" | tee "$TEMP_DIR/subscraper.txt"
    elif [ -f "/root/subscraper/subscraper.py" ]; then
        python3 /root/subscraper/subscraper.py -d "$DOMAIN" | tee "$TEMP_DIR/subscraper.txt"
    elif [ -f "subscraper/subscraper.py" ]; then
        python3 subscraper/subscraper.py -d "$DOMAIN" | tee "$TEMP_DIR/subscraper.txt"
    else
        echo -e "${YELLOW}Warning: subscraper not found, skipping...${NC}"
        touch "$TEMP_DIR/subscraper.txt"
    fi
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subscraper"
    echo ""
    
elif [ -n "$DOMAIN_FILE" ]; then
    echo -e "${BLUE}[1/7]${NC} ${YELLOW}Running${NC} ${GREEN}subfinder${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    subfinder -dL "$DOMAIN_FILE" | tee "$TEMP_DIR/subfinder.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subfinder"
    echo ""
    
    echo -e "${BLUE}[2/7]${NC} ${YELLOW}Running${NC} ${GREEN}subdominator${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    subdominator -dL "$DOMAIN_FILE" | tee "$TEMP_DIR/subdominator.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subdominator"
    echo ""
    
    echo -e "${BLUE}[3/7]${NC} ${YELLOW}Running${NC} ${GREEN}amass${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    while read -r domain; do
        [ -n "$domain" ] && amass enum -passive -d "$domain" | tee -a "$TEMP_DIR/amass.txt"
    done < "$DOMAIN_FILE"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} amass"
    echo ""
    
    echo -e "${BLUE}[4/7]${NC} ${YELLOW}Running${NC} ${GREEN}assetfinder${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    while read -r domain; do
        [ -n "$domain" ] && assetfinder --subs-only "$domain" | tee -a "$TEMP_DIR/assetfinder.txt"
    done < "$DOMAIN_FILE"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} assetfinder"
    echo ""
    
    echo -e "${BLUE}[5/7]${NC} ${YELLOW}Running${NC} ${GREEN}findomain${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    findomain -f "$DOMAIN_FILE" | tee "$TEMP_DIR/findomain.txt"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} findomain"
    echo ""
    
    echo -e "${BLUE}[6/7]${NC} ${YELLOW}Running${NC} ${GREEN}sublist3r${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    while read -r domain; do
        if [ -n "$domain" ]; then
            if command -v sublist3r >/dev/null 2>&1; then
                sublist3r -d "$domain" | tee -a "$TEMP_DIR/sublist3r.txt"
            elif [ -f "Sublist3r/sublist3r.py" ]; then
                python3 Sublist3r/sublist3r.py -d "$domain" | tee -a "$TEMP_DIR/sublist3r.txt"
            elif [ -f "/opt/Sublist3r/sublist3r.py" ]; then
                python3 /opt/Sublist3r/sublist3r.py -d "$domain" | tee -a "$TEMP_DIR/sublist3r.txt"
            else
                echo -e "${YELLOW}Warning: sublist3r not found for $domain, skipping...${NC}"
            fi
        fi
    done < "$DOMAIN_FILE"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} sublist3r"
    echo ""
    
    echo -e "${BLUE}[7/7]${NC} ${YELLOW}Running${NC} ${GREEN}subscraper${NC} for domain list: ${CYAN}$DOMAIN_FILE${NC}..."
    echo "================================================================================================"
    while read -r domain; do
        if [ -n "$domain" ]; then
            if [ -f "/opt/subscraper/subscraper.py" ]; then
                python3 /opt/subscraper/subscraper.py -d "$domain" | tee -a "$TEMP_DIR/subscraper.txt"
            elif [ -f "/root/subscraper/subscraper.py" ]; then
                python3 /root/subscraper/subscraper.py -d "$domain" | tee -a "$TEMP_DIR/subscraper.txt"
            elif [ -f "subscraper/subscraper.py" ]; then
                python3 subscraper/subscraper.py -d "$domain" | tee -a "$TEMP_DIR/subscraper.txt"
            else
                echo -e "${YELLOW}Warning: subscraper not found for $domain, skipping...${NC}"
            fi
        fi
    done < "$DOMAIN_FILE"
    echo "================================================================================================"
    echo -e "${GREEN}✓ Completed${NC} subscraper"
    echo ""
    
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

# Check if any result files exist
if ls "$TEMP_DIR"/*.txt 1> /dev/null 2>&1; then
    cat "$TEMP_DIR"/*.txt 2>/dev/null | grep -v '^$' | grep -v '^#' | sort -u > "$OUTPUT_FILE"
else
    echo -e "${YELLOW}Warning: No result files found${NC}"
    touch "$OUTPUT_FILE"
fi

# Clean up temporary files and any orphaned temp directories
rm -rf "$TEMP_DIR"
rm -rf temp_subs_* 2>/dev/null

# Count results
total_subs=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")
echo -e "${GREEN}✓ Total unique subdomains found: ${YELLOW}$total_subs${NC}"
echo -e "${GREEN}✓ All subdomains saved to: ${CYAN}$OUTPUT_FILE${NC}"
echo -e "${GREEN}✓ Temporary files cleaned up${NC}"