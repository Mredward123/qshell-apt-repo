#!/bin/bash
set -e

echo "Installing QShell from GitHub APT repository..."

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 清理旧的 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/qshell.gpg

# 下载 GPG 密钥（只使用 raw.githubusercontent.com）
echo "Adding GPG key..."
if ! curl -fsSL https://raw.githubusercontent.com/Mredward123/qshell-apt-repo/main/gpg.key -o qshell.asc; then
    echo "✗ Failed to download GPG key"
    exit 1
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

# 添加 APT 源
echo "Adding APT repository..."
sudo tee /etc/apt/sources.list.d/qshell.list > /dev/null << 'SOURCE'
deb [arch=amd64] https://Mredward123.github.io/qshell-apt-repo/ubuntu stable main
SOURCE

# 更新并安装
echo "Updating package lists..."
sudo apt update

echo "Installing qshell..."
# 使用非交互模式安装，避免 needrestart 提示
sudo NEEDRESTART_MODE=a apt install -y qshell

if which qshell > /dev/null; then
    echo "✓ QShell installed successfully!"
    echo "Run: qshell --version"
else
    echo "✗ qshell installation failed or service restart required"
    echo "You may need to manually run: sudo needrestart"
fi

# 清理
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "Note: If system services need restarting, run: sudo needrestart"
