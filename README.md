# Subfinder - Multi-Tool Subdomain Enumeration Script

A comprehensive bash script that automates subdomain discovery using multiple popular tools.

## Features

- **Multiple Tools Integration**: Uses 6 different subdomain enumeration tools
- **Single Domain Mode**: `-d domain.com` for scanning one domain
- **Bulk Mode**: `-dL domains.txt` for scanning multiple domains from a file
- **Output Consolidation**: All results saved to `all_subdomains.txt` with duplicates removed
- **Easy Extension**: Simple structure to add more tools

## Supported Tools

1. **subfinder** - Fast subdomain discovery tool
2. **subdominator** - Advanced subdomain enumeration 
3. **amass** - In-depth DNS enumeration and network mapping
4. **assetfinder** - Find domains and subdomains related to a given domain
5. **findomain** - Cross-platform subdomain enumerator
6. **sublist3r** - Python subdomain enumeration tool

## Usage

### Single Domain
```bash
./subfinder.sh -d example.com
```

### Multiple Domains from File
```bash
./subfinder.sh -dL domains.txt
```

### Help
```bash
./subfinder.sh -h
```

## Options

- `-d <domain>`: Target a single domain
- `-dL <file>`: Process multiple domains from a file
- `-h, --help`: Show help message

## Requirements

The script uses these tools (install if missing):
- `dig` - DNS lookup utility
- `host` - DNS lookup utility  
- `curl` - For Certificate Transparency queries

### Installing Requirements on macOS
```bash
# dig and host are usually pre-installed
# For curl (if missing):
brew install curl
```

### Installing Requirements on Ubuntu/Debian
```bash
sudo apt update
sudo apt install dnsutils curl
```

## Output

Results are saved in the `results/` directory:
- `results/domain.com/dns_subdomains.txt` - DNS enumeration results
- `results/domain.com/crt_subdomains.txt` - Certificate Transparency results  
- `results/domain.com/bruteforce_subdomains.txt` - Brute force results
- `results/domain.com/all_subdomains.txt` - Combined deduplicated results

## Domain List Format

Create a text file with one domain per line:
```
example.com
google.com
github.com
# This is a comment - it will be ignored
```

## Extending the Tool

The script is designed to be easily extensible. You can add more subdomain finder tools by:

1. Creating new functions for different enumeration techniques
2. Adding them to the `process_domain()` function
3. Running them in parallel with `&` and `wait`

### Example: Adding a new tool
```bash
# New enumeration function
custom_enumeration() {
    local domain=$1
    local output_dir=$2
    local output_file="${output_dir}/custom_subdomains.txt"
    
    log "INFO" "Running custom enumeration for ${domain}"
    
    # Your enumeration logic here
    # Save results to $output_file
    
    local count=$(wc -l < "$output_file" 2>/dev/null || echo "0")
    log "INFO" "Custom enumeration completed. Found ${count} subdomains"
}

# Add to process_domain() function
custom_enumeration "$domain" "$output_dir" &
```

## Examples

### Basic usage
```bash
./subfinder.sh -d google.com
```

### Using domain list
```bash
./subfinder.sh -dL domains.txt
```

### Sample output
```
╔═══════════════════════════════════════════════════════════╗
║                    SUBFINDER v1.0                        ║
║              Subdomain Enumeration Tool                  ║
║                   By: Waseem                            ║
╚═══════════════════════════════════════════════════════════╝

[2025-09-28 10:30:15] [INFO] Starting subdomain enumeration for: google.com
[2025-09-28 10:30:15] [INFO] Starting DNS enumeration for google.com
[2025-09-28 10:30:15] [INFO] Checking Certificate Transparency logs for google.com
[2025-09-28 10:30:15] [INFO] Starting subdomain brute force for google.com
[2025-09-28 10:30:16] [SUCCESS] Found: www.google.com
[2025-09-28 10:30:17] [SUCCESS] Found: mail.google.com
...
[2025-09-28 10:30:45] [SUCCESS] Total unique subdomains found for google.com: 25

Results saved to: results/google.com/all_subdomains.txt
```

### Multiple Domains from File
```bash
./subfinder.sh -dL domains.txt
```

## Output

All results are automatically saved to `all_subdomains.txt` with duplicates removed and sorted.

## Installation Requirements

Make sure you have these tools installed:

```bash
# subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# subdominator  
pip install subdominator

# amass
go install -v github.com/owasp-amass/amass/v4/...@master

# assetfinder
go install github.com/tomnomnom/assetfinder@latest

# findomain
# Download from: https://github.com/Findomain/Findomain/releases

# sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
pip install -r Sublist3r/requirements.txt
```

## Contributing

Feel free to add more subdomain enumeration tools to make this script more comprehensive!
