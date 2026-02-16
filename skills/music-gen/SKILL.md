---
name: music-gen
description: Generate original music and songs using ElevenLabs Music API. Use when asked to create a song, make music, compose a track, generate a beat, write a jingle, or turn lyrics into a song. Also use when Paul sings/hums a melody and wants it turned into a full song — transcribe the audio first, then use the description and any lyrics as the prompt. Supports genre prompts, custom lyrics, instrumental tracks, and detailed composition plans with per-section control.
---

# Music Generation (ElevenLabs)

Generate original music from text prompts or detailed composition plans.

## Quick prompt mode

```bash
bash scripts/music-gen.sh "upbeat indie rock song about coding at 3am" --length 60
```

Options: `--length N` (seconds, 3-600), `--instrumental`, `--output path`

Output goes to `workspace/music/song-<timestamp>.mp3`.

## Composition plan mode

For full control over song structure, write a JSON plan and pass it:

```bash
bash scripts/music-gen.sh --plan /path/to/plan.json
```

### Plan JSON structure

```json
{
  "composition_plan": {
    "positive_global_styles": ["indie rock", "energetic", "electric guitar"],
    "negative_global_styles": ["heavy metal", "screaming"],
    "sections": [
      {
        "section_name": "Verse 1",
        "positive_local_styles": ["quiet", "building"],
        "negative_local_styles": ["loud"],
        "duration_ms": 20000,
        "lines": ["Walking through the neon glow", "Code on screens like falling snow"]
      },
      {
        "section_name": "Chorus",
        "positive_local_styles": ["loud", "anthemic", "full band"],
        "negative_local_styles": ["quiet"],
        "duration_ms": 15000,
        "lines": ["We build it up, we tear it down", "The signal rises from the ground"]
      }
    ]
  }
}
```

### Plan fields

- **positive_global_styles**: genres, instruments, moods for the whole song
- **negative_global_styles**: what to avoid
- **sections[].section_name**: Intro, Verse, Chorus, Bridge, Outro, etc.
- **sections[].positive/negative_local_styles**: per-section style overrides
- **sections[].duration_ms**: 3000-120000ms per section
- **sections[].lines**: lyrics (max 200 chars/line). Empty array `[]` for instrumental sections.

## Voice memo → song workflow

When Paul sends a voice memo singing/humming:

1. Transcribe the audio (whisper-api skill)
2. Identify: lyrics (what was sung), mood/genre (how it sounded), tempo
3. Use transcribed lyrics as `lines` in a composition plan
4. Describe the musical feel in `positive_global_styles`
5. Generate and send back

## Prompt tips

- Be specific about genre, instruments, mood, tempo
- Include era references: "90s grunge", "80s synthwave", "70s funk"
- Mention vocal style: "raspy male vocals", "ethereal female voice", "spoken word"
- For instrumentals: use `--instrumental` flag
- Avoid copyrighted artist/song names (API will reject them)
- Good: "melancholic piano ballad with strings, slow tempo, female vocals"
- Bad: "sound like Adele singing Rolling in the Deep"

## Sending results

Send via WhatsApp after generation:

```
message(action=send, channel=whatsapp, target=+1YOURPHONE, filePath=<path>, message="🎵 Here's your track!")
```

## Limits

- Length: 3s to 10 minutes per generation
- Section duration: 3s to 2 minutes each
- Lyrics: max 200 chars per line
- No audio input (reference melodies) — describe the feel instead
- No copyrighted material in prompts
