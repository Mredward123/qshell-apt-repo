#!/bin/bash
set -e

REPO_URL="https://Mredward123.github.io/qshell-apt-repo/ubuntu"

echo "Installing QShell from GitHub APT repository..."

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 清理旧的 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/qshell.gpg

# 下载 GPG 密钥（从根目录）
echo "Adding GPG key..."
if ! curl -fsSL https://Mredward123.github.io/qshell-apt-repo/gpg.key -o qshell.asc; then
    echo "✗ Failed to download GPG key from GitHub Pages"
    # 备选方案：从 raw.githubusercontent.com 下载
    if ! curl -fsSL https://raw.githubusercontent.com/Mredward123/qshell-apt-repo/main/gpg.key -o qshell.asc; then
        echo "✗ All GPG key download methods failed"
        exit 1
    fi
fi

# 转换 GPG 密钥格式
if gpg --dearmor < qshell.asc > qshell.gpg 2>/dev/null; then
    sudo mv qshell.gpg /etc/apt/trusted.gpg.d/qshell.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/qshell.gpg
    echo "✓ GPG key added successfully"
else
    echo "✗ Failed to convert GPG key format"
    exit 1
fi

# 添加 APT 源（指向 ubuntu/ 子目录）
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null << SOURCE
deb [arch=amd64] $REPO_URL stable main
SOURCE

# 更新并安装
echo "Updating package lists..."
if sudo apt update; then
    echo "✓ Package lists updated successfully"
else
    echo "⚠️ apt update completed with warnings"
fi

echo "Installing qshell..."
if sudo apt install -y qshell; then
    echo "✓ QShell installed successfully!"
    echo "Run: qshell --version"
else
    echo "✗ Failed to install qshell"
    echo "Available packages:"
    apt-cache search qshell || echo "No qshell packages found"
fi

# 清理
cd /
rm -rf "$TEMP_DIR"
