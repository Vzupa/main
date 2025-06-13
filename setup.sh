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
cat << 'EOF' >> ~/.zshrc

# Auto start tmux
if which tmux >/dev/null && [ -z "$TMUX" ]; then
  tmux attach-session -t default || tmux new-session -s default
fi
EOF
fi

echo "[*] Creating .tmux.conf..."
cat << 'EOF' > ~/.tmux.conf
set-option -g default-shell /bin/zsh

set -g mouse on
setw -g mode-keys vi

unbind C-b
set -g prefix C-a
bind C-a send-prefix

unbind '"'
unbind %
bind | split-window -h
bind - split-window -v

bind-key -n PageUp copy-mode -u
bind-key -n PageDown send-keys -X page-down

# TPM and plugins
set -g @plugin 'tmux-plugins/tmux-yank'
run '~/.tmux/plugins/tpm/tpm'
EOF

echo "[*] Installing TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

echo "[*] Reloading tmux config..."
tmux source-file ~/.tmux.conf || true

exec zsh
echo "[*] Done, in tmux, press Prefix (Ctrl+A) then I to install plugins."
