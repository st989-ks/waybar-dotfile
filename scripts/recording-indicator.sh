#!/bin/bash

# Waybar module for wf-recorder indicator
# Checks if wf-recorder is running and shows recording status

if pgrep -x "wf-recorder" > /dev/null; then
    # Get recording duration from the most recent video file
    RECORD_DIR="$HOME/Images/videos"
    if [ -d "$RECORD_DIR" ]; then
        LATEST_VIDEO=$(ls -t "$RECORD_DIR"/record-*.mp4 2>/dev/null | head -1)
        if [ -n "$LATEST_VIDEO" ]; then
            DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$LATEST_VIDEO" 2>/dev/null | cut -d'.' -f1)
            if [ -n "$DURATION" ]; then
                MIN=$((DURATION / 60))
                SEC=$((DURATION % 60))
                printf '{"text": "REC ●", "tooltip": "Запись: %02d:%02d", "class": "recording"}' "$MIN" "$SEC"
            else
                printf '{"text": "REC ●", "tooltip": "Запись идёт", "class": "recording"}'
            fi
        else
            printf '{"text": "REC ●", "tooltip": "Запись идёт", "class": "recording"}'
        fi
    else
        printf '{"text": "REC ●", "tooltip": "Запись идёт", "class": "recording"}'
    fi
else
    # Not recording - show nothing
    printf '{"text": "", "tooltip": "", "class": ""}'
fi
