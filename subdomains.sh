#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
#                           SUBDOMAINS - Community Edition
#                      Multi-Tool Subdomain Enumeration Framework
# ═══════════════════════════════════════════════════════════════════════════════
# 
# Author: MuhammadWaseem29 (@MuhammadWaseem29)
# Repository: https://github.com/MuhammadWaseem29/subfinder
# Version: 2.0.0 Community Edition
# License: MIT
#
# Description: A comprehensive subdomain enumeration tool that integrates 7
#              powerful subdomain discovery tools with automated installation,
#              intelligent path detection, and professional reporting.
#
# Supported Tools:
#   • subfinder    - Fast passive subdomain discovery
#   • subdominator - Advanced subdomain enumeration 
#   • amass        - In-depth DNS enumeration and network mapping
#   • assetfinder  - Find domains and subdomains related to a given domain
#   • findomain    - Cross-platform subdomain enumerator
#   • sublist3r    - Python-based subdomain discovery tool
#   • subscraper   - DNS brute force + certificate transparency
#
# Usage:
#   ./subdomains.sh -d example.com                    # Single domain
#   ./subdomains.sh -dL domains.txt                   # Multiple domains
#   ./subdomains.sh -d example.com -o results.txt     # Custom output
#   ./subdomains.sh --install                         # Install all tools
#   ./subdomains.sh --check                          # Check tool status
#   ./subdomains.sh --help                           # Show help
#
# ═══════════════════════════════════════════════════════════════════════════════

# Script Configuration
VERSION="2.0.0"
AUTHOR="MuhammadWaseem29"
OUTPUT_FILE="subdomains_$(date +%Y%m%d_%H%M%S).txt"
TEMP_DIR="temp_subdomains_$$"
REPORT_DIR="reports"

# Auto-load Go PATH if not in current session
if ! command -v go >/dev/null 2>&1; then
    # Try to load Go from common locations
    if [ -d "/usr/local/go/bin" ]; then
        export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
    fi
fi

# Auto-load common binary paths
export PATH="$PATH:$HOME/go/bin:/usr/local/bin:/snap/bin"

# Load pipx paths if they exist
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# Also check for root go path
if [ -d "/root/go/bin" ]; then
    export PATH="$PATH:/root/go/bin"
fi

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner Function
show_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         SUBDOMAINS - Community Edition                       ║"
    echo "║                     Multi-Tool Subdomain Enumeration Framework               ║"
    echo "║                                                                               ║"
    echo "║  Version: $VERSION                                    Author: $AUTHOR  ║"
    echo "║  Repository: https://github.com/MuhammadWaseem29/subfinder             ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Logging Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_progress() {
    echo -e "${PURPLE}[PROGRESS]${NC} $1"
}

# Debug Function
debug_paths() {
    show_banner
    echo -e "${YELLOW}${BOLD}PATH DEBUG INFORMATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo -e "${BLUE}Current PATH:${NC} $PATH"
    echo ""
    
    echo -e "${CYAN}${BOLD}GO BINARY LOCATIONS:${NC}"
    echo -e "${WHITE}Go command:${NC} $(which go 2>/dev/null || echo -e '${RED}NOT FOUND${NC}')"
    echo -e "${WHITE}Go version:${NC} $(go version 2>/dev/null || echo -e '${RED}NOT ACCESSIBLE${NC}')"
    echo ""
    
    echo -e "${CYAN}${BOLD}SEARCHING FOR BINARIES:${NC}"
    echo -e "${WHITE}Subfinder locations:${NC}"
    find /root/go /home/*/go $HOME/go /usr/local -name "subfinder" 2>/dev/null || echo -e "${RED}No subfinder found${NC}"
    echo ""
    
    echo -e "${WHITE}Assetfinder locations:${NC}"
    find /root/go /home/*/go $HOME/go /usr/local -name "assetfinder" 2>/dev/null || echo -e "${RED}No assetfinder found${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}COMMAND DETECTION TEST:${NC}"
    local tools=("subfinder" "subdominator" "amass" "assetfinder" "findomain" "sublist3r")
    for tool in "${tools[@]}"; do
        local cmd_path=$(command -v $tool 2>/dev/null)
        if [ -n "$cmd_path" ]; then
            echo -e "${GREEN}✓${NC} $tool: $cmd_path"
        else
            echo -e "${RED}✗${NC} $tool: NOT FOUND"
        fi
    done
    echo ""
    
    echo -e "${CYAN}${BOLD}MANUAL PATH LOAD TEST:${NC}"
    export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:/root/go/bin"
    echo "After PATH update:"
    echo -e "${WHITE}subfinder:${NC} $(command -v subfinder 2>/dev/null || echo -e '${RED}STILL NOT FOUND${NC}')"
    echo -e "${WHITE}assetfinder:${NC} $(command -v assetfinder 2>/dev/null || echo -e '${RED}STILL NOT FOUND${NC}')"
    echo ""
    
    echo -e "${CYAN}${BOLD}SUGGESTED FIXES:${NC}"
    echo "1. Run: source ~/.bashrc"
    echo "2. Run: export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin"
    echo "3. Restart terminal session"
    echo "4. Re-run installation: sudo ./subdomains.sh --install"
}

