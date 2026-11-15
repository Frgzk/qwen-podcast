#!/bin/bash
# 播客推送脚本：将 podcast-site 目录推送到 GitHub Pages
# 用法：bash push.sh
#
# GitHub Pages 部署分支：gh-pages（必须推送到此分支才能更新站点）
# main 分支同步推送，保持两个分支始终一致。

set -e

PODCAST_DIR="/root/userdata/workspace/podcast-site"
TOKEN_FILE="$HOME/.config/github/token"

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
    git remote add origin "https://frgzk:${TOKEN}@github.com/Frgzk/qwen-podcast.git"
    git checkout -b gh-pages
fi

# 确保 remote URL 使用正确的用户名大小写
git remote set-url origin "https://frgzk:${TOKEN}@github.com/Frgzk/qwen-podcast.git"

# 提交
git add -A
if git diff --cached --quiet; then
    echo "无变更，跳过提交"
else
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
    git commit -m "播客更新 ${TIMESTAMP}"
fi

# 推送到 gh-pages（Pages 部署分支）和 main（镜像同步）
echo "推送到 gh-pages..."
git push origin gh-pages --force 2>&1

echo "同步推送到 main..."
# 将 gh-pages 的最新内容同步到 main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    git checkout main 2>/dev/null
    git merge gh-pages --ff-only 2>/dev/null || git merge gh-pages -m "sync from gh-pages"
    git push origin main --force 2>&1
    git checkout "$CURRENT_BRANCH"
else
    git push origin main --force 2>&1
fi

echo "推送完成：gh-pages 和 main 均已更新"
