# 5 分钟快速上手

## 前提条件

- 已安装 AI 编码工具（Claude Code / OpenCode / Cursor 等）
- 项目使用 Git 管理

## 安装（一步完成）

```bash
# 将 install.sh 复制到项目中（或通过 PATH 全局可用）
cd /path/to/your-project
/path/to/ai-spec-framework/install.sh
```

脚本会自动创建 `code_copilot/` 目录（rules、skills、changes 模板等）。

## 初始化项目规范

打开你的 AI 编码工具，通过 skill 工具加载：

```
skill open_setup
```

AI 会自动扫描项目代码，填充 `code_copilot/rules/` 下的配置文件。填充完成后自动同步到 AGENTS.md。

## 按需生成工具配置

```bash
# 只生成你需要的工具配置
./install.sh --sync --tool=claude     # CLAUDE.md + .claude/
./install.sh --sync --tool=opencode   # AGENTS.md
./install.sh --sync --tool=cursor     # .cursor/rules/
./install.sh --sync --tool=copilot    # .github/copilot-instructions.md
./install.sh --sync --all-tools       # 全部生成
```

## 开始使用

### L1 简单任务（改 1-2 个文件）

```
skill open_spec 修改 UserController 的 getUser 接口，增加返回用户邮箱字段
```

AI 自动评估为 L1，使用轻量模板（~20 行）。

### L2 中等任务（改 3-8 个文件）

```
skill open_spec 为订单系统添加优惠券功能
```

AI 评估为 L2，使用标准模板（~50 行），执行 Research → 分段生成 Spec → HARD-GATE 确认。

### L3 复杂任务（8+ 文件或跨模块）

完整走 `skill open_spec` → `skill open_apply` → `skill open_review` → `skill open_archive` 流程。

## 可用 Skill

通过 `skill` 工具加载：

| Skill | 说明 |
|-------|------|
| `open_setup` | 分析项目，填充 rules/ |
| `open_spec` | 创建变更提案（自动评估复杂度） |
| `open_apply` | 按 Spec 逐步执行编码 |
| `open_review` | 两阶段审查 + 修正循环 + 测试建议 |
| `open_archive` | 归档 + 知识沉淀 |
| `open_debug` | 系统化调试流程 |

## 支持的 AI 工具

| 工具 | 生成配置 |
|------|----------|
| Claude Code | CLAUDE.md + .claude/rules/ + .claude/skills/ |
| OpenCode | AGENTS.md |
| Cursor | .cursor/rules/ |
| GitHub Copilot | .github/copilot-instructions.md |
