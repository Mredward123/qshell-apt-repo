#!/bin/bash
set -e

echo "Installing QShell from GitHub APT repository..."

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 清理旧的 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/qshell.gpg

# 下载 GPG 密钥（使用大写）
echo "Adding GPG key..."
if ! curl -fsSL https://Mredward123.github.io/qshell-apt-repo/gpg.key -o qshell.gpg; then
    echo "✗ Failed to download GPG key from GitHub Pages"
    exit 1
fi

# 验证 GPG 密钥
if gpg --list-packets < qshell.gpg > /dev/null 2>&1; then
    sudo mv qshell.gpg /etc/apt/trusted.gpg.d/qshell.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/qshell.gpg
    echo "✓ GPG key added successfully"
else
    echo "✗ Invalid GPG key format"
    exit 1
fi

# 添加 APT 源（GitHub Pages 使用大写）
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null << 'SOURCE'
deb [arch=amd64] https://Mredward123.github.io/qshell-apt-repo/ stable main
SOURCE

# 更新并安装
echo "Updating package lists..."
sudo apt update

echo "Installing qshell..."
if sudo apt install -y qshell 2>/dev/null; then
    echo "✓ QShell installed successfully!"
    echo "Run: qshell --version"
else
    echo "ℹ qshell package not found in repository"
    echo "This is normal - the APT repository is set up and ready."
    echo "When you add .deb packages to pool/main/, they will be available for installation."
fi

# 清理
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "✓ QShell APT repository setup completed successfully!"
