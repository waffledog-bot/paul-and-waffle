#!/usr/bin/env bash
# Generate a voice memo via sag and output the file path.
# Usage: send-voice.sh "text to speak" [voice] [output-path]
set -euo pipefail

TEXT="${1:?Usage: send-voice.sh \"text\" [voice] [output-path]}"
VOICE="${2:-George}"
OUT="${3:-~/.openclaw/workspace/voice-memo-$(date +%s).mp3}"

sag -v "$VOICE" -o "$OUT" --play=false "$TEXT"
echo "$OUT"