# PATH Refresh Function
refresh_paths() {
    # Source bash profile if it exists
    [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null
    [ -f ~/.profile ] && source ~/.profile 2>/dev/null
    
    # Add Go paths
    export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:/root/go/bin"
    
    # Add common binary paths
    export PATH="$PATH:/usr/local/bin:/snap/bin:$HOME/.local/bin"
    
    # Remove duplicates from PATH
    export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
}
# Tool Detection Function
detect_tool_path() {
    local tool="$1"
    
    case "$tool" in
        "subfinder")
            # Enhanced detection for subfinder
            if command -v subfinder >/dev/null 2>&1; then
                echo "subfinder"
            elif [ -f "$HOME/go/bin/subfinder" ]; then
                echo "$HOME/go/bin/subfinder"
            elif [ -f "/root/go/bin/subfinder" ]; then
                echo "/root/go/bin/subfinder"
            else
                # Search for subfinder binary
                SUBFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "subfinder" 2>/dev/null | head -1)
                if [ -n "$SUBFINDER_PATH" ]; then
                    echo "$SUBFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "assetfinder")
            # Enhanced detection for assetfinder
            if command -v assetfinder >/dev/null 2>&1; then
                echo "assetfinder"
            elif [ -f "$HOME/go/bin/assetfinder" ]; then
                echo "$HOME/go/bin/assetfinder"
            elif [ -f "/root/go/bin/assetfinder" ]; then
                echo "/root/go/bin/assetfinder"
            else
                # Search for assetfinder binary
                ASSETFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "assetfinder" 2>/dev/null | head -1)
                if [ -n "$ASSETFINDER_PATH" ]; then
                    echo "$ASSETFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "sublist3r")
            # Try multiple locations for sublist3r
            if command -v sublist3r >/dev/null 2>&1; then
                echo "sublist3r"
            elif [ -f "/opt/Sublist3r/sublist3r.py" ]; then
                echo "python3 /opt/Sublist3r/sublist3r.py"
            elif [ -f "Sublist3r/sublist3r.py" ]; then
                echo "python3 Sublist3r/sublist3r.py"
            else
                SUBLIST3R_PATH=$(find / -name "sublist3r.py" 2>/dev/null | head -1)
                if [ -n "$SUBLIST3R_PATH" ]; then
                    echo "python3 $SUBLIST3R_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "subscraper")
            # Try multiple locations for subscraper
            if [ -f "/opt/subscraper/subscraper.py" ]; then
                echo "python3 /opt/subscraper/subscraper.py"
            elif [ -f "/root/subscraper/subscraper.py" ]; then
                echo "python3 /root/subscraper/subscraper.py"
            elif [ -f "~/subscraper/subscraper.py" ]; then
                echo "python3 ~/subscraper/subscraper.py"
            elif [ -f "subscraper/subscraper.py" ]; then
                echo "python3 subscraper/subscraper.py"
            else
                SUBSCRAPER_PATH=$(find / -name "subscraper.py" 2>/dev/null | head -1)
                if [ -n "$SUBSCRAPER_PATH" ]; then
                    echo "python3 $SUBSCRAPER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "assetfinder")
            # Enhanced detection for assetfinder
            if command -v assetfinder >/dev/null 2>&1; then
                echo "assetfinder"
            elif [ -f "$HOME/go/bin/assetfinder" ]; then
                echo "$HOME/go/bin/assetfinder"
            elif [ -f "/root/go/bin/assetfinder" ]; then
                echo "/root/go/bin/assetfinder"
            else
                # Search for assetfinder binary
                ASSETFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "assetfinder" 2>/dev/null | head -1)
                if [ -n "$ASSETFINDER_PATH" ]; then
                    echo "$ASSETFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        *)
            if command -v "$tool" >/dev/null 2>&1; then
                echo "$tool"
            else
                echo ""
            fi
            ;;
    esac
}

