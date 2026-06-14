# push-coding-practice

**Claude Code skill - 本地内容三端同步方案**

一键将本地仓库的内容同步到三处存档：GitHub 公开仓库 + 飞书云文件夹 + 飞书多维表格索引。

## 适用场景

任何需要把本地内容（笔记、文章、实践记录、知识库等）推送到多个归档位置的需求：

- 本地 git 仓库作为 source of truth
- GitHub 作为公开存档和版本管理
- 飞书云文件夹作为团队/个人可浏览的知识库
- 飞书多维表格作为检索索引

## 架构

```
本地 git 仓库 (source of truth)
    ├── git push → GitHub 公开仓库
    ├── drive +upload → 飞书云文件夹
    └── base +record-upsert → 飞书多维表格索引
```

所有 token 和路径配置集中在 `config.json`（gitignored），公开仓库只暴露 `config.example.json` 作为模板。

## 快速开始

1. 将本 skill 安装到 `~/.claude/skills/`
2. 复制 `config.example.json` 为 `config.json`，填入你的实际配置
3. 本地内容变更后，对 Claude 说"推送"即可触发三端同步

## 配置说明

| 配置项 | 说明 |
|---|---|
| `repo_local_path` | 本地 git 仓库路径 |
| `github_remote` | GitHub 远程仓库地址 |
| `content_root_files` | 推送到飞书根文件夹的顶层文件 |
| `feishu.*` | 飞书云文件夹及各子文件夹 token |
| `bitable.*` | 飞书多维表格的 base token 和 table id |

详细字段见 [`config.example.json`](config.example.json)。

## 前置依赖

- Claude Code（或兼容 Claude Code skill 的 agent）
- `lark-cli`（飞书 CLI，需登录且有 drive/base 权限）
- `git`（配置好 GitHub 远程仓库）

## 安全性

- 真实 token 仅存在于本地 `config.json` 和私密备份仓库
- 公开仓库只提交 `config.example.json`（占位符模板）
- `config.json` 在 `.gitignore` 中，不会被误提交

## 踩过的坑

见 [SKILL.md](SKILL.md) 中「重要约束」章节。
