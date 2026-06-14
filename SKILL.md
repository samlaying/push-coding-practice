---
name: push-coding-practice
description: 把「我的 coding 实践」归档推送到三处存档（GitHub 公开仓库 + 飞书云文件夹 + 飞书多维表格索引）。当用户说"推送"、"同步到飞书/github"、"把实践归档推上去"、"更新飞书云文件夹"、"推一下 coding 实践"等任何涉及把本地 coding 实践内容同步出去的表达时，务必使用本技能。token 从本地 config.json 读取，绝不硬编码。
---

# push-coding-practice

把本地「我的 coding 实践」git 仓库的内容同步到三处存档。本地是源 of truth，向外推送。

## 三处存档

| 目标 | 方式 | 命令 |
|---|---|---|
| GitHub 公开仓库 | `git push`（仓库已配 origin） | `git -C <repo> push` |
| 飞书云文件夹 | 逐个内容文件 `drive +upload`（**只推内容 .md，跳过 .git/、CLAUDE.md、.gitignore**） | `lark-cli drive +upload --as user` |
| 飞书多维表格索引 | 新增/更新一行 | `lark-cli base +record-upsert --as user` |

## 配置（脱敏，关键）

token 全部存在本 skill 目录的 `config.json`（**gitignored，不入公开仓库**）。结构见同目录 `config.example.json`：

- `repo_local_path` — 本地仓库路径
- `github_remote` — GitHub 远程
- `content_root_files` — 推到飞书根文件夹的顶层文件（如 README.md、index.md）
- `feishu.root_folder_token` + `feishu.subfolders` — 飞书云文件夹及各子文件夹 token
- `bitable.base_token` + `bitable.table_id` — 检索用多维表格

> 真实 `config.json` 的安全副本在私密仓库 `samlaying/push-coding-practice-secrets`。
> 本地 `config.json` 缺失时，提示用户从私密仓库拷一份过来，不要凭记忆重填 token。

## 触发"推送"时的标准动作

1. **跑同步脚本**（自动完成 git push + 飞书云文件夹同步）：
   ```bash
   bash ~/.claude/skills/push-coding-practice/scripts/sync.sh
   ```
   脚本会：`git push` → 把 `content_root_files` 推到飞书根文件夹、各子文件夹里的 `.md` 推到对应子文件夹；已存在同名文件则**原地覆盖**（`--file-token`），没有则新建。

2. **多维表格加行**（仅当有新增分析文档时）：问用户要不要在索引表加一行，用 `lark-cli base +record-upsert`，字段：对象名 / 类型(竞品调研|github项目分析) / 标签 / 日期 / 结论(✅采用|⚠️备选|❌放弃) / 状态(待开始|进行中|已完成) / 文档链接。

3. **报告三处结果**：GitHub commit、飞书各文件 file_token、是否加了表格行。

## 重要约束（踩过的坑）

- 飞书侧存的是**原生 .md 文件**（不是渲染版 docx），可原地覆盖更新；想看渲染版得另走 docx 导入，本技能不用。
- `lark-cli drive +upload` 的 `--file` 必须是 **cwd 内相对路径**（绝对路径会被拒）。sync.sh 会自动 cd 到仓库父目录再跑，手动执行时同理。
- **不要用 `lark-drive +push` 整目录推**——它不识别 .gitignore，会把整个 `.git/` 几百个文件也推上去。永远走逐文件 `drive +upload`。
- 用户的飞书资源一律 `--as user`（云空间是个人资源，bot 看不到）。
- 多维表格 select 字段写入未知选项会自动新增选项；不想新增时先 `+field-list` 确认可选值。
