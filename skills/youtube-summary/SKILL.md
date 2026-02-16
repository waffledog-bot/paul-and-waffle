---
name: youtube-summary
description: Summarize or transcribe YouTube videos of any length. Use when asked to summarize, transcribe, or extract key points from a YouTube video or link. Handles long videos (1hr+) that crash other tools.
---

# YouTube Summary

Summarize YouTube videos reliably, even very long ones (1hr+).

## Why this exists

The `summarize` CLI crashes (OOM/SIGKILL) when asked to both extract AND summarize long transcripts in one shot. This skill splits the work: extract transcript via CLI, then summarize in-context.

## Workflow

1. Extract transcript to a file:

```bash
bash {baseDir}/scripts/yt-transcript.sh "YOUTUBE_URL" /tmp/yt-transcript.txt
```

2. Read the transcript file (use offset/limit for very large files).
3. Summarize in your own words based on user request (length, format, focus areas).

## Tips

- For videos under ~20 min, the transcript fits easily in context. Read it all and summarize.
- For videos over 1hr, the transcript may be 2000+ lines. Read in chunks (500-line batches) and build a running summary.
- Always mention key speakers/guests by name when identifiable.
- Match the summary style to what the user asks for (bullet points, paragraphs, detailed, brief, etc.).
