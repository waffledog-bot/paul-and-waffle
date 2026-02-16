#!/usr/bin/env bash
# Download a YouTube video's audio and split into stems via Demucs.
# Usage: yt-stems.sh <youtube-url> [mode] [output-dir]
#   mode: 2stems (default), 4stems, 5stems (maps to demucs models)
#   output-dir: where stems land (default: workspace/stems/)
set -euo pipefail

URL="${1:?Usage: yt-stems.sh <youtube-url> [2stems|4stems|5stems] [output-dir]}"
MODE="${2:-2stems}"
OUTDIR="${3:-~/.openclaw/workspace/stems}"
TMPDIR="$(mktemp -d)"

mkdir -p "$OUTDIR"

echo "⬇️  Downloading audio..."
yt-dlp -x --audio-format wav -o "$TMPDIR/track.%(ext)s" "$URL" 2>&1 | tail -3

# Map mode to demucs args
case "$MODE" in
  2stems) DEMUCS_ARGS="--two-stems vocals -n htdemucs" ;;
  4stems) DEMUCS_ARGS="-n htdemucs" ;;
  5stems) DEMUCS_ARGS="-n htdemucs_ft" ;;
  *) echo "Unknown mode: $MODE (use 2stems, 4stems, 5stems)"; exit 1 ;;
esac

echo "🎵 Splitting stems (mode: $MODE)..."
demucs $DEMUCS_ARGS --mp3 -o "$TMPDIR/out" "$TMPDIR/track.wav" 2>&1

# Move results to output dir with clean names
STEM_SRC=$(find "$TMPDIR/out" -mindepth 1 -maxdepth 1 -type d | head -1)
STEM_SRC=$(find "$STEM_SRC" -mindepth 1 -maxdepth 1 -type d | head -1)

TIMESTAMP=$(date +%s)
DEST="$OUTDIR/stems-$TIMESTAMP"
mkdir -p "$DEST"
cp "$STEM_SRC"/*.mp3 "$DEST/"

echo "✅ Stems saved to: $DEST"
ls -la "$DEST/"

# Cleanup
rm -rf "$TMPDIR"

echo "$DEST"
