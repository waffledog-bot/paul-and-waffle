---
name: stem-split
description: Find a song on YouTube, download it, and split into stems (vocals, drums, bass, other) using Demucs. Use when asked to isolate vocals, remove vocals, make an instrumental, extract drums/bass, split stems, or get a karaoke version of a song. Also handles local audio files.
---

# Stem Split

Download audio from YouTube and separate into individual stems using Demucs (Meta's AI source separation).

## Quick workflow

### From YouTube URL

```bash
bash scripts/yt-stems.sh "<youtube-url>" [mode] [output-dir]
```

### From local file

```bash
demucs --two-stems vocals -n htdemucs --mp3 -o ~/.openclaw/workspace/stems "<file>"
```

## Modes

| Mode | Stems produced | Model | Best for |
|------|---------------|-------|----------|
| `2stems` | vocals, no_vocals (instrumental) | htdemucs | Karaoke, vocal isolation |
| `4stems` | vocals, drums, bass, other | htdemucs | General remixing |
| `5stems` | vocals, drums, bass, other, piano | htdemucs_ft | Detailed separation |

Default: `2stems` (fastest, most common request).

## Finding songs

Use `yt-dlp --print title --print webpage_url "ytsearch1:<song name>"` to find a song URL before downloading.

## Sending stems to Paul

After splitting, send the relevant stems via WhatsApp using the voice-memo skill or message tool:

```
message(action=send, channel=whatsapp, target=+1YOURPHONE, filePath=<stem-path>, message="Here's the vocal track 🎤")
```

For multiple stems, send each as a separate message with a label.

## Output location

All stems go to `~/.openclaw/workspace/stems/`. Each run creates a timestamped subfolder.

## Dependencies

- `yt-dlp` (brew) — YouTube download
- `demucs` (pipx, Python 3.11) — stem separation
- `ffmpeg` (brew) — audio conversion

## Notes

- First run downloads the model (~80MB). Subsequent runs are faster.
- Processing time: ~30-60s for a typical song on M-series Mac.
- Demucs runs on CPU by default (MPS/GPU optional but CPU is fine for single tracks).
