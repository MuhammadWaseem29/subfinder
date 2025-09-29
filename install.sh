#!/bin/bash

# FINDER Tool Installation Script
# Installs all required subdomain enumeration tools
# Author: MuhammadWaseem29

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 FINDER Installation Script                   ║"
echo "║            Installing All Subdomain Tools                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Update system
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install basic dependencies
print_status "Installing basic dependencies..."
apt install -y curl wget git unzip tar snapd python3 python3-pip

# 1. Install Go if not present
print_status "Checking Go installation..."
if command_exists go; then
    print_success "Go is already installed: $(go version)"
else
    print_status "Installing Go..."
    wget -q https://go.dev/dl/go1.22.3.linux-amd64.tar.gz \
    && sudo rm -rf /usr/local/go \
    && sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz \
    && echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc \
    && source ~/.bashrc
    
    # Update current session PATH
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    if command_exists go; then
        print_success "Go installed successfully: $(go version)"
    else
        print_error "Go installation failed"
    fi
fi

# 2. Install Subfinder
print_status "Installing Subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
if command_exists subfinder; then
    print_success "Subfinder installed successfully"
else
    print_error "Subfinder installation failed"
fi

# 3. Install Subdominator
print_status "Installing Subdominator..."

# Install python3-pip if not present
apt install -y python3-pip

# Install pipx
apt install -y pipx

# Try multiple installation methods for Subdominator
print_status "Attempting Subdominator installation (Method 1: pipx)..."
pipx install git+https://github.com/RevoltSecurities/Subdominator

print_status "Attempting Subdominator installation (Method 2: pipx force)..."
pipx install subdominator --force

print_status "Attempting Subdominator installation (Method 3: pip)..."
pip install --upgrade subdominator --break-system-packages

print_status "Attempting Subdominator installation (Method 4: pip git)..."
pip install --upgrade git+https://github.com/RevoltSecurities/Subdominator --break-system-packages

# Test if subdominator works
if command_exists subdominator; then
    print_success "Subdominator installed successfully"
else
    print_warning "Trying manual installation of Subdominator..."
    
    # Manual installation
    git clone https://github.com/RevoltSecurities/Subdominator.git
    cd Subdominator
    pip install --upgrade pip --break-system-packages
    pip install -r requirements.txt --break-system-packages
    pip install . --break-system-packages
    cd ..
    
    # Test again
    if command_exists subdominator; then
        print_success "Subdominator installed successfully (manual method)"
    else
        print_warning "Finding Subdominator binary..."
        SUBDOMINATOR_PATH=$(which subdominator 2>/dev/null || find / -name subdominator 2>/dev/null | grep bin/ | head -1)
        
        if [ -n "$SUBDOMINATOR_PATH" ]; then
            echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.bashrc
            echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.zshrc 2>/dev/null
            print_success "Subdominator path added to shell profiles: $SUBDOMINATOR_PATH"
        else
            print_error "Subdominator installation failed completely"
        fi
    fi
fi

# Install additional dependencies for Subdominator
print_status "Installing additional dependencies for Subdominator..."
apt update && apt install -y \
    libpango-1.0-0 \
    libcairo2 \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info

apt install -y libpango1.0-dev libcairo2-dev

# Verify Subdominator
if command_exists subdominator; then
    print_success "Subdominator is working: $(subdominator --help | head -1)"
fi

# 4. Install Findomain
print_status "Installing Findomain..."
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
unzip findomain-linux-i386.zip
chmod +x findomain
mv findomain /usr/local/bin/
rm findomain-linux-i386.zip

if command_exists findomain; then
    print_success "Findomain installed successfully"
else
    print_error "Findomain installation failed"
fi

# 5. Install Sublist3r
print_status "Installing Sublist3r..."
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r/
pip install -r requirements.txt --break-system-packages
cd ..

# Create sublist3r wrapper script
cat > /usr/local/bin/sublist3r << 'EOF'
#!/bin/bash
python3 $(dirname $(find / -name "sublist3r.py" 2>/dev/null | head -1))/sublist3r.py "$@"
EOF
chmod +x /usr/local/bin/sublist3r

if [ -f "Sublist3r/sublist3r.py" ]; then
    print_success "Sublist3r installed successfully"
else
    print_error "Sublist3r installation failed"
fi

# 6. Install Amass
print_status "Installing Amass..."
apt install -y snapd
systemctl enable --now snapd.socket
snap install amass --classic

if command_exists amass; then
    print_success "Amass installed successfully"
else
    print_error "Amass installation failed"
fi

# 7. Install Assetfinder
print_status "Installing Assetfinder..."
go install github.com/tomnomnom/assetfinder@latest

if command_exists assetfinder; then
    print_success "Assetfinder installed successfully"
else
    print_warning "Assetfinder installation failed, trying with newer Go version..."
    
    # Try with newer Go version
    rm -rf /usr/local/go
    wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && source ~/.bashrc
    
    # Update current session
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    print_status "Go version: $(go version)"
    go install github.com/tomnomnom/assetfinder@latest
    
    if command_exists assetfinder; then
        print_success "Assetfinder installed successfully with newer Go"
    else
        print_error "Assetfinder installation failed"
    fi
fi

# 8. Install Subscraper
print_status "Installing Subscraper..."
cd ~
git clone https://github.com/m8sec/subscraper
cd subscraper

# Install dependencies
pip3 install -r requirements.txt --break-system-packages
pip3 install ipparser --break-system-packages
pip3 install taser --break-system-packages

# Install additional packages
apt install -y python3-poetry
pip3 install taser --break-system-packages --no-deps
pip3 install beautifulsoup4 bs4 lxml ntlm-auth requests-file requests-ntlm tldextract selenium selenium-wire webdriver-manager --break-system-packages
pip3 install bs4 --break-system-packages
pip3 install requests_ntlm --break-system-packages
pip3 install tldextract --break-system-packages
pip3 install selenium --break-system-packages --no-deps
pip3 install trio trio-websocket certifi typing_extensions pysocks --break-system-packages

# Test subscraper
if [ -f "subscraper.py" ]; then
    print_success "Subscraper installed successfully in ~/subscraper/"
else
    print_error "Subscraper installation failed"
fi

cd ~

# Final verification
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    Installation Summary                      ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
print_status "Verifying all tools..."

# Test each tool
tools=("subfinder" "subdominator" "findomain" "amass" "assetfinder")
for tool in "${tools[@]}"; do
    if command_exists $tool; then
        echo -e "${GREEN}✓${NC} $tool - ${GREEN}Installed${NC}"
    else
        echo -e "${RED}✗${NC} $tool - ${RED}Failed${NC}"
    fi
done

# Check sublist3r
if [ -f "Sublist3r/sublist3r.py" ]; then
    echo -e "${GREEN}✓${NC} sublist3r - ${GREEN}Installed${NC}"
else
    echo -e "${RED}✗${NC} sublist3r - ${RED}Failed${NC}"
fi

# Check subscraper
if [ -f "subscraper/subscraper.py" ]; then
    echo -e "${GREEN}✓${NC} subscraper - ${GREEN}Installed${NC}"
else
    echo -e "${RED}✗${NC} subscraper - ${RED}Failed${NC}"
fi

echo ""
print_success "Installation script completed!"
print_status "Please restart your terminal or run: source ~/.bashrc"
print_status "Then test your FINDER tool: ./finder.sh -d example.com"

echo ""
echo -e "${CYAN}🎯 All tools installed for FINDER subdomain enumeration! 🎯${NC}"