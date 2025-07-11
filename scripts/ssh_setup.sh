#!/bin/bash

set -e

echo "[*] Switching 'main' repo remote from HTTPS to SSH..."
ORIG_DIR="$(pwd)"

if [[ -d "$HOME/main/.git" ]]; then
    cd "$HOME/main"
    git remote set-url origin git@github.com:Vzupa/main.git
    echo "[*] Remote URL updated to SSH:"
    git remote -v
    cd "$ORIG_DIR"
else
    echo "[!] Directory '$HOME/main' not found or not a Git repo — skipping SSH remote change."
fi


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
