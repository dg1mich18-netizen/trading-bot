#!/bin/bash
echo "=== TRADING BOT STATUS ==="
echo "📅 $(date)"
echo "🔒 Repo: $(curl -s https://github.com/dg1mich18-netizen/trading-bot | grep -o 'Public\|Private' | head -1)"
echo "📊 Branch: $(git branch --show-current)"
echo "🔄 Last commit: $(git log --oneline -1)"
echo "📁 Files: $(find . -name "*.py" | wc -l) Python files"