# Tool Availability Check
check_tools() {
    # Refresh PATH variables before checking
    refresh_paths
    
    local tools=("subfinder" "subdominator" "amass" "assetfinder" "findomain" "sublist3r" "subscraper")
    local available=0
    local total=${#tools[@]}
    
    echo -e "${CYAN}${BOLD}Tool Availability Check:${NC}"
    echo "────────────────────────────────────────────────────────────────"
    
    for tool in "${tools[@]}"; do
        local tool_path=$(detect_tool_path "$tool")
        if [ -n "$tool_path" ]; then
            echo -e "${GREEN}✓${NC} $tool - ${GREEN}Available${NC} ($tool_path)"
            ((available++))
        else
            echo -e "${RED}✗${NC} $tool - ${RED}Not Found${NC}"
        fi
    done
    
    echo "────────────────────────────────────────────────────────────────"
    echo -e "${BLUE}Status:${NC} $available/$total tools available"
    
    if [ $available -eq $total ]; then
        log_success "All tools are ready! 🎯"
        return 0
    elif [ $available -gt 0 ]; then
        log_warning "Some tools are missing. Run './subdomains.sh --install' to install missing tools."
        return 1
    else
        log_error "No tools found! Please run './subdomains.sh --install' first."
        return 2
    fi
}

# Cleanup Function
cleanup() {
    echo ""
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR" 2>/dev/null
    rm -rf temp_subdomains_* 2>/dev/null
    log_success "Cleanup completed"
    exit 1
}

# Set trap for cleanup on interruption
trap cleanup INT TERM

# Installation Function
install_tools() {
    show_banner
    log_info "Starting automated tool installation..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "Installation requires root privileges. Please run with sudo."
        log_info "Example: sudo ./subdomains.sh --install"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection. Please check your network."
        exit 1
    fi
    
    # Update system
    log_info "Updating system packages..."
    apt update && apt upgrade -y
    
    # Install dependencies
    log_info "Installing dependencies..."
    apt install -y curl wget git unzip tar snapd python3 python3-pip golang-go
    
    # 1. Install Go if needed
    log_info "Checking Go installation..."
    if ! command -v go >/dev/null 2>&1; then
        log_info "Installing Go..."
        wget -q https://go.dev/dl/go1.22.3.linux-amd64.tar.gz \
        && rm -rf /usr/local/go \
        && tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz \
        && echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc \
        && echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.zshrc \
        && source ~/.bashrc
        
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        rm go1.22.3.linux-amd64.tar.gz
        
        if command -v go >/dev/null 2>&1; then
            log_success "Go installed successfully: $(go version)"
        else
            log_error "Go installation failed"
        fi
    else
        log_success "Go is already installed: $(go version)"
    fi
    
    # 2. Install Subfinder
    log_info "Installing subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    if command -v subfinder >/dev/null 2>&1; then
        log_success "Subfinder installed successfully"
    else
        log_error "Subfinder installation failed"
    fi
    
    # 3. Install Subdominator (comprehensive installation)
    log_info "Installing subdominator with multiple methods..."
    
    # Install pip and pipx first
    apt install -y python3-pip pipx
    
    # Method 1: pipx
    log_info "Trying pipx installation..."
    if pipx install git+https://github.com/RevoltSecurities/Subdominator 2>/dev/null; then
        log_success "Subdominator installed via pipx (git)"
    elif pipx install subdominator --force 2>/dev/null; then
        log_success "Subdominator installed via pipx (package)"
    else
        log_warning "Pipx failed, trying pip methods..."
        
        # Method 2: pip with break-system-packages
        pip install --upgrade subdominator --break-system-packages 2>/dev/null
        pip install --upgrade git+https://github.com/RevoltSecurities/Subdominator --break-system-packages 2>/dev/null
        
        # Method 3: Manual installation if pip fails
        if ! command -v subdominator >/dev/null 2>&1; then
            log_info "Trying manual installation..."
            git clone https://github.com/RevoltSecurities/Subdominator.git
            cd Subdominator
            pip install --upgrade pip --break-system-packages
            pip install -r requirements.txt --break-system-packages
            pip install . --break-system-packages
            cd ..
            
            # Test installation
            if ! command -v subdominator >/dev/null 2>&1; then
                log_warning "Finding subdominator binary..."
                SUBDOMINATOR_PATH=$(which subdominator 2>/dev/null || find / -name subdominator 2>/dev/null | grep bin/ | head -1)
                
                if [ -n "$SUBDOMINATOR_PATH" ]; then
                    echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.bashrc
                    echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.zshrc
                    export PATH=$PATH:$(dirname $SUBDOMINATOR_PATH)
                    log_success "Subdominator path added to shell profiles"
                fi
            fi
        fi
    fi
    
    # Install dependencies for Subdominator
    log_info "Installing Subdominator dependencies..."
    apt update && apt install -y \
        libpango-1.0-0 \
        libcairo2 \
        libpangoft2-1.0-0 \
        libpangocairo-1.0-0 \
        libgdk-pixbuf2.0-0 \
        libffi-dev \
        shared-mime-info
    
    apt install -y libpango1.0-dev libcairo2-dev
    
    # Verify subdominator
    if command -v subdominator >/dev/null 2>&1; then
        log_success "Subdominator installed and working"
    else
        log_warning "Subdominator may need manual PATH configuration"
    fi
    
    # 4. Install Amass
    log_info "Installing amass..."
    apt update && apt install -y snapd unzip curl
    systemctl enable --now snapd.socket
    snap install amass --classic
    
    if command -v amass >/dev/null 2>&1; then
        log_success "Amass installed successfully"
    else
        log_error "Amass installation failed"
    fi
    
    # 5. Install Assetfinder
    log_info "Installing assetfinder..."
    go install github.com/tomnomnom/assetfinder@latest
    
    if ! command -v assetfinder >/dev/null 2>&1; then
        log_warning "Assetfinder failed, trying with newer Go..."
        rm -rf /usr/local/go
        wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
        tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
        source ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        
        log_info "Updated Go version: $(go version)"
        go install github.com/tomnomnom/assetfinder@latest
        rm go1.23.2.linux-amd64.tar.gz
    fi
    
    if command -v assetfinder >/dev/null 2>&1; then
        log_success "Assetfinder installed successfully"
    else
        log_error "Assetfinder installation failed"
    fi
    
    # 6. Install Findomain
    log_info "Installing findomain..."
    curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
    apt install -y unzip
    unzip findomain-linux-i386.zip
    chmod +x findomain
    mv findomain /usr/local/bin/
    rm findomain-linux-i386.zip
    
    if command -v findomain >/dev/null 2>&1; then
        log_success "Findomain installed successfully"
    else
        log_error "Findomain installation failed"
    fi
    
    # 7. Install Sublist3r
    log_info "Installing sublist3r..."
    git clone https://github.com/aboul3la/Sublist3r.git /opt/Sublist3r
    cd /opt/Sublist3r
    pip install -r requirements.txt --break-system-packages
    
    # Create symlink for easy access
    ln -sf /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
    chmod +x /usr/local/bin/sublist3r
    cd -
    
    if [ -f "/opt/Sublist3r/sublist3r.py" ]; then
        log_success "Sublist3r installed successfully"
    else
        log_error "Sublist3r installation failed"
    fi
    
    # 8. Install Subscraper
    log_info "Installing subscraper..."
    cd ~
    git clone https://github.com/m8sec/subscraper /opt/subscraper
    cd /opt/subscraper
    
    # Install all dependencies
    pip3 install -r requirements.txt --break-system-packages
    pip3 install ipparser --break-system-packages
    pip3 install taser --break-system-packages
    
    # Install additional packages
    apt update && apt install -y python3-poetry
    pip3 install taser --break-system-packages --no-deps
    pip3 install beautifulsoup4 bs4 lxml ntlm-auth requests-file requests-ntlm tldextract selenium selenium-wire webdriver-manager --break-system-packages
    pip3 install bs4 --break-system-packages
    pip3 install requests_ntlm --break-system-packages
    pip3 install tldextract --break-system-packages
    pip3 install selenium --break-system-packages --no-deps
    pip3 install trio trio-websocket certifi typing_extensions pysocks --break-system-packages
    
    cd -
    
    if [ -f "/opt/subscraper/subscraper.py" ]; then
        log_success "Subscraper installed successfully"
    else
        log_error "Subscraper installation failed"
    fi
    
    # Final Go PATH setup for both shells
    log_info "Setting up Go PATH for bash and zsh..."
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.zshrc 2>/dev/null || true
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    log_success "Installation completed! Please restart your terminal or run:"
    echo "  source ~/.bashrc"
    log_info "Test with: ./subdomains.sh --check"
    
    # Final verification
    echo ""
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}${BOLD}                              INSTALLATION SUMMARY                             ${NC}"
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo ""
    log_info "Verifying all tools..."
    
    local tools=("subfinder" "subdominator" "amass" "assetfinder" "findomain" "sublist3r" "subscraper")
    local installed=0
    local total=${#tools[@]}
    
    for tool in "${tools[@]}"; do
        local tool_path=$(detect_tool_path "$tool")
        if [ -n "$tool_path" ]; then
            echo -e "${GREEN}✓${NC} $tool - ${GREEN}Available${NC} ($tool_path)"
            ((installed++))
        else
            echo -e "${RED}✗${NC} $tool - ${RED}Not Found${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Final Status:${NC} $installed/$total tools successfully installed"
    
    if [ $installed -eq $total ]; then
        echo -e "${GREEN}${BOLD}🎯 ALL TOOLS INSTALLED SUCCESSFULLY! 🎯${NC}"
        echo -e "${CYAN}You can now run: ./subdomains.sh -d example.com${NC}"
    elif [ $installed -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}⚠️  PARTIAL INSTALLATION COMPLETED ⚠️${NC}"
        echo -e "${YELLOW}Some tools may need manual configuration or PATH updates.${NC}"
        echo -e "${CYAN}Available tools can still be used with: ./subdomains.sh -d example.com${NC}"
    else
        echo -e "${RED}${BOLD}❌ INSTALLATION FAILED ❌${NC}"
        echo -e "${RED}Please check the error messages above and try manual installation.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}NEXT STEPS:${NC}"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Test installation: ./subdomains.sh --check"
    echo "3. Run enumeration: ./subdomains.sh -d example.com"
    echo ""
}

# Help Function
show_help() {
    show_banner
    echo -e "${YELLOW}${BOLD}USAGE:${NC}"
    echo "  $0 [OPTIONS] -d <domain>                 Single domain enumeration"
    echo "  $0 [OPTIONS] -dL <file>                  Multiple domains from file"
    echo ""
    echo -e "${YELLOW}${BOLD}OPTIONS:${NC}"
    echo "  -d  <domain>              Target domain to enumerate"
    echo "  -dL <file>               File containing list of domains (one per line)"
    echo "  -o  <output_file>        Custom output file (default: subdomains_TIMESTAMP.txt)"
    echo "  -r  <report_name>        Generate detailed report"
    echo "  --install                Install all required tools"
    echo "  --check                  Check tool availability"
    echo "  --debug                  Show PATH and binary location debug info"
    echo "  --update                 Update all tools to latest versions"
    echo "  --version                Show version information"
    echo "  --help                   Show this help message"
    echo ""
    echo -e "${YELLOW}${BOLD}EXAMPLES:${NC}"
    echo "  $0 -d example.com                        # Basic enumeration"
    echo "  $0 -d example.com -o results.txt         # Custom output file"
    echo "  $0 -dL domains.txt -r security_audit     # Multiple domains with report"
    echo "  $0 --install                             # Install all tools"
    echo "  $0 --check                               # Check tool status"
    echo "  $0 --debug                               # Debug PATH issues"
    echo ""
    echo -e "${YELLOW}${BOLD}SUPPORTED TOOLS:${NC}"
    echo "  • subfinder    - Fast passive subdomain discovery"
    echo "  • subdominator - Advanced subdomain enumeration"
    echo "  • amass        - In-depth DNS enumeration and network mapping"
    echo "  • assetfinder  - Find domains and subdomains"
    echo "  • findomain    - Cross-platform subdomain enumerator"
    echo "  • sublist3r    - Python-based subdomain discovery"
    echo "  • subscraper   - DNS brute force + certificate transparency"
    echo ""
    echo -e "${CYAN}For more information, visit: https://github.com/MuhammadWaseem29/subfinder${NC}"
}

# Generate Report Function
generate_report() {
    local domain="$1"
    local report_name="$2"
    local total_subs="$3"
    
    mkdir -p "$REPORT_DIR"
    local report_file="$REPORT_DIR/${report_name}_$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Subdomain Enumeration Report - $domain</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 8px; }
        .stats { background: #ecf0f1; padding: 15px; margin: 20px 0; border-radius: 8px; }
        .tool-section { margin: 20px 0; padding: 15px; border-left: 4px solid #3498db; }
        .subdomain { font-family: monospace; background: #f8f9fa; padding: 2px 5px; margin: 2px; display: inline-block; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Subdomain Enumeration Report</h1>
        <p>Domain: <strong>$domain</strong> | Generated: $(date) | Tool: SUBDOMAINS v$VERSION</p>
    </div>
    
    <div class="stats">
        <h2>Summary</h2>
        <p><strong>Total Unique Subdomains Found:</strong> $total_subs</p>
        <p><strong>Tools Used:</strong> 7 (subfinder, subdominator, amass, assetfinder, findomain, sublist3r, subscraper)</p>
        <p><strong>Output File:</strong> $OUTPUT_FILE</p>
    </div>
    
    <div class="tool-section">
        <h2>Discovered Subdomains</h2>
        <div>
EOF

    # Add subdomains to report
    while read -r subdomain; do
        echo "            <span class=\"subdomain\">$subdomain</span>" >> "$report_file"
    done < "$OUTPUT_FILE"
    
    cat >> "$report_file" << EOF
        </div>
    </div>
    
    <footer style="margin-top: 40px; text-align: center; color: #7f8c8d;">
        <p>Generated by SUBDOMAINS Community Edition v$VERSION | Author: $AUTHOR</p>
        <p>Repository: https://github.com/MuhammadWaseem29/subfinder</p>
    </footer>
</body>
</html>
EOF

    log_success "HTML report generated: $report_file"
}

# Main Enumeration Function
run_enumeration() {
    local target="$1"
    local target_type="$2"  # "domain" or "file"
    
    show_banner
    
    # Refresh PATH variables for this session
    refresh_paths
    
    # Create directories
    rm -rf temp_subdomains_* 2>/dev/null
    mkdir -p "$TEMP_DIR" "$REPORT_DIR"
    
    # Check tools before starting
    check_tools
    local tool_status=$?
    if [ $tool_status -eq 2 ]; then
        log_error "Cannot proceed without tools. Run --install first."
        exit 1
    fi
    
    log_info "Starting subdomain enumeration for: $target"
    log_info "Output will be saved to: $OUTPUT_FILE"
    echo ""
    
    # Tool execution with dynamic path detection
    local tools=("subfinder" "subdominator" "amass" "assetfinder" "findomain" "sublist3r" "subscraper")
    local completed=0
    
    for i in "${!tools[@]}"; do
        local tool="${tools[$i]}"
        local tool_num=$((i + 1))
        local tool_path=$(detect_tool_path "$tool")
        
        if [ -z "$tool_path" ]; then
            log_warning "[$tool_num/7] Skipping $tool - not found"
            continue
        fi
        
        echo -e "${BLUE}[$tool_num/7]${NC} ${YELLOW}Running${NC} ${GREEN}$tool${NC} for $target_type: ${CYAN}$target${NC}..."
        echo "════════════════════════════════════════════════════════════════════════════════"
        
        case "$tool" in
            "subfinder")
                if [ "$target_type" == "domain" ]; then
                    timeout 300 $tool_path -d "$target" 2>/dev/null | tee "$TEMP_DIR/subfinder.txt" || {
                        log_warning "Subfinder timed out or failed for $target"
                        touch "$TEMP_DIR/subfinder.txt"
                    }
                else
                    timeout 600 $tool_path -dL "$target" 2>/dev/null | tee "$TEMP_DIR/subfinder.txt" || {
                        log_warning "Subfinder timed out or failed for domain list"
                        touch "$TEMP_DIR/subfinder.txt"
                    }
                fi
                ;;
            "subdominator")
                if [ "$target_type" == "domain" ]; then
                    $tool_path -d "$target" | tee "$TEMP_DIR/subdominator.txt"
                else
                    $tool_path -dL "$target" | tee "$TEMP_DIR/subdominator.txt"
                fi
                ;;
            "amass")
                if [ "$target_type" == "domain" ]; then
                    $tool_path enum -passive -d "$target" | tee "$TEMP_DIR/amass.txt"
                else
                    while read -r domain; do
                        [ -n "$domain" ] && $tool_path enum -passive -d "$domain" | tee -a "$TEMP_DIR/amass.txt"
                    done < "$target"
                fi
                ;;
            "assetfinder")
                if [ "$target_type" == "domain" ]; then
                    $tool_path --subs-only "$target" | tee "$TEMP_DIR/assetfinder.txt"
                else
                    while read -r domain; do
                        [ -n "$domain" ] && $tool_path --subs-only "$domain" | tee -a "$TEMP_DIR/assetfinder.txt"
                    done < "$target"
                fi
                ;;
            "findomain")
                if [ "$target_type" == "domain" ]; then
                    $tool_path -t "$target" | tee "$TEMP_DIR/findomain.txt"
                else
                    $tool_path -f "$target" | tee "$TEMP_DIR/findomain.txt"
                fi
                ;;
            "sublist3r")
                if [ "$target_type" == "domain" ]; then
                    $tool_path -d "$target" | tee "$TEMP_DIR/sublist3r.txt"
                else
                    while read -r domain; do
                        [ -n "$domain" ] && $tool_path -d "$domain" | tee -a "$TEMP_DIR/sublist3r.txt"
                    done < "$target"
                fi
                ;;
            "subscraper")
                if [ "$target_type" == "domain" ]; then
                    $tool_path -d "$target" | tee "$TEMP_DIR/subscraper.txt"
                else
                    while read -r domain; do
                        [ -n "$domain" ] && $tool_path -d "$domain" | tee -a "$TEMP_DIR/subscraper.txt"
                    done < "$target"
                fi
                ;;
        esac
        
        echo "════════════════════════════════════════════════════════════════════════════════"
        log_success "Completed $tool"
        echo ""
        ((completed++))
    done
    
    # Merge results
    echo ""
    log_progress "Merging results and removing duplicates..."
    cat "$TEMP_DIR"/*.txt 2>/dev/null | grep -v '^$' | sort -u > "$OUTPUT_FILE"
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    rm -rf temp_subdomains_* 2>/dev/null
    
    # Results
    local total_subs=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")
    echo ""
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}                              RESULTS SUMMARY                                ${NC}"
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Target:${NC}                 $target"
    echo -e "${WHITE}Tools Executed:${NC}         $completed/7"
    echo -e "${WHITE}Total Subdomains Found:${NC} ${YELLOW}${BOLD}$total_subs${NC}"
    echo -e "${WHITE}Output File:${NC}            ${CYAN}$OUTPUT_FILE${NC}"
    echo -e "${WHITE}Execution Time:${NC}        $(date)"
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Generate report if requested
    if [ -n "$REPORT_NAME" ]; then
        generate_report "$target" "$REPORT_NAME" "$total_subs"
    fi
    
    log_success "Subdomain enumeration completed! 🎯"
}

# Main Script Logic
main() {
    # Default values
    DOMAIN=""
    DOMAIN_FILE=""
    REPORT_NAME=""
    
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
            -r)
                REPORT_NAME="$2"
                shift 2
                ;;
            --install)
                install_tools
                exit 0
                ;;
            --check)
                show_banner
                check_tools
                exit $?
                ;;
            --debug)
                debug_paths
                exit 0
                ;;
            --version)
                show_banner
                echo -e "${WHITE}Version:${NC} $VERSION"
                echo -e "${WHITE}Author:${NC} $AUTHOR"
                echo -e "${WHITE}Repository:${NC} https://github.com/MuhammadWaseem29/subfinder"
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [ -n "$DOMAIN" ] && [ -n "$DOMAIN_FILE" ]; then
        log_error "Cannot use both -d and -dL options simultaneously."
        exit 1
    fi
    
    if [ -z "$DOMAIN" ] && [ -z "$DOMAIN_FILE" ]; then
        show_help
        exit 1
    fi
    
    # Execute enumeration
    if [ -n "$DOMAIN" ]; then
        run_enumeration "$DOMAIN" "domain"
    elif [ -n "$DOMAIN_FILE" ]; then
        if [ ! -f "$DOMAIN_FILE" ]; then
            log_error "Domain file not found: $DOMAIN_FILE"
            exit 1
        fi
        if [ ! -s "$DOMAIN_FILE" ]; then
            log_error "Domain file is empty: $DOMAIN_FILE"
            exit 1
        fi
        run_enumeration "$DOMAIN_FILE" "file"
    fi
}

# Execute main function
main "$@"