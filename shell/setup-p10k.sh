#!/bin/bash

# Shell script to setup zsh with oh-my-zsh, powerlevel10k, and plugins
# Author: Setup script for Federico's zsh environment
# Date: 2026-01-27

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[ℹ]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux systems"
    exit 1
fi

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    print_info "zsh is not installed. Installing zsh..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    else
        print_error "Unable to detect package manager. Please install zsh manually."
        exit 1
    fi
    print_status "zsh installed"
else
    print_status "zsh is already installed"
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    print_info "git is not installed. Installing git..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    fi
    print_status "git installed"
fi

# Install oh-my-zsh
print_info "Installing oh-my-zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_info "oh-my-zsh is already installed, skipping..."
else
    # Download and install oh-my-zsh (non-interactive)
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_status "oh-my-zsh installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install powerlevel10k
print_info "Installing powerlevel10k..."
if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    print_info "powerlevel10k is already installed, updating..."
    git -C "$ZSH_CUSTOM/themes/powerlevel10k" pull
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    print_status "powerlevel10k installed"
fi

# Install zsh-syntax-highlighting
print_info "Installing zsh-syntax-highlighting..."
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_info "zsh-syntax-highlighting is already installed, updating..."
    git -C "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_status "zsh-syntax-highlighting installed"
fi

# Install zsh-autosuggestions
print_info "Installing zsh-autosuggestions..."
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_info "zsh-autosuggestions is already installed, updating..."
    git -C "$ZSH_CUSTOM/plugins/zsh-autosuggestions" pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_status "zsh-autosuggestions installed"
fi

# Install fzf (dependency for fzf-tab)
print_info "Installing fzf..."
if [ -d "$HOME/.fzf" ]; then
    print_info "fzf is already installed, updating..."
    cd "$HOME/.fzf" && git pull && ./install --all --no-bash --no-fish
    cd - > /dev/null
else
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
    print_status "fzf installed"
fi

# Install fzf-tab
print_info "Installing fzf-tab..."
if [ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    print_info "fzf-tab is already installed, updating..."
    git -C "$ZSH_CUSTOM/plugins/fzf-tab" pull
else
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
    print_status "fzf-tab installed"
fi

# Update .zshrc with powerlevel10k theme
print_info "Configuring .zshrc..."
if [ -f "$HOME/.zshrc" ]; then
    # Backup original .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    print_status "Backed up existing .zshrc"
    
    # Update theme to powerlevel10k
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    
    # Update plugins line - simple single line replacement
    sed -i 's/^plugins=(.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)/' "$HOME/.zshrc"
    
    print_status ".zshrc configured with theme and plugins"
else
    print_error ".zshrc not found. This shouldn't happen after oh-my-zsh installation."
    exit 1
fi

# Add oh-my-zsh source line if missing
if ! grep -q "^source \$ZSH/oh-my-zsh.sh" "$HOME/.zshrc"; then
    # Find the line with plugins=() and add source after it
    sed -i '/^plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)/a\\nsource $ZSH/oh-my-zsh.sh' "$HOME/.zshrc"
    print_status "Added source line for oh-my-zsh"
fi

# Add fzf configuration if not already present
if ! grep -q "source ~/.fzf.zsh" "$HOME/.zshrc" && ! grep -q "\[ -f ~/.fzf.zsh \]" "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" >> "$HOME/.zshrc"
    print_status "Added fzf configuration to .zshrc"
fi

# Print completion message
echo ""
print_status "Installation complete!"
echo ""
print_info "Next steps:"
echo "  1. Change your default shell to zsh: chsh -s \$(which zsh)"
echo "  2. Log out and log back in (or restart your terminal)"
echo "  3. The powerlevel10k configuration wizard will start automatically"
echo "  4. If it doesn't start automatically, run: p10k configure"
echo ""
print_info "Your original .zshrc has been backed up"
echo ""

# Offer to change default shell
read -p "Would you like to change your default shell to zsh now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v chsh &> /dev/null; then
        chsh -s "$(which zsh)"
        print_status "Default shell changed to zsh"
        print_info "Please log out and log back in for the change to take effect"
    else
        print_error "chsh command not found. You'll need to change your shell manually"
    fi
fi

# Offer to start zsh now
echo ""
read -p "Would you like to start zsh now to run the powerlevel10k configuration? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Starting zsh... (type 'exit' to return to your previous shell)"
    exec zsh
fi