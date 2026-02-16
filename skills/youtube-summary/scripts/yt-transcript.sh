#!/usr/bin/env bash
# Extract YouTube transcript to a file.
# Usage: yt-transcript.sh <youtube-url> [output-file]
# Requires: summarize CLI (brew install steipete/tap/summarize)
set -euo pipefail

URL="${1:?Usage: yt-transcript.sh <youtube-url> [output-file]}"
OUT="${2:-/tmp/yt-transcript-$(date +%s).txt}"

summarize "$URL" --youtube auto --extract-only > "$OUT" 2>&1

LINES=$(wc -l < "$OUT")
WORDS=$(wc -w < "$OUT")
echo "Transcript saved: $OUT ($LINES lines, $WORDS words)"
