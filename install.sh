#!/bin/bash
set -e

REPO_URL="https://mredward123.github.io/qshell-apt-repo/ubuntu"

echo "Installing QShell from GitHub APT repository..."

# Add GPG key
echo "Adding GPG key..."
wget -qO - $REPO_URL/qshell-repo.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/qshell.gpg

# Add repository
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null <<LIST_EOF
deb [arch=amd64] $REPO_URL stable main
LIST_EOF

# Update and install
echo "Updating package lists..."
sudo apt update

echo "Installing QShell..."
sudo apt install -y qshell

echo "Installation complete!"
echo "Run: qshell --version"
