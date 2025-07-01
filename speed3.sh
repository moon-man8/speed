#!/bin/bash

is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Check if sudo exists
if ! command -v sudo &> /dev/null; then
    if is_root; then
        echo "⚠️ sudo command not found. Installing sudo..."
        apt update -qq >/dev/null 2>&1 && apt install -y sudo >/dev/null 2>&1
        if ! command -v sudo &> /dev/null; then
            echo "❌ Failed to install sudo. Exiting."
            exit 1
        fi
    else
        echo "❌ sudo command not found and user is not root. Please run as root or install sudo."
        exit 1
    fi
fi

# Check if curl is installed, if not install silently
if ! command -v curl &> /dev/null; then
    echo "⚠️ curl is not installed. Installing..."
    sudo apt update -qq >/dev/null 2>&1 && sudo apt install -y curl >/dev/null 2>&1
    if ! command -v curl &> /dev/null; then
        echo "❌ Failed to install curl. Exiting."
        exit 1
    fi
fi

# Detect python3 or python, prefer python3 if both exist
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "⚠️ Python not found. Installing python3..."
    sudo apt update -qq >/dev/null 2>&1 && sudo apt install -y python3 >/dev/null 2>&1
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    else
        echo "❌ Failed to install python3. Please install Python manually."
        exit 1
    fi
fi

echo "⏳ Please wait while testing your download and upload speeds..."

output=$(curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | $PYTHON_CMD -W ignore - 2>/dev/null)

ip=$(echo "$output" | grep "Testing from" | awk -F '[()]' '{print $2}')
download=$(echo "$output" | grep "Download" | awk '{print $2, $3}')
upload=$(echo "$output" | grep "Upload" | awk '{print $2, $3}')

echo ""
echo "IP: $ip"
echo "Download: $download"
echo "Upload: $upload"
