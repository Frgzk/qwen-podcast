#!/bin/bash
# 播客推送脚本：将 podcast-site 目录推送到 GitHub Pages
# 用法：bash push.sh

set -e

PODCAST_DIR="/root/userdata/workspace/podcast-site"
TOKEN_FILE="$HOME/.config/github/token"

# 从云端记忆中恢复 token（如果本地不存在）
if [ ! -f "$TOKEN_FILE" ]; then
    echo "ERROR: GitHub token 未找到，请先写入 $TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

cd "$PODCAST_DIR"

# 初始化 git（如果尚未初始化）
if [ ! -d ".git" ]; then
    git init
    git config user.name "frgzk"
    git config user.email "frgzk@users.noreply.github.com"
    git remote add origin "https://frgzk:${TOKEN}@github.com/frgzk/qwen-podcast.git"
    git checkout -b gh-pages
fi

# 提交并推送
git add -A
if git diff --cached --quiet; then
    echo "无变更，跳过提交"
else
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
    git commit -m "播客更新 ${TIMESTAMP}"
    git push origin gh-pages --force
    echo "推送成功"
fi
