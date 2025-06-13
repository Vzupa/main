#!/bin/bash

# Exit on error
set -e

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y zsh curl git tmux

echo "[*] Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo "[*] Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true

echo "[*] Updating .zshrc..."
sed -i '/^plugins=/d' ~/.zshrc
echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc

# Add tmux auto-start block if not present
if ! grep -q 'tmux attach-session' ~/.zshrc; then
    echo "[*] Adding tmux autostart block to .zshrc..."
    cat "$(dirname "$0")/tmux_autostart.zsh" >> ~/.zshrc
fi

echo "[*] Creating .tmux.conf..."
cp "$(dirname "$0")/tmux.config" ~/.tmux.conf

echo "[*] Installing TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

echo "[*] Reloading tmux config..."
tmux source-file ~/.tmux.conf || true

exec zsh
echo "[*] Done, in tmux, press Prefix (Ctrl+A) then I to install plugins."
