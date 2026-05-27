# AI Spec Framework — AI 辅助编码工作流

## 一句话

把 AI 编码从"黑箱生成"变成**可理解 → 可规划 → 可审查 → 可追溯**的结构化流程。

---

## 工作流总览

```
          ┌── 新功能 ──┐
需求 ──→  ├── 老功能 ──┤──→ ├──→ open-spec ──→ open-apply ──→ open-review ──→ open-archive
          └── Bugfix ──┘     ↑                     ↑  ↖  ↑         ↓
                           open-setup            open-understand  修正循环   ai-work/knowledge/
                                                      │
                                                    code-map.md
```

### 各 Skill 职责

| Skill | 什么时候用 | 产出 | 一句话 |
|-------|-----------|------|--------|
| **open-setup** | 新项目首次使用 | `ai-work/rules/` + `ai-work/AGENTS.md` | 扫描项目结构和编码风格，初始化上下文 |
| **open-understand** | 改老功能前 | `code-map.md` | 深度分析老代码，产出模块地图/调用链/影响雷达 |
| **open-spec** | 每次变更前 | `ai-work/changes/<name>/spec.md + tasks.md + log.md` | 把需求转成结构化变更文档 |
| **open-apply** | Spec 确认后 | 实际代码 | 按 task 逐步编码，有偏差自动提案不硬来 |
| **open-review** | 编码完成后 | 审查报告 | AI 幻觉检查 → Spec 合规 → 代码质量 |
| **open-debug** | 出 Bug 时 | 根因分析 + 修复 | 系统化调试，根因是 spec 问题就回溯 |
| **open-archive** | Review 通过后 | 归档 + 知识沉淀 | 归档变更，提取知识到 ai-work/knowledge/ |

---

## 完整使用流程

### 从 0 开始一个新项目

```
1. skill open-setup
   → 自动检测项目类型（Java/Python/Frontend/Go/Node.js/Rust）
   → 扫描目录结构 + 代码风格 → 生成 ai-work/rules/ + ai-work/AGENTS.md

2. 提需求
   skill open-spec "我要加一个用户积分功能"
   → 检测到是新功能，跳过 code-map.md
   → 复杂度评估 → 选择模板 → Research → 提问收敛 → Draft → Output → HARD-GATE
   → 确认后进入 open-apply

3. 编码
   skill open-apply <变更名>
   → 输出变更预览（改什么不改什么）
   → 逐 Task 执行 + Verification 铁律
   → 遇到偏差自动提案（3 个方案）→ 用户确认后同步更新 spec

4. 审查
   skill open-review <变更名>
   → Stage 0: AI 幻觉检查（幻影 import/API/依赖/配置/类型/过度实现）
   → Stage 1: Spec 合规性
   → Stage 2: 代码质量
   → 修正循环 → 最终报告

5. 归档
   skill open-archive <变更名>
   → 知识提取 → 归档到 ai-work/archives/ → 更新 ai-work/knowledge/
```

### 改老功能

```
1. 先理解老代码
   skill open-understand "用户登录模块"
   → 产出 code-map.md（模块地图 + 调用链 + 影响雷达 + 变更耦合 + 测试契约）

2. 再规划变更
   skill open-spec "修改用户登录逻辑"
   → 自动读取 code-map.md → 引用调用链/影响雷达
   → ... 后续流程同上
```

### 修 Bug

```
1. skill open-debug "用户登录后偶现 500"
   → Phase 1: 根因调查 → 定位代码 → 追踪调用链 → 收集证据
   → 根因分类: 编码错误 / Spec 缺陷 / 外部依赖
   → Phase 2-3: 方案对比 → 验证 → Phase 4: 修复
   → 如果根因是 Spec 缺陷: 建议回到 open-spec 更新
```

### 极简模式（L0：1 个文件改 1 个点）

