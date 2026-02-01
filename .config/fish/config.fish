## -------------------------------------------------
## Source CachyOS defaults
## -------------------------------------------------
source /usr/share/cachyos-fish-config/conf.d/done.fish


## -------------------------------------------------
## Greeting
## -------------------------------------------------
function fish_greeting
    fastfetch
end


## -------------------------------------------------
## Man pages
## -------------------------------------------------
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"


## -------------------------------------------------
## done notifications
## -------------------------------------------------
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## -------------------------------------------------
## Environment setup
## -------------------------------------------------
# Apply fish-compatible profile
if test -f ~/.fish_profile
    source ~/.fish_profile
end
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx QT_STYLE_OVERRIDE Fusion

## -------------------------------------------------
## PATH setup (clean + deduplicated)
## -------------------------------------------------
for dir in \
    /opt/zig \
    ~/.nimble/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/Applications/depot_tools
    if test -d $dir
        if not contains -- $dir $PATH
            set -p PATH $dir
        end
    end
end





## -------------------------------------------------
## Bang-bang (!! and !$)
## -------------------------------------------------
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end


## -------------------------------------------------
## Functions
## -------------------------------------------------
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (string trim -r -c / $argv[1])
        set to $argv[2]
        command cp -r $from $to
    else
        command cp $argv
    end
end


## -------------------------------------------------
## Aliases
## -------------------------------------------------

# eza listings
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.="eza -a | grep -e '^\.'"
alias arx="~/.arx/arx.sh"
# Package managers
alias pac="sudo pacman -S"
alias pacr="sudo pacman -Rns"
alias i="yay -S"
alias r="yay -Rns"
alias s="yay -Ss"
alias u="yay -Syu"
alias update="sudo pacman -Syu"

# System helpers
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias mirror="sudo cachyos-rate-mirrors"
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias hw='hwinfo --short'
alias jctl="journalctl -p 3 -xb"

# Pacman info
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias walls="cd ~/.config/walls"

# Grep / misc
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias tb='nc termbin.com 9999'

# Config shortcuts
alias hyprconf="nvim ~/.config/hypr/hyprland.conf"
alias wayconf="nvim ~/.config/waybar/config.jsonc"
alias waystyle="nvim ~/.config/waybar/style.css"
alias footconf="nvim ~/.config/foot/part2.ini"
alias fishrc="nvim ~/.config/fish/config.fish"

# Reload Fish
alias reload="source ~/.config/fish/config.fish"

