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

| 依赖 | 用途 | 安装方式 |
|---|---|---|
| **git** | 向 GitHub 推送 | `brew install git` / 系统自带 |
| **bash** | 运行同步脚本 | 系统自带 |
| **jq** | 解析 JSON 配置 | `brew install jq` |
| **lark-cli** | 飞书 OpenAPI 交互（上传文件、操作多维表格） | `npx lark-cli` 或官网安装 |
| **Claude Code**（或兼容 skill 的 agent） | 触发 skill 执行 | Claude Code CLI |

配置要求：

- `git` 远程仓库（origin）须已配置，当前用户有推送权限
- `lark-cli` 须已登录（`lark-cli auth login`），且拥有对应云文件夹和 base 的访问权限
- 本地仓库路径必须在 `config.json` 的 `repo_local_path` 中正确指向，且已是一个 git 仓库

## 安全性

- 真实 token 仅存在于本地 `config.json` 和私密备份仓库
- 公开仓库只提交 `config.example.json`（占位符模板）
- `config.json` 在 `.gitignore` 中，不会被误提交

## 踩过的坑

见 [SKILL.md](SKILL.md) 中「重要约束」章节。
