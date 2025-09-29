# SUBDOMAINS - Community Edition 🎯

A comprehensive subdomain enumeration framework that combines the power of 7 advanced tools with automated installation and professional reporting capabilities.

## 🌟 Community Edition Features

**SUBDOMAINS v2.0** is the complete, production-ready solution for subdomain discovery:

- **🔧 All-in-One Solution**: Combined enumeration and installation in one script
- **🎯 7 Integrated Tools**: Best-in-class subdomain discovery tools
- **📊 Professional Reporting**: HTML reports with detailed analytics
- **🎨 Beautiful Interface**: Colored output with progress tracking
- **🔍 Smart Tool Detection**: Automatic path discovery and fallback
- **📁 Organized Output**: Timestamped files and report directories
- **⚡ Fast & Reliable**: Optimized execution with error handling

## 🛠️ Supported Tools

This framework integrates **7 powerful subdomain enumeration tools**:

1. **subfinder** - Fast passive subdomain discovery
2. **subdominator** - Advanced subdomain enumeration  
3. **amass** - In-depth DNS enumeration and network mapping
4. **assetfinder** - Find domains and subdomains related to a given domain
5. **findomain** - Cross-platform subdomain enumerator
6. **sublist3r** - Python-based subdomain discovery tool
7. **subscraper** - DNS brute force + certificate transparency

## 📋 Key Features

- **🚀 One-Command Installation**: Automated setup for all tools
- **🎯 Multi-tool Integration**: Combines 7 different subdomain discovery tools
- **📝 Dual Input Methods**: Single domain (`-d`) or domain list (`-dL`)
- **📊 HTML Reports**: Professional reporting with detailed analytics
- **🎨 Colored Interface**: Beautiful progress indicators and status messages
- **🧹 Smart Cleanup**: Automatic temporary file management
- **🔧 Tool Detection**: Intelligent path discovery for all tools
- **⚠️ Signal Handling**: Graceful interruption handling
- **📁 Organized Output**: Timestamped files and structured directories

## 🚀 Quick Start

### Option 1: Community Edition (Recommended)

**Download and use the all-in-one solution:**

```bash
# Download
wget https://raw.githubusercontent.com/MuhammadWaseem29/subfinder/main/subdomains.sh
chmod +x subdomains.sh

# Install all tools (run as root)
sudo ./subdomains.sh --install

# Check tool availability
./subdomains.sh --check

# Run enumeration
./subdomains.sh -d example.com
# Clone repository
git clone https://github.com/MuhammadWaseem29/subfinder.git
cd subfinder

# Install all tools
sudo bash install.sh

# Run enumeration
./finder.sh -d example.com
```

## 🎯 Usage Examples

### Community Edition (subdomains.sh)

```bash
# Install all tools
sudo ./subdomains.sh --install

# Check tool availability
./subdomains.sh --check

# Single domain enumeration
./subdomains.sh -d example.com

# Multiple domains from file
./subdomains.sh -dL domains.txt

# Custom output file
./subdomains.sh -d example.com -o my_results.txt

# Generate HTML report
./subdomains.sh -d example.com -r security_audit

# Show help
./subdomains.sh --help

# Show version
./subdomains.sh --version
```

### Legacy Components

```bash
# finder.sh (enumeration)
./finder.sh -d example.com
./finder.sh -dL domains.txt -o custom_output.txt

# install.sh (setup)
sudo bash install.sh
```

## 📊 Output Structure

### Community Edition Output:
```
📁 Current Directory
├── subdomains_20240128_143022.txt    # Timestamped results
├── 📁 reports/                       # HTML reports (with -r flag)
│   └── security_audit_20240128_143022.html
└── 📁 temp_subdomains_*/ (auto-cleaned)
```

### Legacy Output:
```
📁 Project Directory
├── all_subdomains.txt                # Combined results
└── temp_finder_*/                    # Temporary files
```

## 🔧 Advanced Features

### Tool Status Checking
```bash
./subdomains.sh --check
```

### Custom Output Files
```bash
./subdomains.sh -d example.com -o company_subdomains.txt
```

### HTML Report Generation
```bash
./subdomains.sh -d example.com -r penetration_test
```

### Bulk Domain Processing
```bash
# Create domains.txt file
echo "example.com" > domains.txt
echo "target.com" >> domains.txt
echo "company.com" >> domains.txt

# Run bulk enumeration
./subdomains.sh -dL domains.txt -r bulk_audit
```

## 📋 Tool Installation Status

The community edition automatically detects and installs missing tools:

