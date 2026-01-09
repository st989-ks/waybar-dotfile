#!/bin/bash

# Get player info
INFO=$(playerctl -a metadata --format '{{playerName}}|{{status}}|{{artist}}|{{title}}' 2>/dev/null | head -1)

if [ -z "$INFO" ]; then
  echo '{"text": "", "tooltip": "", "alt": "stopped", "class": "stopped"}'
  exit 0
fi

# Parse player info
IFS='|' read -r PLAYER STATUS ARTIST TITLE <<< "$INFO"

# Determine player icon
case "$PLAYER" in
  vlc)
    ICON=""
    ;;
  firefox)
    ICON="🦊"
    ;;
  *)
    ICON="🎶"
    ;;
esac

# Determine status icon and text
case "$STATUS" in
  Playing)
    STATUS_ICON="▶️"
    STATUS_TEXT="PLAY"
    ALT="playing"
    ;;
  Paused)
    STATUS_ICON="⏸️"
    STATUS_TEXT="PAUSE"
    ALT="paused"
    ;;
  Stopped)
    STATUS_ICON="⏹️"
    STATUS_TEXT="STOP"
    ALT="stopped"
    ;;
  *)
    STATUS_ICON=""
    STATUS_TEXT=""
    ALT="unknown"
    ;;
esac

# Build text with icon and status
if [ -n "$STATUS_TEXT" ]; then
  # Text with underline and italic
  TEXT="$ICON $STATUS_TEXT $STATUS_ICON"
else
  TEXT="$ICON"
fi

# Build tooltip
TOOLTIP="$PLAYER: $ARTIST - $TITLE"

# Output JSON
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"alt\": \"$ALT\", \"class\": \"$PLAYER\"}"
