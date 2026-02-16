---
name: site-deploy
description: Deploy websites to Vercel and push to GitHub. Use when asked to deploy a site, publish a website, push to GitHub, or update a live site. Handles the full git commit → push → Vercel deploy flow.
---

# Site Deploy

Commit, push to GitHub, and deploy to Vercel in one flow.

## Quick deploy

```bash
cd <project-dir>
git add -A
git commit -m "<message>"
git push
npx vercel --prod --yes
```

## First-time setup

### GitHub repo
```bash
gh repo create <name> --public --source . --push --description "<desc>"
```

### Vercel (first deploy links the project)
```bash
npx vercel --yes
```

## Project structure

All website projects live in `~/.openclaw/workspace/projects/<name>/`. Each gets its own git repo.

## Pre-commit checklist

Before pushing, sanitize any skills or config included in the repo:
- Strip phone numbers, API keys, hardcoded user paths
- Replace with generic placeholders (`+1YOURPHONE`, `~/.openclaw/workspace`)
- Check with: `grep -r "paul\|15098\|sk-\|AIza" . --include="*.md" --include="*.sh"`

## Gotchas

- `vercel login` and `gh auth login` must be done manually (OAuth flows)
- Vercel free tier handles static sites fine, including media files
- Use `--prod` flag to deploy to the production URL (without it, creates a preview URL)
- Large media files (stems, videos) add up — the paul-and-waffle site is ~27MB
