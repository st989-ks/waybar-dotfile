#!/bin/bash
set -euo pipefail

CACHE="$HOME/.cache/waybar/waybar-media.json"
STATE="$HOME/.cache/waybar/waybar-media.state"
TS="$HOME/.cache/waybar/waybar-media.ts"
DIR="$(dirname "$CACHE")"

mkdir -p "$DIR"

# Если кеш есть — сразу отдаём (дёшево)
[ -s "$CACHE" ] && cat "$CACHE"

NOW=$(date +%s)
LAST=$(cat "$TS" 2>/dev/null || echo 0)

# НЕ чаще чем раз в 5 секунд
[ $((NOW - LAST)) -lt 5 ] && exit 0

echo "$NOW" > "$TS"

INFO="$(playerctl metadata --format '{{playerName}}|{{status}}|{{artist}}|{{title}}' 2>/dev/null || true)"

if [ -z "$INFO" ]; then
	JSON='{"text":"","alt":"stopped","class":"stopped"}'
	echo "$JSON" > "$CACHE"
	echo "$JSON"
	exit 0
fi

LAST_INFO="$(cat "$STATE" 2>/dev/null || true)"
[ "$INFO" = "$LAST_INFO" ] && exit 0

IFS='|' read -r PLAYER STATUS ARTIST TITLE <<< "$INFO"

case "$PLAYER" in
	vlc) ICON="" ;;
	firefox) ICON="🦊" ;;
	spotify) ICON="" ;;
	*) ICON="🎶" ;;
esac

case "$STATUS" in
	Playing) TEXT="$ICON ▶" ALT="playing" ;;
	Paused)  TEXT="$ICON ⏸" ALT="paused" ;;
	*)       TEXT="$ICON ⏹" ALT="stopped" ;;
esac

TOOLTIP="${ARTIST:+$ARTIST - }$TITLE"

JSON=$(printf '{"text":"%s","tooltip":"%s","alt":"%s","class":"%s"}' \
	"$TEXT" "$TOOLTIP" "$ALT" "$PLAYER")

echo "$JSON" > "$CACHE"
echo "$INFO" > "$STATE"
