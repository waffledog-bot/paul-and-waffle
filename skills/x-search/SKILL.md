---
name: x-search
description: Search and analyze X/Twitter using Grok's x_search. Topic search, account analysis, side-by-side debate classification, and freeform questions.
---

# X Search

Search and analyze X/Twitter content using Grok + x_search. Adapted from [OpenUniverse](https://github.com/AnthonyRonning/openuniverse).

## Setup

Requires `XAI_API_KEY` environment variable (xAI API key).
Python package: `xai-sdk` (install via `pip3 install --break-system-packages xai-sdk`)

## Commands

```bash
SCRIPT="python3 $(dirname "$0")/x-search.py"
export XAI_API_KEY="..."

# Search tweets on any topic
$SCRIPT search "bitcoin etf" --limit 5

# Topic analysis with two-sided classification
$SCRIPT topic "AI regulation" --sides "Pro-regulation|Anti-regulation" --limit 10

# Analyze an account's positions across topics
$SCRIPT account @elonmusk --topics "AI,Bitcoin,Free speech,Mars"

# Ask anything about an account
$SCRIPT ask @jack "What does he think about Nostr?"
```

## Output

All output is markdown. Pipe to a file to save reports:
```bash
$SCRIPT account @jack --topics "Bitcoin,Nostr,Bluesky" > reports/jack-analysis.md
```

## How It Works

Uses xAI's Grok model with the built-in `x_search` tool, which can natively search X/Twitter content. No separate X API bearer token needed — just the xAI key.

- **Model**: Must use `grok-4-1-fast` (or grok-4 family). Only grok-4+ supports x_search server-side tools. grok-3-mini will error.
- **jq** is available for JSON wrangling in shell pipelines.

## Features

- **Topic Search**: Find top tweets on any subject with engagement metrics
- **Side Analysis**: Classify tweets into two sides of a debate (from OpenUniverse)
- **Account Analysis**: Map someone's positions across configurable topics with tweet evidence
- **Freeform Ask**: Natural language questions about any account
- **Markdown Reports**: All output as clean markdown, easy to save/share
- **Citations**: All output includes tweet URLs as markdown links. Every claim is sourced.

## Tips & Lessons Learned

### Don't restrict searches to "official" accounts
When investigating a topic (e.g. "why is bitcoin down?"), **don't use `account` mode on @bitcoin or @cryptocurrency**. These are low-signal news aggregator accounts. The real discourse happens across individual analysts, traders, and commentators. Use `search` or `ask` without restricting to a handle.

### The `ask` command is the most flexible
For complex research questions, `ask` with a detailed prompt is more effective than `topic`. You can ask it to find, classify, and tally tweets in a single call. The `topic` command's two-step flow (find → classify) can break if JSON parsing fails between steps.

### Blended prompts work best for investigations
A good research flow:
1. **Web search** (Brave) for news articles — get the facts and professional analysis
2. **X search** for the vibes — what's crypto Twitter actually saying?
3. **Ask with classification prompt** — have Grok find + classify tweets in one shot
4. Synthesize both into a narrative

### JSON parsing is fragile
Grok sometimes returns tweets in slightly different JSON formats or wraps them in markdown. The `extract_json()` helper handles most cases but isn't bulletproof. When the `topic` command fails to parse, the raw response usually still contains useful data.

### Citations are mandatory
All prompts enforce citation rules — every claim must link to a real tweet URL. The `ask` command is especially strict: it requires `[text](https://x.com/user/status/ID)` inline links for every key point. If Grok can't find a source, it must say so. When using output in your own analysis, preserve the links — don't strip them.

### Engagement matters
When asking Grok to find tweets, explicitly request "high engagement" or "most liked/retweeted." Otherwise it may return low-engagement noise. Adding "viral" or "popular" to prompts helps.

### Model selection
- `grok-4-1-fast`: Good balance of speed and quality. Default.
- Only grok-4 family supports `x_search`. Do NOT use grok-3-mini or other models.
