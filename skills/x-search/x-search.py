#!/usr/bin/env python3
"""
X/Twitter search and analysis tool powered by Grok + x_search.
Adapted from OpenUniverse (github.com/AnthonyRonning/openuniverse).

Commands:
  search <query> [--limit N]           Search tweets on any topic
  topic <query> --sides "A|B" [--limit N]  Topic analysis with side classification
  account <handle> --topics "t1,t2,t3" Account analysis across topics
  ask <handle> <question>              Freeform question about an account

Environment:
  XAI_API_KEY  - Required. xAI API key for Grok.
"""

import os
import sys
import json
import argparse
import re
from datetime import datetime

# ---------------------------------------------------------------------------
# xAI / Grok helpers
# ---------------------------------------------------------------------------

def get_client():
    from xai_sdk import Client
    api_key = os.environ.get("XAI_API_KEY")
    if not api_key:
        print("Error: XAI_API_KEY not set", file=sys.stderr)
        sys.exit(1)
    return Client(api_key=api_key)


def grok_chat(prompt: str, model: str = "grok-4-1-fast", handles: list = None):
    """Send a prompt to Grok with x_search enabled. Returns response text."""
    from xai_sdk.chat import user
    from xai_sdk.tools import x_search

    client = get_client()
    tool = x_search(allowed_x_handles=handles) if handles else x_search()
    chat = client.chat.create(model=model, tools=[tool])
    chat.append(user(prompt))
    response = chat.sample()
    return response.content if hasattr(response, "content") else str(response)


def extract_json(text: str) -> dict:
    """Try to extract JSON from a Grok response (may be wrapped in markdown)."""
    if "```json" in text:
        text = text.split("```json")[1].split("```")[0].strip()
    elif "```" in text:
        text = text.split("```")[1].split("```")[0].strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return None


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_search(args):
    """Search for tweets on a topic."""
    limit = args.limit or 10
    prompt = f"""Find the top {limit} most popular/viral tweets about: "{args.query}"

Return results as JSON:
{{
  "tweets": [
    {{
      "url": "https://x.com/username/status/...",
      "author": "@username",
      "text": "tweet text (first 280 chars)",
      "engagement": "likes/retweets summary"
    }}
  ]
}}

IMPORTANT: Every tweet MUST include its real x.com URL. Use x_search to find them. Focus on high engagement."""

    print(f"🔍 Searching X for: {args.query}", file=sys.stderr)
    raw = grok_chat(prompt)
    data = extract_json(raw)

    if data and "tweets" in data:
        # Markdown output
        print(f"# X Search: {args.query}\n")
        print(f"*{len(data['tweets'])} results · {datetime.now().strftime('%Y-%m-%d %H:%M')}*\n")
        for i, t in enumerate(data["tweets"], 1):
            print(f"**{i}. {t.get('author', '???')}**")
            print(f"> {t.get('text', '')}")
            print(f"📊 {t.get('engagement', '')} · [Link]({t.get('url', '')})\n")
    else:
        # Couldn't parse JSON — dump raw response as markdown
        print(f"# X Search: {args.query}\n")
        print(raw)


def cmd_topic(args):
    """Topic analysis with side classification."""
    sides = args.sides.split("|")
    if len(sides) != 2:
        print("Error: --sides must be 'SideA|SideB'", file=sys.stderr)
        sys.exit(1)

    side_a, side_b = sides[0].strip(), sides[1].strip()
    limit = args.limit or 10

    # Step 1: Find tweets
    search_prompt = f"""Find the top {limit} most popular/viral tweets about: "{args.query}"

Return as JSON:
{{
  "tweets": [
    {{
      "url": "https://x.com/username/status/...",
      "author": "@username",
      "text": "full tweet text",
      "engagement": "likes/retweets summary"
    }}
  ]
}}

IMPORTANT: Every tweet MUST include its real x.com URL. Use x_search. Focus on high-engagement tweets that express opinions."""

    print(f"🔍 Finding tweets about: {args.query}", file=sys.stderr)
    raw = grok_chat(search_prompt)
    tweets_data = extract_json(raw)

    if not tweets_data or "tweets" not in tweets_data:
        print(f"# Topic Analysis: {args.query}\n")
        print("Could not find tweets. Raw response:\n")
        print(raw)
        return

    tweets = tweets_data["tweets"]

    # Step 2: Classify
    tweets_text = "\n\n".join(
        f"Tweet {i+1} by {t.get('author','?')}:\n{t.get('text','')}"
        for i, t in enumerate(tweets)
    )

    classify_prompt = f"""Classify each tweet into one of two sides. Only use "neutral" if truly impossible to classify.

Side A = "{side_a}"
Side B = "{side_b}"

Tweets:
{tweets_text}

Return JSON:
{{
  "classifications": [
    {{"index": 1, "side": "a" or "b" or "neutral", "reason": "brief reason"}}
  ]
}}

Be decisive. Most tweets should clearly fall into side A or B."""

    print(f"📊 Classifying into: {side_a} vs {side_b}", file=sys.stderr)
    raw2 = grok_chat(classify_prompt)
    class_data = extract_json(raw2)

    classifications = {}
    if class_data and "classifications" in class_data:
        for c in class_data["classifications"]:
            classifications[c.get("index", 0)] = c

    # Markdown report
    print(f"# Topic Analysis: {args.query}\n")
    print(f"**{side_a}** vs **{side_b}** · {len(tweets)} tweets · {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")

    counts = {"a": 0, "b": 0, "neutral": 0}

    for i, t in enumerate(tweets, 1):
        c = classifications.get(i, {})
        side = c.get("side", "?")
        reason = c.get("reason", "")
        label = side_a if side == "a" else (side_b if side == "b" else "Neutral")
        counts[side] = counts.get(side, 0) + 1

        print(f"### {i}. {t.get('author', '?')} — *{label}*")
        print(f"> {t.get('text', '')}")
        print(f"*{reason}* · [Link]({t.get('url', '')})\n")

    print("---")
    print(f"## Summary")
    print(f"- **{side_a}**: {counts.get('a', 0)} tweets")
    print(f"- **{side_b}**: {counts.get('b', 0)} tweets")
    print(f"- **Neutral**: {counts.get('neutral', 0)} tweets")


