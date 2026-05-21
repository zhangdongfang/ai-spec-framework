# code_copilot

**Spec-Driven Development (SDD)** 框架 — 让 AI 编码工具按规范写代码。

核心理念：**No Spec, No Code**。AI 必须先理解需求规格，再按任务拆分逐步编码，每步可验证。

## 特性

- **轻量安装** — 一个脚本，只创建 `code_copilot/` 目录
- **三级 Spec 模板** — L1 轻量 / L2 标准 / L3 完整，自动评估复杂度
- **6 个 Skill** — open-setup, open-spec, open-apply, open-review, open-archive, open-debug（通过 skill 工具加载）
- **按需工具配置** — 用哪个 AI 工具就生成哪个配置
- **知识飞轮** — 踩坑和决策自动沉淀，越用越聪明

## 快速开始

```bash
# 安装到你的项目
cd /path/to/your-project
/path/to/ai-spec-framework/install.sh

# 按需生成工具配置
/path/to/ai-spec-framework/install.sh --sync --tool=opencode

# 在 AI 工具中通过 skill 工具加载
skill open-setup    # AI 扫描代码，填充 rules/
skill open-spec     # 创建变更提案（自动评估复杂度）
```

详见 [docs/quick-start.md](docs/quick-start.md)。

## 安装后生成的结构

```
your-project/
├── code_copilot/               # 框架目录（单一事实来源）
│   ├── rules/                  # 项目规则
│   ├── knowledge/              # 知识库
│   ├── agents/                 # Agent 提示词
│   ├── skills/                 # Skill 工作流
│   ├── changes/                # 进行中的变更
│   │   └── <change-name>/      # spec.md + tasks.md + log.md
│   └── archives/               # 已完成变更归档
│
├── CLAUDE.md                   # （可选）./install.sh --sync --tool=claude
├── AGENTS.md                   # （可选）./install.sh --sync --tool=opencode
├── .cursor/rules/              # （可选）./install.sh --sync --tool=cursor
└── .github/copilot-instructions.md  # （可选）./install.sh --sync --tool=copilot
```

## 工作流

```
skill open-spec    ──→  自动评估复杂度 → Research → 分段 Spec → HARD-GATE 确认
                                                │
skill open-apply   ──→  逐 Task 编码 → 验证铁律（必须展示证据）
                                                │
skill open-review  ──→  Stage 1: Spec 合规 → Stage 2: 代码质量 → 修正循环
                                                │
skill open-archive ──→  知识沉淀 → 移入 archives/
```

## 核心原则

| 原则 | 说明 |
|------|------|
| No Spec, No Code | L2+ 任务必须先写 Spec |
| 渐进式复杂度 | L1/L2/L3 自动匹配流程深度 |
| 验证铁律 | 每个 Task 必须展示编译/测试证据 |
| 反向同步 | 代码偏离 Spec 时，先改 Spec 再改代码 |
| 零自由度编码 | Apply 阶段严格按 tasks.md 执行 |
| HARD-GATE | Spec 完成后必须人工确认才能开始编码 |

## Spec 模板分级

| 级别 | 模板 | 适用场景 |
|------|------|----------|
| L1 | `spec-lite.md` | 改 1-2 个文件，单功能点 |
| L2 | `spec-standard.md` | 改 3-8 个文件，中等功能 |
| L3 | `spec-full.md` | 8+ 文件或跨模块，完整流程 |

## 可用 Skill

通过 `skill` 工具加载：

| Skill | 说明 |
|-------|------|
| `open-setup` | 分析项目，填充 rules/ |
| `open-spec` | 创建变更提案（自动评估复杂度） |
| `open-apply` | 按 Spec 逐步执行编码 |
| `open-review` | 两阶段审查 + 修正循环 + 测试建议 |
| `open-archive` | 归档 + 知识沉淀 |
| `open-debug` | 系统化调试流程 |

## 支持的 AI 工具

| 工具 | 生成配置 |
|------|----------|
| Claude Code | CLAUDE.md + .claude/rules/ + .claude/skills/ |
| OpenCode | AGENTS.md |
| Cursor | .cursor/rules/ |
| GitHub Copilot | .github/copilot-instructions.md |

## License

MIT
