#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "⚠️ curl is not installed."
    echo "📦 Installing curl..."
    sudo apt update && sudo apt install curl -y

    if ! command -v curl &> /dev/null; then
        echo "❌ Failed to install curl. Exiting."
        exit 1
    fi
fi

# Inform the user
echo "⏳ Please wait while testing your download and upload speeds..."

# Run speedtest and suppress warning messages
output=$(curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -W ignore - 2>/dev/null)

# Extract IP
ip=$(echo "$output" | grep "Testing from" | awk -F '[()]' '{print $2}')

# Extract Download speed
download=$(echo "$output" | grep "Download" | awk '{print $2, $3}')

# Extract Upload speed
upload=$(echo "$output" | grep "Upload" | awk '{print $2, $3}')

# Display result
echo ""
echo "IP: $ip"
echo "Download: $download"
echo "Upload: $upload"
