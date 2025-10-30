#!/bin/bash
set -e

REPO_URL="https://Mredward123.github.io/qshell-apt-repo"

echo "Installing QShell from GitHub APT repository..."

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 清理旧的 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/qshell.gpg

# 下载 GPG 密钥
echo "Adding GPG key..."
if ! wget -q $REPO_URL/gpg.key -O qshell.gpg; then
    echo "✗ Failed to download GPG key from $REPO_URL/gpg.key"
    exit 1
fi

# 验证并安装 GPG 密钥
if gpg --list-packets < qshell.gpg > /dev/null 2>&1; then
    sudo mv qshell.gpg /etc/apt/trusted.gpg.d/qshell.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/qshell.gpg
    echo "✓ GPG key added successfully"
else
    echo "✗ Invalid GPG key format"
    exit 1
fi

# 添加 APT 源
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null << LIST_EOF
deb [arch=amd64] $REPO_URL stable main
LIST_EOF

# 更新并安装
echo "Updating package lists..."
sudo apt update

echo "Installing QShell..."
if sudo apt install -y qshell 2>/dev/null; then
    echo "✓ QShell installed successfully!"
    echo "Run: qshell --version"
else
    echo "ℹ qshell package not found in repository"
    echo "This is normal if the package hasn't been built yet."
    echo "Available packages in the repository:"
    apt-cache search qshell || echo "No qshell packages found yet"
    echo ""
    echo "Repository structure:"
    curl -s $REPO_URL/dists/stable/Release 2>/dev/null || echo "Release file not found"
fi

# 清理
cd /
rm -rf "$TEMP_DIR"
