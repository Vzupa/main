#!/bin/bash

# Setup keybindings for Clipman and suspend if running Xfce
if [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]] || [[ "$DESKTOP_SESSION" == *"xfce"* ]]; then
    echo "[*] Xfce desktop detected. Setting keybindings..."

    # Ensure xfce4-clipman-plugin is started
    if ! pgrep -x "xfce4-clipman" > /dev/null; then
        echo " - Starting xfce4-clipman-plugin..."
        xfce4-clipman & # Run in background
    else
        echo " - xfce4-clipman-plugin is already running."
    fi

    # Set xfce4-clipman to start on login
    echo " - Setting xfce4-clipman to auto-start on login..."
    xfce4-session-settings --disable-startup-notify --add-program "xfce4-clipman" || echo " ! Failed to add xfce4-clipman to startup applications."

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
