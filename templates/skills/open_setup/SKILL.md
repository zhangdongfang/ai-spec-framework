---
name: open_setup
description: "分析项目工程结构和编码风格，填充 rules/ 配置文件"
---

# open_setup — 初始化项目上下文

分析工程结构、依赖、分层模式、编码习惯，填充 `code_copilot/rules/` 下的配置文件。

## ⚡ 技能激活确认（必须执行）

你的第一条回复**必须完全输出**以下内容：

```
[open_setup v1.0] 分析项目工程结构和编码风格，填充 rules/ 配置文件
[加载] 构建文件: ✅/❌ · 项目目录: <路径>
```

输出此确认后，继续执行后续步骤。

## 执行步骤

### Step 1: 扫描项目

1. 读取构建文件（pom.xml / build.gradle / package.json / pyproject.toml / go.mod）
2. 执行 `tree -d -L 3` 了解目录结构
3. 扫描 5-10 个核心源码文件，识别：
   - 分层架构模式
   - 命名规范、异常处理风格、日志用法
   - 测试框架和风格、ORM / 数据访问方式、API 风格

### Step 2: 填充 rules/project-rules.md

- 应用概况、目录结构、分层架构、关键依赖
- 命名规范、异常处理模式、日志规范（基于实际代码）

### Step 3: 填充 rules/domain-rules.md（如有）

- 业务领域特定规则
- 安全红线（已有默认值，不修改）

### Step 4: 同步工具配置

rules 填充完成后，自动执行同步，将更新后的 rules 写入 AGENTS.md：

```bash
bash ai-spec-framework/install.sh --sync --tool=opencode
```

## 约束

- 所有结论基于实际代码，附带文件路径
- 反映项目"实际是怎么做的"，不生成理想化规范
- 无明确约定的标注"暂未统一，建议团队讨论"
- Step 4 必须执行，确保 AGENTS.md 与 rules 同步
- Step 4 必须执行，确保 AGENTS.md 与 rules 同步
- Step 4 必须执行，确保 AGENTS.md 与 rules 同步
- Step 4 必须执行，确保 AGENTS.md 与 rules 同步
