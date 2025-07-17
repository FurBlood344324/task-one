#!/bin/bash
# Extension installation script
# Works with all shells and systems

echo "Installing extensions..."

# Check if extensions.json exists
if [ ! -f ".vscode/extensions.json" ]; then
    echo "Error: .vscode/extensions.json not found"
    exit 1
fi

# Extract extension IDs using multiple fallback methods
extract_extensions() {
    # Method 1: Try awk (most portable)
    if command -v awk >/dev/null 2>&1; then
        awk -F'"' '/"[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+"/ {
            for(i=1;i<=NF;i++) {
                if($i ~ /^[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+$/) {
                    print $i
                }
            }
        }' .vscode/extensions.json
        return 0
    fi
    
    # Method 2: Try grep + sed (backup)
    if command -v grep >/dev/null 2>&1 && command -v sed >/dev/null 2>&1; then
        grep -o '"[^"]*\.[^"]*"' .vscode/extensions.json | sed 's/"//g'
        return 0
    fi
    
    # Method 3: Pure bash fallback
    while IFS= read -r line; do
        # Extract strings that look like extension IDs
        if [[ $line =~ \"([a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)\" ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    done < .vscode/extensions.json
}

# Install extensions
extension_count=0
extract_extensions | while read -r ext; do
    if [ -n "$ext" ]; then
        echo "Installing: $ext"
        if code --install-extension "$ext"; then
            echo "✓ Successfully installed: $ext"
        else
            echo "✗ Failed to install: $ext"
        fi
        extension_count=$((extension_count + 1))
    fi
done

echo "Extension installation completed!"
