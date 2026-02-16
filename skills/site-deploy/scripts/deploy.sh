#!/usr/bin/env bash
# Quick deploy: commit, push, and deploy to Vercel.
# Usage: deploy.sh [commit-message]
set -euo pipefail

MSG="${1:-Update site}"

echo "📦 Committing..." >&2
git add -A
git commit -m "$MSG" 2>&1 || echo "Nothing to commit" >&2

echo "⬆️  Pushing to GitHub..." >&2
git push 2>&1

echo "🚀 Deploying to Vercel..." >&2
npx vercel --prod --yes 2>&1 | tail -3

echo "✅ Done!" >&2
