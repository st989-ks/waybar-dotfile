#!/bin/bash

# Get default microphone source
DEFAULT_SOURCE=$(pactl get-default-source)

if [ -z "$DEFAULT_SOURCE" ]; then
  echo '{"text": "0"}'
  exit 0
fi

# Check if microphone is muted
IS_MUTED=$(pactl get-source-mute "$DEFAULT_SOURCE" | grep -oP 'Mute: \K\S+')

if [ "$IS_MUTED" = "yes" ]; then
  echo '{"text": "", "alt": "Выключен"}'
  exit 0
fi

# Get volume of default source (microphone) - extract percentage
VOLUME=$(pactl get-source-volume "$DEFAULT_SOURCE" | grep -oP 'front-left:.*?/\K[0-9]+(?=%)' | head -1)

if [ -z "$VOLUME" ]; then
  # Fallback parsing using awk
  VOLUME=$(pactl get-source-volume "$DEFAULT_SOURCE" | awk '/front-left:/ {print $5}' | sed 's/%//')
  if [ -n "$VOLUME" ] && [ "$VOLUME" != "0" ]; then
    echo "{\"text\": \"$VOLUME% \", \"alt\": \"Громкость: $VOLUME%\"}"
  else
    echo '{"text": "0", "alt": "Громкость: 0%"}'
  fi
else
  echo "{\"text\": \"$VOLUME% \", \"alt\": \"Громкость: $VOLUME%\"}"
fi
