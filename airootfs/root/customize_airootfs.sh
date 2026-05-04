#!/bin/bash
set -e

# ==============================================================================
# Kaynxx Custom Arch Linux - ISO Customization Script
# ==============================================================================

# Initialize pacman keys inside the ISO
pacman-key --init
pacman-key --populate archlinux

# Add chaotic-aur key
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

# Set root password (1111)
echo "root:1111" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Create kaynxx user
useradd -m -G wheel,audio,video,optical,storage,input -s /bin/zsh kaynxx
echo "kaynxx:1111" | chpasswd

# ==============================================================================
# Create Hyprland configs
# ==============================================================================
CONF_DIR="/home/kaynxx/.config"
mkdir -p "$CONF_DIR/hypr"

cat > "$CONF_DIR/hypr/hyprland.conf" << 'HYPREOF'
# Kaynxx - Hyprland Config

monitor=,preferred,auto,1

exec-once = waybar
exec-once = swaybg -i /usr/share/backgrounds/archlinux/simple.png -m fill
exec-once = mako
exec-once = /usr/lib/polkit-kde-authentication-agent-1

input {
    kb_layout = tr
    follow_mouse = 1
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(cba6f7ff) rgba(89b4faff) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 5
        passes = 2
    }
    shadow {
        enabled = true
        range = 8
        render_power = 3
        color = rgba(1a1a1aee)
    }
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 5, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

misc {
    force_default_wallpaper = 0
}

# Keybinds
$mainMod = SUPER

bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,

bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Volume & Brightness
bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

# Screenshot
bind = , Print, exec, grim ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png
bind = $mainMod, Print, exec, grim -g "$(slurp)" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png

# Logout
bind = $mainMod SHIFT, E, exec, wlogout
HYPREOF

# ==============================================================================
# Waybar config
# ==============================================================================
mkdir -p "$CONF_DIR/waybar"

cat > "$CONF_DIR/waybar/config.jsonc" << 'WAYEOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces", "hyprland/mode"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray"],
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "󰈹", "2": "", "3": "󰙳", "4": "󰝚", "5": "󰉌",
            "default": ""
        }
    },
    "clock": {
        "format": "{:%H:%M  %d/%m/%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "battery": {
        "states": {"warning": 30, "critical": 15},
        "format": "{capacity}% {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "󰈀 {ipaddr}",
        "format-disconnected": "󰌙 Disconnected"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "󰝟",
        "format-icons": {"default": ["󰕿", "󰖀", "󰕾"]}
    },
    "tray": {"spacing": 8}
}
WAYEOF

cat > "$CONF_DIR/waybar/style.css" << 'CSSEOF'
* { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; }
window#waybar { background: rgba(26,27,38,0.9); color: #cdd6f4; border-bottom: 3px solid rgba(203,166,247,0.5); }
#workspaces button { padding: 0 8px; color: #6c7086; }
#workspaces button.active { color: #cba6f7; border-bottom: 2px solid #cba6f7; }
#clock { color: #89b4fa; }
#battery { color: #a6e3a1; }
#network { color: #89dceb; }
#pulseaudio { color: #f38ba8; }
.modules-left, .modules-center, .modules-right { margin: 2px 8px; }
CSSEOF

# ==============================================================================
# Kitty terminal config
# ==============================================================================
mkdir -p "$CONF_DIR/kitty"
cat > "$CONF_DIR/kitty/kitty.conf" << 'KITTYEOF'
font_family      JetBrainsMono Nerd Font
font_size        12.0
cursor_shape     beam
cursor_blink_interval 0
background_opacity 0.9
background #1e1e2e
foreground #cdd6f4
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #cba6f7
color6  #89dceb
color7  #bac2de
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #cba6f7
color14 #89dceb
color15 #a6adc8
KITTYEOF

# ==============================================================================
# Mako notification config
# ==============================================================================
mkdir -p "$CONF_DIR/mako"
cat > "$CONF_DIR/mako/config" << 'MAKOEOF'
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#cba6f7
border-radius=10
border-size=2
font=JetBrainsMono Nerd Font 11
width=350
height=150
margin=10
padding=10
MAKOEOF

# ==============================================================================
# Starship prompt
# ==============================================================================
cat > "$CONF_DIR/starship.toml" << 'STAREOF'
format = """$os$username$directory$git_branch$git_status$cmd_duration$line_break$character"""
[os]
disabled = false
[os.symbols]
Arch = " "
[username]
style_user = "bold purple"
style_root = "bold red"
format = "[$user]($style) "
show_always = true
[directory]
style = "bold blue"
truncation_length = 3
[git_branch]
style = "bold green"
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
STAREOF

# ==============================================================================
# ZSH config
# ==============================================================================
cat > "/home/kaynxx/.zshrc" << 'ZSHEOF'
# Kaynxx ZSH Config
export ZDOTDIR="$HOME"
export PATH="$HOME/.local/bin:$PATH"

# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias pacin='sudo pacman -S'
alias pacup='sudo pacman -Syu'
alias pacre='sudo pacman -R'
alias yay='paru'
alias cls='clear'

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Auto cd
setopt AUTO_CD
ZSHEOF

# Fix ownership
chown -R kaynxx:kaynxx /home/kaynxx

# Copy configs to /etc/skel for any future users
cp -r /home/kaynxx/.config /etc/skel/.config
cp /home/kaynxx/.zshrc /etc/skel/.zshrc

# ==============================================================================
# Enable services
# ==============================================================================
systemctl enable sddm.service
systemctl enable NetworkManager.service

# SDDM autologin for live session
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=kaynxx
Session=hyprland
EOF

# Create Pictures directory
mkdir -p /home/kaynxx/Pictures
chown kaynxx:kaynxx /home/kaynxx/Pictures

echo "==> Customization complete!"
