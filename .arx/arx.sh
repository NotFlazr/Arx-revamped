#!/bin/bash
# ARX Control Script - MINIMAL REFINEMENT
# Only critical fixes, preserving original logic

Option=$1
themedir=~/.arx/themes/
themelist=~/.arx/themes/themelist.txt
waydir=~/.arx/waybar/

# Supported wallpaper formats
SUPPORTED_FORMATS=("jpg" "jpeg" "png" "bmp" "gif" "mp4")

rwaybar() {
    pkill waybar
    waybar &
}

replace_waybar() {
    cp ~/.arx/waybar/$waybars/config.jsonc ~/.config/waybar/config.jsonc
    cp ~/.arx/waybar/$waybars/style.css ~/.config/waybar/style.css
}

find_wallpaper() {
    theme="$1"
    skip_video_playback="$2"  # If set to "skip", don't start video playback
    
    # Loop through all supported formats and return the first found wallpaper
    for ext in "${SUPPORTED_FORMATS[@]}"; do
        if [ -f "$themedir/$theme/wall.$ext" ]; then
            wallpaper="$themedir/$theme/wall.$ext"
            echo "$wallpaper"
            
            # Always kill yin first (clean slate)
            pkill yin 2>/dev/null
            
            if [ "$ext" == "mp4" ]; then
                # Handle MP4 video wallpaper
                # Extract first frame and save as PNG
                ffmpeg -i "$wallpaper" -vframes 1 -q:v 2 "$themedir/$theme/wall_frame.png" -y 2>/dev/null
                
                # Set the extracted frame as wallpaper with swww (stays in bg)
                swww img "$themedir/$theme/wall_frame.png" --transition-type random --transition-step 30 --transition-fps 60
                
                # Small delay to let swww finish transition
                sleep 0.5
                
                # Only start video playback if not skipped
                if [ "$skip_video_playback" != "skip" ]; then
                    # Ensure yin cache directory exists
                    mkdir -p ~/.cache/yin
                    
                    # Kill any existing yin and restart fresh
                    pkill -9 yin 2>/dev/null
                    sleep 0.3
                    
                    # Start yin daemon
                    nohup yin > /dev/null 2>&1 &
                    # Give it time to initialize
                    sleep 1.5
                    
                    # Then control it with yinctl to play the video
                    yinctl --img "$wallpaper"
                fi
            else
                # Handle static image wallpaper (yin already killed above)
                swww img "$wallpaper" --transition-type random --transition-step 30 --transition-fps 60
            fi
            
            return 0
        fi
    done
    return 1
}

if [ -z "$Option" ]; then
    echo -e "\033[38;5;3m╔═══════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;3m║\033[0m \033[1;38;5;6mARX CONTROL\033[0m                    \033[38;5;3m║\033[0m"
    echo -e "\033[38;5;3m╚═══════════════════════════════════╝\033[0m"
    echo -e "  \033[2;37mYour system, simplified.\033[0m"
    echo -e "  Run '\033[1;38;5;4marx help\033[0m' to get started."

elif [ "$Option" = "help" ]; then
    echo -e "\033[38;5;3mCommands:\033[0m"
    echo -e "  * update: Updates system and AUR"
    echo -e "  * img : Set wallpaper (supports images/videos)"
    echo -e "  * theme: Applies manually curated theme (might require changing css files)"
    echo -e "  * themes: List available themes"
    echo -e "  * themem: Applies themes using colors from matugen (might require changing css files)"
    echo -e "  * wavey: Change waybar theme"
    echo -e "  * themeset : Set a specific theme"

elif [ "$Option" = "img" ]; then
    if [ -n "$2" ]; then
        # Check if it's an MP4 video
        if [[ "$2" == *.mp4 ]]; then
            # Extract first frame
            frame_path="/tmp/arx_frame.png"
            ffmpeg -i "$2" -vframes 1 -q:v 2 "$frame_path" -y 2>/dev/null
            
            # Set frame with swww
            swww img "$frame_path" --transition-type random --transition-step 30 --transition-fps 60
            
            # Wait for transition
            sleep 0.5
            
            # Ensure yin cache directory exists
            mkdir -p ~/.cache/yin
            
            # Kill any existing yin and restart fresh
            pkill -9 yin 2>/dev/null
            sleep 0.3
            
            # Start yin daemon
            nohup yin > /dev/null 2>&1 &
            # Give it time to initialize
            sleep 1.5
            
            # Control it to play the video
            yinctl --img "$2"
        else
            # Static image - kill yin and just set with swww
            pkill yin 2>/dev/null
            swww img "$2" --transition-type random --transition-step 30 --transition-fps 60
        fi
    fi