| Tool | Status Check | Auto-Install | Fallback Paths |
|------|-------------|--------------|----------------|
| subfinder | ✅ | ✅ | Go binary detection |
| subdominator | ✅ | ✅ | Pip package + Git clone |
| amass | ✅ | ✅ | Snap package |
| assetfinder | ✅ | ✅ | Go binary detection |
| findomain | ✅ | ✅ | Binary download |
| sublist3r | ✅ | ✅ | Multiple path detection |
| subscraper | ✅ | ✅ | Git clone installation |

## 🛠️ Manual Installation

If you prefer manual installation of tools:
go install github.com/tomnomnom/assetfinder@latest

# findomain
# Download from: https://github.com/Findomain/Findomain/releases

# sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
pip install -r Sublist3r/requirements.txt

# subscraper
git clone https://github.com/m8sec/subscraper
cd subscraper && pip3 install -r requirements.txt
```

## 📝 Domain List Format

Create a text file with one domain per line:
```
example.com
google.com
github.com
target.org
# Comments are supported
```

## 🔍 Tool Detection Intelligence

The community edition features smart tool detection:

- **Automatic Path Discovery**: Finds tools in standard locations
- **Multiple Installation Methods**: Supports various installation paths
- **Fallback Mechanisms**: Uses alternative paths when needed
- **Binary Validation**: Ensures tools are executable and accessible

## 🎨 Visual Interface

The community edition includes:

- **🎯 Progress Indicators**: Real-time tool execution status
- **🌈 Color-coded Output**: Different colors for different message types
- **📊 Professional Banners**: Clean, branded interface
- **📈 Results Summary**: Detailed statistics and completion status

## 🧹 Cleanup & Management

- **Automatic Cleanup**: Removes temporary files on completion
- **Signal Handling**: Graceful shutdown on interruption (Ctrl+C)
- **Organized Output**: Timestamped files prevent overwrites
- **Report Management**: Structured report directory

## 🚀 Performance Features

- **Parallel Execution**: Tools run simultaneously for speed
- **Optimized Output**: Efficient file handling and deduplication
- **Memory Management**: Proper resource cleanup
- **Error Resilience**: Continues execution even if some tools fail

## 📊 Sample Output

```bash
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         SUBDOMAINS - Community Edition                       ║
║                     Multi-Tool Subdomain Enumeration Framework               ║
║                                                                               ║
║  Version: 2.0.0                                    Author: MuhammadWaseem29  ║
║  Repository: https://github.com/MuhammadWaseem29/subfinder                   ║
╚═══════════════════════════════════════════════════════════════════════════════╝

[INFO] Starting subdomain enumeration for: example.com
[INFO] Output will be saved to: subdomains_20240128_143022.txt

[1/7] Running subfinder for domain: example.com...
[2/7] Running subdominator for domain: example.com...
[3/7] Running amass for domain: example.com...
[4/7] Running assetfinder for domain: example.com...
[5/7] Running findomain for domain: example.com...
[6/7] Running sublist3r for domain: example.com...
[7/7] Running subscraper for domain: example.com...

[PROGRESS] Merging results and removing duplicates...

═══════════════════════════════════════════════════════════════════════════════
                              RESULTS SUMMARY                                
═══════════════════════════════════════════════════════════════════════════════
Target:                 example.com
Tools Executed:         7/7
Total Subdomains Found: 147
Output File:            subdomains_20240128_143022.txt
Execution Time:         2024-01-28 14:30:22
═══════════════════════════════════════════════════════════════════════════════

[SUCCESS] Subdomain enumeration completed! 🎯
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Star History

If you find this tool useful, please consider giving it a star! ⭐

## 📞 Support

- 🐛 **Bug Reports**: [Open an issue](https://github.com/MuhammadWaseem29/subfinder/issues)
- 💡 **Feature Requests**: [Submit a request](https://github.com/MuhammadWaseem29/subfinder/issues)
- 💬 **Discussions**: [Join the conversation](https://github.com/MuhammadWaseem29/subfinder/discussions)

## 🙏 Acknowledgments

Special thanks to the developers of the integrated tools:
- [ProjectDiscovery](https://github.com/projectdiscovery) for subfinder
- [RevoltSecurities](https://github.com/RevoltSecurities) for subdominator
- [OWASP](https://github.com/owasp-amass) for amass
- [tomnomnom](https://github.com/tomnomnom) for assetfinder
- [Findomain](https://github.com/findomain) for findomain
- [aboul3la](https://github.com/aboul3la) for sublist3r
- [m8sec](https://github.com/m8sec) for subscraper

---

<div align="center">
  <strong>Made with ❤️ by <a href="https://github.com/MuhammadWaseem29">MuhammadWaseem29</a></strong>
</div>
