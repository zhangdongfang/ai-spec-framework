---
name: open-review
description: "两阶段审查 — Spec 合规 + 代码质量 + 修正循环 + 测试建议"
args: "变更名"
---

# open-review — 两阶段审查 + 修正循环

不信报告，只信代码。

## ⚡ 技能激活确认（必须执行）

你的第一条回复**必须完全输出**以下内容（将 `<变更名>` 替换为实际值）：

```
[open-review v1.0] 两阶段审查 — Spec 合规 + 代码质量 + 修正循环 + 测试建议
[加载] 变更: <变更名> · tasks.md 完成状态: ✅/❌ · rules/: ✅/❌
```

输出此确认后，继续执行后续步骤。

## 前置

1. 找到 `changes/<变更名>/`
2. 确认 tasks.md 中所有 task 已完成
3. 读取 rules/ 作为审查基线

## Stage 1: Spec 合规性（spec-reviewer）

参考 `agents/spec-reviewer.md`。逐条比对:

1. 所有功能点是否已实现（标注代码位置）
2. 验收标准是否满足
3. Delta 变更是否全部落地
4. 是否有 YAGNI 违规

**FAIL → 进入修正循环（见下方）**

## Stage 2: 代码质量（code-quality-reviewer）

参考 `agents/code-quality-reviewer.md`。按严重程度分级:

- Critical（阻塞）/ Important（应修复）/ Minor（建议）

**存在 Critical → 进入修正循环**

## 修正循环

发现问题时:

1. 列出所有问题，按 Critical → Important → Minor 排序
2. 逐条修复，每条修复后:
   - 展示验证结果（编译/测试输出）
   - 同步更新 spec.md + tasks.md + log.md（文档同步铁律）
   - Git commit: `[<变更名>] fix: <修正描述>`
3. 修复完成后重新执行 Stage 1 + Stage 2

用户可说"先不修 Minor"跳过建议级问题。

## 测试建议

审查完成后，基于变更内容给出测试建议:

- 哪些路径需要补充单测
- 边界条件和异常场景
- 如用户要求"写测试"，按 Red/Green TDD 执行

## 最终报告

- 全部 PASS → 提交 PR 进入人工审查，提示 `skill open-archive <变更名>`
- 存在问题 → 修正后重新审查
