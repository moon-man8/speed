#!/bin/bash

# Function to check if user is root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Check if sudo exists
if ! command -v sudo &> /dev/null; then
    if is_root; then
        echo "⚠️ sudo command not found. Installing sudo..."
        apt update && apt install sudo -y
        if ! command -v sudo &> /dev/null; then
            echo "❌ Failed to install sudo. Exiting."
            exit 1
        fi
    else
        echo "❌ sudo command not found and user is not root. Please run as root or install sudo."
        exit 1
    fi
fi

# Check if curl is installed, if not install it using sudo
if ! command -v curl &> /dev/null; then
    echo "⚠️ curl is not installed."
    sudo apt update && sudo apt install curl -y
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
    echo "⚠️ Python not found. Attempting to install python3..."
    sudo apt update && sudo apt install python3 -y
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    else
        echo "❌ Failed to install python3. Please install Python manually."
        exit 1
    fi
fi

echo "⏳ Please wait while testing your download and upload speeds..."

# Run speedtest and suppress warning messages using the detected python interpreter
output=$(curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | $PYTHON_CMD -W ignore - 2>/dev/null)

# Extract IP
ip=$(echo "$output" | grep "Testing from" | awk -F '[()]' '{print $2}')

# Extract Download speed
download=$(echo "$output" | grep "Download" | awk '{print $2, $3}')

# Extract Upload speed
upload=$(echo "$output" | grep "Upload" | awk '{print $2, $3}')

echo ""
echo "IP: $ip"
echo "Download: $download"
echo "Upload: $upload"
