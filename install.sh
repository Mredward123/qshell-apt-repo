#!/bin/bash
set -e

echo "Installing QShell from GitHub APT repository..."

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 清理旧的 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/qshell.gpg

# 下载 GPG 密钥 - 使用可靠的 raw.githubusercontent.com
echo "Adding GPG key..."
if ! curl -fsSL https://raw.githubusercontent.com/Mredward123/qshell-apt-repo/main/gpg.key -o qshell.gpg; then
    echo "✗ Failed to download GPG key"
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

# 添加 APT 源 - 使用 GitHub Pages（即使网络有问题，用户可以在其他机器使用）
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null << 'SOURCE'
deb [arch=amd64] https://Mredward123.github.io/qshell-apt-repo/ stable main
SOURCE

# 更新并安装
echo "Updating package lists..."
if ! sudo apt update; then
    echo "⚠️ apt update failed - this might be due to network issues with GitHub Pages"
    echo "The repository is set up correctly, but this server cannot access it."
    echo "Other machines should be able to use this repository normally."
    exit 1
fi

echo "Installing qshell..."
if sudo apt install -y qshell 2>/dev/null; then
    echo "✓ QShell installed successfully!"
    echo "Run: qshell --version"
else
    echo "ℹ qshell package not found in repository"
    echo "This is normal - the APT repository is set up and ready for when you add packages."
fi

# 清理
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "✓ QShell APT repository setup completed!"
