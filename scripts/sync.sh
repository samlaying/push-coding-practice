#!/usr/bin/env bash
# push-coding-practice / sync.sh
# 把本地「我的 coding 实践」仓库同步到 GitHub + 飞书云文件夹。
# token 从本 skill 目录的 config.json 读取（gitignored），绝不硬编码。
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$SKILL_DIR/config.json"

if [ ! -f "$CONFIG" ]; then
  echo "✗ 缺少 $CONFIG" >&2
  echo "  从私密仓库 samlaying/push-coding-practice-secrets 拷一份 config.json 过来，" >&2
  echo "  或复制 config.example.json 后填真实 token。" >&2
  exit 1
fi

command -v jq >/dev/null || { echo "✗ 需要 jq" >&2; exit 1; }
command -v lark-cli >/dev/null || { echo "✗ 需要 lark-cli" >&2; exit 1; }

REPO=$(jq -r '.repo_local_path' "$CONFIG")
ROOT_TOKEN=$(jq -r '.feishu.root_folder_token' "$CONFIG")
GH_REMOTE=$(jq -r '.github_remote' "$CONFIG")

[ -d "$REPO/.git" ] || { echo "✗ $REPO 不是 git 仓库" >&2; exit 1; }

echo "==> [1/2] git push → GitHub ($GH_REMOTE)"
git -C "$REPO" push

echo "==> [2/2] 飞书云文件夹同步（原生 .md，已存在则原地覆盖）"
REPO_PARENT="$(dirname "$REPO")"
REPO_NAME="$(basename "$REPO")"
cd "$REPO_PARENT"

# 用法: upload_or_overwrite <repo内相对路径> <目标文件夹token>
upload_or_overwrite() {
  local rel="$1"
  local folder_token="$2"
  local file="$REPO_NAME/$rel"
  [ -f "$file" ] || return 0
  local name; name="$(basename "$rel")"
  local existing
  existing=$(lark-cli drive files list --as user \
    --params "{\"folder_token\":\"$folder_token\",\"page_size\":200}" \
    --format json 2>/dev/null \
    | jq -r --arg n "$name" '.data.files[]? | select(.name==$n) | .token' | head -1)
  if [ -n "$existing" ]; then
    echo "   ↻ overwrite  $rel"
    lark-cli drive +upload --as user --file "$file" --folder-token "$folder_token" \
      --file-token "$existing" --format json >/dev/null
  else
    echo "   + create     $rel"
    lark-cli drive +upload --as user --file "$file" --folder-token "$folder_token" \
      --format json >/dev/null
  fi
}

# 顶层内容文件 → 根文件夹
while IFS= read -r f; do
  [ -z "$f" ] && continue
  upload_or_overwrite "$f" "$ROOT_TOKEN"
done < <(jq -r '.content_root_files[]?' "$CONFIG")

# 各子文件夹里的 .md → 对应 token
while IFS=$'\t' read -r sub token; do
  [ -z "$sub" ] && continue
  for ff in "$REPO/$sub"/*.md; do
    [ -f "$ff" ] || continue
    upload_or_overwrite "$sub/$(basename "$ff")" "$token"
  done
done < <(jq -r '.feishu.subfolders | to_entries[] | "\(.key)\t\(.value)"' "$CONFIG")

echo "==> 完成。如需在多维表格加行，用 lark-cli base +record-upsert（见 SKILL.md）。"