def cmd_account(args):
    """Account analysis across topics."""
    handle = args.handle.lstrip("@")
    topics = [t.strip() for t in args.topics.split(",")]

    topic_list = "\n".join(f"- {t}" for t in topics)

    prompt = f"""Analyze the Twitter/X account @{handle} and determine their position on each topic:

{topic_list}

For each topic:
1. "active": true if they've discussed it, false otherwise
2. "position": brief description of their stance (max 1 sentence)
3. "examples": up to 3 REAL tweet URLs (https://x.com/username/status/ID) showing their position

IMPORTANT: Every claim must be backed by a real tweet URL. Use x_search to find relevant tweets.

Return JSON:
{{
  "account": "@{handle}",
  "topics": {{
    "Topic Name": {{
      "active": true/false,
      "position": "their stance",
      "examples": ["https://x.com/..."]
    }}
  }}
}}"""

    print(f"🔍 Analyzing @{handle} across {len(topics)} topics", file=sys.stderr)
    raw = grok_chat(prompt, handles=[handle])
    data = extract_json(raw)

    print(f"# Account Analysis: @{handle}\n")
    print(f"*{len(topics)} topics · {datetime.now().strftime('%Y-%m-%d %H:%M')}*\n")

    if data and "topics" in data:
        for topic, info in data["topics"].items():
            active = "✅" if info.get("active") else "❌"
            print(f"## {active} {topic}")
            print(f"{info.get('position', 'No data')}\n")
            examples = info.get("examples", [])
            if examples:
                for url in examples:
                    print(f"- [{url}]({url})")
                print()
    else:
        print(raw)


def cmd_ask(args):
    """Freeform question about an account."""
    handle = args.handle.lstrip("@")
    question = " ".join(args.question)

    prompt = f"""Answer this question about the Twitter/X account @{handle}:

"{question}"

CITATION RULES (mandatory):
- Use x_search to find relevant tweets
- EVERY claim must link to a specific tweet: [text](https://x.com/user/status/ID)
- Include at least one tweet URL per key point
- Format: markdown with inline links
- If you cannot find a source tweet, say so explicitly

Be concise and factual."""

    print(f"🔍 Asking about @{handle}: {question}", file=sys.stderr)
    raw = grok_chat(prompt, handles=[handle])

    print(f"# @{handle}: {question}\n")
    print(f"*{datetime.now().strftime('%Y-%m-%d %H:%M')}*\n")
    print(raw)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="X/Twitter search & analysis via Grok")
    sub = parser.add_subparsers(dest="command")

    # search
    p_search = sub.add_parser("search", help="Search tweets on a topic")
    p_search.add_argument("query", nargs="+")
    p_search.add_argument("--limit", type=int, default=10)

    # topic
    p_topic = sub.add_parser("topic", help="Topic analysis with side classification")
    p_topic.add_argument("query", nargs="+")
    p_topic.add_argument("--sides", required=True, help="'SideA|SideB'")
    p_topic.add_argument("--limit", type=int, default=10)

    # account
    p_acct = sub.add_parser("account", help="Analyze account across topics")
    p_acct.add_argument("handle")
    p_acct.add_argument("--topics", required=True, help="Comma-separated topics")

    # ask
    p_ask = sub.add_parser("ask", help="Freeform question about an account")
    p_ask.add_argument("handle")
    p_ask.add_argument("question", nargs="+")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Join query words
    if hasattr(args, "query"):
        args.query = " ".join(args.query)
    
    {"search": cmd_search, "topic": cmd_topic, "account": cmd_account, "ask": cmd_ask}[args.command](args)


if __name__ == "__main__":
    main()