```
skill open-spec "修复用户名的 NPE"
→ 评为 L0 → 跳过 Check/Converge → 直接 Draft + Output
→ 3 个章节的 L0 模板 → 确认 → open-apply
```

---

## 核心设计原则

### 1. Diff Preview（防 AI 改错方向）

编码前先声明"我要改什么、不改什么"，用户确认后再动手。

### 2. 偏差自动提案（取代零偏差停车）

AI 遇到意想不到的情况时，**不直接停，而是出 3 个方案**让用户选，选完后自动更新 spec。

### 3. AI 幻觉检查（Stage 0）

审查的第一步不是看 spec，而是跑编译 + 静态分析，专门抓 AI 常见的 7 种幻觉。

### 4. Verification 铁律

每个 task 完成后必须展示可验证的证据（编译输出/测试结果），禁止"应该没问题"。

### 5. 代码地图（code-map.md）

改老功能前先产出独立的代码理解文档，作为 spec 的输入。避免 AI 在不理解上下文的情况下瞎改。

### 6. 业务可观测性

每次变更必须定义"怎么知道新功能跑对了、和老功能比怎么样"——量化对比而非凭感觉。

### 7. 根因回溯

debug 发现是 spec 问题时不绕路，明确回到 open-spec 更新。

---

## 评价

### 优势

| # | 优势 | 说明 |
|---|------|------|
| 1 | **闭环完整** | 从项目初始化到归档，覆盖整个开发生命周期，没有断裂 |
| 2 | **多语言原生** | 7 种项目类型（Java/Python/Frontend/Go/Node.js/Rust/通用）各有一套层名、术语、构建命令 |
| 3 | **防幻觉机制** | Stage 0 幻觉检查 + Verification 铁律 + Diff Preview，三层防护 AI 常见错误 |
| 4 | **渐变复杂度** | L0（1 文件极简）→ L3（跨模块复杂变更），按需选路径，不杀鸡用牛刀 |
| 5 | **知识飞轮** | 每次变更的踩坑和发现都沉淀到 ai-work/knowledge/，越用越聪明 |
| 6 | **可观测设计** | spec 强制定义业务指标和对比策略，避免"改完了但不知道对不对" |
| 7 | **偏差友好** | 不预设 AI 能完美执行，遇到意外有标准提案流程，不是简单停车 |

### 劣势

| # | 劣势 | 说明 |
|---|------|------|
| 1 | **流程较重** | 即使 L0 也需要走 3 个 skill（spec→apply→review），习惯"直接改"的开发者会觉得繁琐 |
| 2 | **文档维护成本** | spec/tasks/log/tasks 等多份文档需要同步更新，自动同步能力有限 |
| 3 | **知识沉淀依赖 AI 质量** | ai-work/knowledge/ 的质量取决于 AI 是否能识别和提炼有价值的知识，不一定每次都准 |
| 4 | **团队落地门槛** | 需要整个团队统一使用这套流程，新人需要学习 7 个 skill 的用途和顺序 |
| 5 | **没有 CI 集成** | 当前流程都是人工触发，没有自动化的 CI 门禁（比如自动跑 review） |
| 6 | **审查仍然依赖人** | Stage 0 和 1 可以自动跑，但最终代码质量审查还是需要人来看 |
| 7 | **跨语言一致性** | 虽然每个语言有对应模板，但对小众/混合项目（如 Flutter、.NET）覆盖不足 |

### 适合的场景

- **中等复杂度功能**（L1-L3）：改 2-20 个文件，需要多人 review 的变更
- **新成员加入**：不熟悉代码库，需要 code-map.md 快速上手
- **多人协作项目**：需要规范的变更记录和知识沉淀
- **高变更频率模块**：反复修改的老功能，code-map.md 可复用

### 不适合的场景

- **紧急修复**（线上 P0）：等不了流程，直接改代码
- **极度简单的项目**（如只有一个文件的脚本）：全套流程是负担
- **单人副业项目**：不需要这么多文档和审查
