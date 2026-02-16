#!/usr/bin/env bash
# Generate music via ElevenLabs Music API.
# Usage: music-gen.sh <prompt> [length_seconds] [output_path] [--instrumental] [--plan <json_file>]
set -euo pipefail

PROMPT=""
LENGTH=30
OUTPUT=""
INSTRUMENTAL=false
PLAN_FILE=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --instrumental|-i) INSTRUMENTAL=true; shift ;;
    --plan|-p) PLAN_FILE="$2"; shift 2 ;;
    --length|-l) LENGTH="$2"; shift 2 ;;
    --output|-o) OUTPUT="$2"; shift 2 ;;
    *) if [[ -z "$PROMPT" ]]; then PROMPT="$1"; else PROMPT="$PROMPT $1"; fi; shift ;;
  esac
done

TIMESTAMP=$(date +%s)
OUTPUT="${OUTPUT:-~/.openclaw/workspace/music/song-${TIMESTAMP}.mp3}"
mkdir -p "$(dirname "$OUTPUT")"

LENGTH_MS=$((LENGTH * 1000))
# Clamp
[[ $LENGTH_MS -lt 3000 ]] && LENGTH_MS=3000
[[ $LENGTH_MS -gt 600000 ]] && LENGTH_MS=600000

API_KEY="${ELEVENLABS_API_KEY:?ELEVENLABS_API_KEY not set}"

if [[ -n "$PLAN_FILE" ]]; then
  # Composition plan mode
  BODY=$(cat "$PLAN_FILE")
  echo "🎵 Generating from composition plan..." >&2
else
  # Simple prompt mode
  [[ -z "$PROMPT" ]] && { echo "Usage: music-gen.sh <prompt> [--length N] [--instrumental] [--output path]" >&2; exit 1; }
  
  if $INSTRUMENTAL; then
    BODY=$(jq -n --arg p "$PROMPT" --argjson l "$LENGTH_MS" '{prompt: $p, music_length_ms: $l, force_instrumental: true}')
  else
    BODY=$(jq -n --arg p "$PROMPT" --argjson l "$LENGTH_MS" '{prompt: $p, music_length_ms: $l}')
  fi
  echo "🎵 Generating: ${PROMPT:0:80}..." >&2
  echo "   Length: ${LENGTH}s | Instrumental: $INSTRUMENTAL" >&2
fi

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT" \
  -X POST "https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128" \
  -H "xi-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$BODY")

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "❌ API error (HTTP $HTTP_CODE):" >&2
  cat "$OUTPUT" >&2
  rm -f "$OUTPUT"
  exit 1
fi

echo "✅ Saved to: $OUTPUT" >&2
echo "$OUTPUT"
