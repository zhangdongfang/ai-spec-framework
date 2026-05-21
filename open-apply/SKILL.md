---
name: open-apply
description: "按 tasks.md 逐步执行编码 — 零偏差，Verification 铁律"
args: "变更名"
---

# open-apply — 按 Spec 执行编码

Plan 是合同，AI 是打印机。

## ⚡ 技能激活确认（必须执行）

你的第一条回复**必须完全输出**以下内容（将 `<变更名>` 替换为实际值）：

```
[open-apply v1.0] 按 tasks.md 逐步执行编码 — 零偏差，Verification 铁律
[加载] 变更: <变更名> · spec.md: ✅/❌ · 分支: <分支名> · master/main: ✅/❌
```

输出此确认后，继续执行后续步骤。

## 前置检查

1. 找到 `changes/<变更名>/` 目录
2. 确认 spec.md 已通过 HARD-GATE
3. 确认无 `[待澄清]` 项
4. 检查当前 Git 分支 — 禁止在 master/main 上编码

## 自由度: 零

零偏差原则。遇到以下情况立即停车:
- 需要修改 spec 中未列出的文件
- 实际与设计不一致
- 发现技术障碍
- 需要引入未预期的依赖

停车后执行 Reverse Sync: 更新 spec.md → 记录 log.md → 等用户确认 → 继续。

## 执行模式

- **逐步**（默认）: 完成一个 task → 报告 → 等确认
- **批量**: 用户说"全部完成"→ 按顺序执行所有
- **紧急停车**: 逻辑冲突或 spec 缺失 → 立即停止

## 每个 Task 的步骤

1. 报告: "开始执行 Task-N: {描述}"
2. 按 spec 实现代码
3. **Verification 铁律**: 展示编译/测试输出
4. 在 tasks.md 中标记完成
5. 检查知识发现 → 写入 log.md
6. Git commit: `[<变更名>] <中文简述>`
7. 报告完成

## Verification 铁律

每个 task 完成后**必须展示可验证的证据**。
**禁止**: "应该没问题"、"代码看起来正确"等无证据声明。
验证不通过时不得继续下一个任务。

## 完成

所有 task 完毕后:
1. 填写 tasks.md 底部的"完成"部分
2. 输出执行摘要
3. 提示: 执行 `skill open-review <变更名>` 进入审查
