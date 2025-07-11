#!/bin/bash

# Exit on error
set -e

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y zsh curl git tmux xclip xfconf

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
    cat "$(dirname "$0")/static/tmux_autostart.zsh" >> ~/.zshrc
fi

echo "[*] Creating .tmux.conf..."
cp "$(dirname "$0")/static/tmux.config" ~/.tmux.conf

echo "[*] Installing TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

echo "[*] Reloading tmux config..."
tmux source-file ~/.tmux.conf || true


setup_git_and_ssh() {
    local email="$1"

    if [[ -z "$email" ]]; then
        echo "[-] Email not provided. Usage: setup_git_and_ssh <email>"
        return 1
    fi

    echo "[*] Configuring Git with email: $email..."
    git config --global user.name "Vzupa"
    git config --global user.email "$email"

    echo "[*] Git config set:"
    git --no-pager config --global --list

    local ssh_key_path="$HOME/.ssh/id_rsa_github"

    if [[ -f "$ssh_key_path" ]]; then
        echo "[!] SSH key already exists at $ssh_key_path — skipping key generation."
    else
        echo "[*] Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""
    fi

    echo "[*] Starting SSH agent and adding key..."
    eval "$(ssh-agent -s)"
    ssh-add "$ssh_key_path"

    echo "[*] Copying public SSH key to clipboard..."
    xclip -selection clipboard < "${ssh_key_path}.pub"

echo '[*] Adding SSH agent startup lines to .zshrc...'
{
        echo ''
        echo '# Start SSH agent and add default key'
        echo 'eval "$(ssh-agent -s)"'
        echo "ssh-add $ssh_key_path"
} >> ~/.zshrc

    echo "[*] Public key copied to clipboard. You can now paste it into GitHub or other services:"
    cat "${ssh_key_path}.pub"
}

setup_git_and_ssh "$1"

echo "[*] Done, in tmux, press Prefix (Ctrl+A) then I to install plugins."
