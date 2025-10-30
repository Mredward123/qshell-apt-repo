# QShell APT Repository

This repository contains the QShell package for Debian/Ubuntu systems.

## Installation

### Automated Installation
```bash
curl -sSL https://raw.githubusercontent.com/Mredward123/qshell-apt-repo/main/install.sh | bash
```

### Manual Installation
```bash
# 1. Add GPG key
wget -qO - https://mredward123.github.io/qshell-apt-repo/ubuntu/qshell-repo.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/qshell.gpg

# 2. Add repository
echo "deb [arch=amd64] https://mredward123.github.io/qshell-apt-repo/ubuntu stable main" | sudo tee /etc/apt/sources.list.d/qshell.list

# 3. Install QShell
sudo apt update
sudo apt install qshell
```

## Verification
```bash
qshell --version
```

## Support
For issues and questions, visit the main QShell repository.
