#!/usr/bin/env bash
# Generate a video clip via OpenAI Sora API.
# Usage: sora-video.sh <prompt> [seconds] [output-path] [size]
# Seconds: 4, 8, or 12. Size: 1280x720 (default landscape)
set -euo pipefail

PROMPT="${1:?Usage: sora-video.sh \"prompt\" [4|8|12] [output.mp4] [size]}"
SECONDS="${2:-8}"
OUTPUT="${3:-}"
SIZE="${4:-1280x720}"
API_KEY="${OPENAI_API_KEY:?OPENAI_API_KEY not set}"

TIMESTAMP=$(date +%s)
OUTPUT="${OUTPUT:-~/.openclaw/workspace/music/video-${TIMESTAMP}.mp4}"
mkdir -p "$(dirname "$OUTPUT")"

echo "🎬 Submitting video job..." >&2
JOB=$(curl -s -X POST "https://api.openai.com/v1/videos" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg p "$PROMPT" --arg s "$SECONDS" --arg sz "$SIZE" '{model:"sora-2", prompt:$p, seconds:$s, size:$sz}')")

JOB_ID=$(echo "$JOB" | jq -r '.id // empty')
if [[ -z "$JOB_ID" ]]; then
  echo "❌ Failed to create job:" >&2
  echo "$JOB" >&2
  exit 1
fi

echo "   Job ID: $JOB_ID" >&2
echo "   Polling for completion..." >&2

while true; do
  sleep 5
  STATUS_JSON=$(curl -s "https://api.openai.com/v1/videos/$JOB_ID" \
    -H "Authorization: Bearer $API_KEY")
  STATUS=$(echo "$STATUS_JSON" | jq -r '.status')
  PROGRESS=$(echo "$STATUS_JSON" | jq -r '.progress // 0')
  
  echo "   Status: $STATUS ($PROGRESS%)" >&2
  
  if [[ "$STATUS" == "completed" ]]; then
    break
  elif [[ "$STATUS" == "failed" ]]; then
    echo "❌ Generation failed:" >&2
    echo "$STATUS_JSON" | jq '.error' >&2
    exit 1
  fi
done

# Download the video
DOWNLOAD_URL=$(curl -s "https://api.openai.com/v1/videos/$JOB_ID/content" \
  -H "Authorization: Bearer $API_KEY" | jq -r '.url // empty')

if [[ -z "$DOWNLOAD_URL" ]]; then
  # Maybe the content endpoint returns binary directly
  curl -s "https://api.openai.com/v1/videos/$JOB_ID/content" \
    -H "Authorization: Bearer $API_KEY" \
    -o "$OUTPUT"
else
  curl -sL "$DOWNLOAD_URL" -o "$OUTPUT"
fi

echo "✅ Saved to: $OUTPUT" >&2
echo "$OUTPUT"
