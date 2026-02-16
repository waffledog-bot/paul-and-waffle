---
name: voice-memo
description: Send voice memos to Paul via WhatsApp using ElevenLabs TTS. Use when asked to send a voice message, voice memo, voice note, or audio reply. Also use when a voice response would be more engaging than text (stories, summaries, dramatic readings).
---

# Voice Memo

Generate audio with sag (ElevenLabs TTS) and send as a WhatsApp voice note.

## Quick workflow

1. Generate audio to the workspace (never `/tmp/` — not in allowed media dirs):

```bash
bash scripts/send-voice.sh "Your message here" [voice] [output-path]
```

Default voice: `George` (Warm, Captivating Storyteller). Default output: `workspace/voice-memo-<timestamp>.mp3`.

2. Send via message tool:

```
message(action=send, channel=whatsapp, target=+1YOURPHONE, filePath=<output-path>, asVoice=true)
```

Include a short text caption — don't just send the file silently.

## Voice options

- **George** — Warm storyteller (default, great for summaries/recaps)
- **Roger** — Laid-back, casual
- **Charlie** — Deep, confident, energetic
- **Liam** — Energetic social media creator
- **Chris** — Charming, down-to-earth
- **Brian** — Deep, resonant, comforting

## ElevenLabs v3 audio tags

Add at the start of a line for expression:

`[whispers]`, `[shouts]`, `[sings]`, `[laughs]`, `[sighs]`, `[excited]`, `[sarcastic]`, `[curious]`, `[crying]`, `[mischievously]`

Use `[short pause]`, `[pause]`, `[long pause]` for timing.

## Tips

- Write the text conversationally — it's speech, not an essay.
- Keep voice memos under ~60 seconds for best engagement.
- For longer content, break into key points rather than reading walls of text.
- Always save to workspace dir (`~/.openclaw/workspace/`), never `/tmp/`.
