#!/bin/bash

MONITOR="eDP-1"
TOUCH="elan2514:00-04f3:23e8"
STYLUS="elan2514:00-04f3:23e8-stylus"

monitor-sensor | while read -r line; do
  case "$line" in
    *"normal"*)
      hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,0"
      hyprctl keyword device:$TOUCH:transform 0
      hyprctl keyword device:$STYLUS:transform 0
      ;;
    *"left-up"*)
      hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,1"
      hyprctl keyword device:$TOUCH:transform 1
      hyprctl keyword device:$STYLUS:transform 1
      ;;
    *"right-up"*)
      hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,3"
      hyprctl keyword device:$TOUCH:transform 3
      hyprctl keyword device:$STYLUS:transform 3
      ;;
    *"bottom-up"*)
      hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,2"
      hyprctl keyword device:$TOUCH:transform 2
      hyprctl keyword device:$STYLUS:transform 2
      ;;
  esac
done

