#!/bin/bash

# Exit on error
set -e

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y zsh curl git tmux xfce4-clipman xfconf

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

# Setup keybindings for Clipman and suspend if running Xfce
if [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]] || [[ "$DESKTOP_SESSION" == *"xfce"* ]]; then
    echo "[*] Xfce desktop detected. Setting keybindings..."

    # Remove existing bindings for Super+V and Super+L (if any)
    existing_v=$(xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>v" 2>/dev/null || echo "")
    if [[ -n "$existing_v" ]]; then
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>v" -r || true
        echo "  - Removed existing binding for Super+V"
    fi

    existing_l=$(xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" 2>/dev/null || echo "")
    if [[ -n "$existing_l" ]]; then
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -r || true
        echo "  - Removed existing binding for Super+L"
    fi

    # Bind Super+V to xfce4-clipman-history
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>v" -n -t string -s "xfce4-clipman-history" || echo "  ! Failed to bind Super+V"

    # Bind Super+L to systemctl suspend
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -n -t string -s "systemctl suspend" || echo "  ! Failed to bind Super+L"

    echo "[*] Keybindings set."
else
    echo "[*] Not running Xfce desktop. Skipping keybinding setup."
fi

exec zsh
echo "[*] Done, in tmux, press Prefix (Ctrl+A) then I to install plugins."

source ~/.zshrc
