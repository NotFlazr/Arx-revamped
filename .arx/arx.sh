#!/bin/bash
# ARX Control Script
# Usage: arx [help|update|img <file>]

Option=$1
themedir=~/.arx/themes/
themelist=~/.arx/themes/themelist.txt
waydir=~/.arx/waybar/
# Supported wallpaper formats
SUPPORTED_FORMATS=("jpg" "jpeg" "png" "bmp" "gif")
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
    # Loop through all supported formats and return the first found wallpaper
    for ext in "${SUPPORTED_FORMATS[@]}"; do
        if [ -f "$themedir/$theme/wall.$ext" ]; then
            echo "$themedir/$theme/wall.$ext"
            return
        fi
    done
    echo "No valid wallpaper found for theme: $theme"
}

if [ -z "$Option" ]; then
  echo -e "\033[38;5;3m╔═══════════════════════════════════╗\033[0m"
  echo -e "\033[38;5;3m║\033[0m          \033[1;38;5;6mARX CONTROL\033[0m              \033[38;5;3m║\033[0m"
  echo -e "\033[38;5;3m╚═══════════════════════════════════╝\033[0m"
  echo -e "  \033[2;37mYour system, simplified.\033[0m"
  echo -e "  Run '\033[1;38;5;4marx help\033[0m' to get started."
elif [ "$Option" = "help" ]; then
  echo -e "\033[38;5;3mCommands:"
  echo -e " * update: Updates system and AUR"
  echo -e " * img <file>: Set wallpaper (supports images/videos)"
  echo -e " * theme : Applies manually curated theme(might require changing css files) also themes"
  echo -e " * themem : Applies themes using colors from matugen(might require changing css files)"
  elif [ "$Option" = "img" ]; then
  if [  -n "$2" ];then
    swww img "$2" --transition-type random --transition-step 30 --transition-fps 60
  fi
elif [ "$Option" = "update" ]; then
  sudo pacman -Syu
  yay -Syu
elif [ "$Option" = "themes" ]; then
  echo -e "\033[1;32m$(exa -D "$themedir")\033[0m"

elif [ "$Option" = "theme" ]; then
  theme=$(exa -D "$themedir" | rofi -dmenu -p "[Theme]" -theme ~/.config/rofi/theme.rasi)
  wallpaper=$(find_wallpaper "$theme")  # Find wallpaper with the correct format
  if [ -n "$wallpaper" ]; then
    swww img "$wallpaper" --transition-type random --transition-step 30 --transition-fps 60
    echo "$theme"
    cp "$themedir/$theme/hypr/colors.conf" ~/.config/hypr/colors.conf
    cp "$themedir/$theme/waybar/colors.css" ~/.config/waybar/colors.css
    cp "$themedir/$theme/mako/colors" ~/.config/mako/colors
    cp "$themedir/$theme/discord/theme.css" ~/.config/Vencord/themes/theme.css
    cp "$themedir/$theme/kitty/colors.conf" ~/.config/kitty/colors.conf && 
      $(rwaybar)
      pkill mako
    mako
pywal-discord
pkill waybar
waybar
    notify-send "Theme '$theme' applied!"
  else
    echo "No wallpaper found for theme '$theme'."
  fi
  elif [ "$Option" = "themem" ]; then
  theme=$(exa -D  "$themedir" | rofi -dmenu -p "[Theme]" -theme ~/.config/rofi/theme.rasi)
  wallpaper=$(find_wallpaper "$theme")  # Find wallpaper with the correct format
  if [ -n "$wallpaper" ]; then
  matugen image "$wallpaper"
  pkill nautilus
    notify-send "Theme '$theme' applied!"
  else
    echo "No wallpaper found for theme '$theme'."
  fi

elif [[ "$Option" = "wavey" ]]; then
waybars=$(exa -D  "$waydir" | rofi -dmenu -p "[Waybar]" -theme ~/.config/rofi/theme.rasi)
echo "Chosen your waybar '$waybars'"

  if [ -n "$waybars" ]; then
    $(replace_waybar)
    $(rwaybar)
    notify-send "Waybar changed! Now using '$waybars'"
  else
    notify-send "No files found for waybar theme '$theme'."
  fi
elif [ "$Option" = "themeset" ] && [ -z "$2" ]; then
  notify-send "No theme is selected. Run 'arx themes' to see available ones."
elif [ "$Option" = "themeset" ] && [ ! -z "$2" ]; then
  if grep -qx "$2" "$themelist"; then
    notify-send "Done"
  else
    notify-send "No theme named $2"
  fi
fi