elif [ "$Option" = "update" ]; then
    sudo pacman -Syu
    yay -Syu

elif [ "$Option" = "themes" ]; then
    echo -e "\033[1;32m$(exa -D "$themedir")\033[0m"

elif [ "$Option" = "theme" ]; then
    theme=$(exa -D "$themedir" | rofi -dmenu -p "[Theme]" -theme ~/.config/rofi/theme.rasi)
    if [ -n "$theme" ]; then
        wallpaper=$(find_wallpaper "$theme")
        if [ $? -eq 0 ]; then
            echo "Applied theme: $theme with wallpaper: $wallpaper"
            cp "$themedir/$theme/hypr/colors.conf" ~/.config/hypr/colors.conf
            cp "$themedir/$theme/waybar/colors.css" ~/.config/waybar/colors.css
            cp "$themedir/$theme/mako/colors" ~/.config/mako/colors
            cp "$themedir/$theme/discord/theme.css" ~/.config/Vencord/themes/theme.css
            cp "$themedir/$theme/kitty/colors.conf" ~/.config/kitty/colors.conf
            rwaybar
            pkill mako
            mako &
            pywal-discord
            notify-send "Theme '$theme' applied!"
        else
            echo "No wallpaper found for theme '$theme'."
            notify-send "Error: No wallpaper found for theme '$theme'."
        fi
    fi

elif [ "$Option" = "themem" ]; then
    theme=$(exa -D "$themedir" | rofi -dmenu -p "[Theme]" -theme ~/.config/rofi/theme.rasi)
    if [ -n "$theme" ]; then
        # Skip video playback in find_wallpaper, we'll handle it here
        wallpaper=$(find_wallpaper "$theme" "skip")
        if [ $? -eq 0 ]; then
            # Check if it's an MP4, use the extracted frame instead
            if [[ "$wallpaper" == *.mp4 ]]; then
                echo "Using extracted frame for matugen (MP4 detected)"
                matugen image "$themedir/$theme/wall_frame.png"
                
                # Ensure yin cache directory exists
                mkdir -p ~/.cache/yin
                
                # Kill any existing yin and restart fresh
                pkill -9 yin 2>/dev/null
                sleep 0.3
                
                # Start yin daemon
                nohup yin > /dev/null 2>&1 &
                # Give it time to initialize
                sleep 1.5
                
                # Control it to play the video
                yinctl --img "$wallpaper"
            else
                matugen image "$wallpaper"
            fi
            pkill nautilus
            notify-send "Theme '$theme' applied with matugen!"
        else
            echo "No wallpaper found for theme '$theme'."
            notify-send "Error: No wallpaper found for theme '$theme'."
        fi
    fi

elif [ "$Option" = "wavey" ]; then
    waybars=$(exa -D "$waydir" | rofi -dmenu -p "[Waybar]" -theme ~/.config/rofi/theme.rasi)
    echo "Chosen your waybar '$waybars'"
    if [ -n "$waybars" ]; then
        replace_waybar
        rwaybar
        notify-send "Waybar changed! Now using '$waybars'"
    else
        notify-send "No files found for waybar theme."
    fi

elif [ "$Option" = "themeset" ] && [ -z "$2" ]; then
    notify-send "No theme is selected. Run 'arx themes' to see available ones."

elif [ "$Option" = "themeset" ] && [ -n "$2" ]; then
    if grep -qx "$2" "$themelist"; then
        # FIX: Actually apply the theme instead of just saying "Done"
        theme="$2"
        wallpaper=$(find_wallpaper "$theme")
        if [ $? -eq 0 ]; then
            echo "Applied theme: $theme with wallpaper: $wallpaper"
            cp "$themedir/$theme/hypr/colors.conf" ~/.config/hypr/colors.conf 2>/dev/null
            cp "$themedir/$theme/waybar/colors.css" ~/.config/waybar/colors.css 2>/dev/null
            cp "$themedir/$theme/mako/colors" ~/.config/mako/colors 2>/dev/null
            cp "$themedir/$theme/discord/theme.css" ~/.config/Vencord/themes/theme.css 2>/dev/null
            cp "$themedir/$theme/kitty/colors.conf" ~/.config/kitty/colors.conf 2>/dev/null
            rwaybar
            pkill mako
            mako &
            pywal-discord
            notify-send "Theme '$theme' applied!"
        else
            notify-send "Error: No wallpaper found for theme '$theme'."
        fi
    else
        notify-send "No theme named $2"
    fi
fi
