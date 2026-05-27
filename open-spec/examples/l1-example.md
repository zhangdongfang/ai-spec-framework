# L1 Spec 完整示例

## 输入

用户需求：`"给用户列表页加一个按注册时间排序的功能"`

项目类型：Java/Spring

## AI 执行过程

### 1. 激活确认
```
[open-spec v3.1 | Java | rules:✅ | 涉及老代码:✅] 开始创建变更提案
```

### 2. Check
检测到涉及现有的用户列表接口 → 建议先跑 open-understand。
用户已有 code-map.md，确认可复用。

### 3. Assess
评估结果：改 2 个文件（UserController.java + UserService.java），无 DB 变更 → **L1 简单**

### 4. Research 摘要
> 现有代码出处：
> - `UserController.java:45` — `GET /api/users` 接口，当前支持 `page` 和 `size` 参数
> - `UserService.java:32` — `listUsers(int page, int size)` 方法，调用 `userDao.findAll(pageable)`
> - `UserDao.java:12` — 继承 `JpaRepository`，已支持 `Sort` 参数
> - 详见 code-map.md §3 调用链路
>
> 可复用模式：OrderController.java:67 已有按创建时间排序的实现，使用 `Sort.by(direction, field)` 模式

### 5. Converge
提问：排序方向默认升序还是降序？→ 用户选择：默认降序（最新注册的在前）
YAGNI 裁剪：多字段排序 → 延后

### 6. Draft — 第一段确认
**代码现状**：用户列表接口 `GET /api/users` 当前仅支持分页，不支持排序。UserDao 继承 JpaRepository 已具备 Sort 能力。
**功能点**：新增 `sortBy` 和 `sortDir` 两个可选查询参数
**业务规则**：sortBy 仅允许 `createdAt`（后续可扩展），sortDir 默认 `desc`

→ 用户确认 ✅

## 最终 spec.md 产出

```markdown
# 用户列表排序功能
> status: propose
> created: 2026-05-27
> complexity: L1 简单
> project_type: Java/Spring

## 1. 背景与目标
用户列表页需要按注册时间排序，方便运营查看最新注册用户。完成后 GET /api/users 支持 sortBy + sortDir 参数。

## 2. 变更上下文
- 变更涉及文件: UserController.java, UserService.java
- 为什么是这两个文件: Controller 加参数，Service 传递 Sort 到 DAO。DAO 层无需改动（JpaRepository 已支持 Sort）

## 3. 功能点
- [x] 功能 1：GET /api/users 新增可选参数 sortBy（默认 createdAt）和 sortDir（默认 desc）→ Service 构造 Sort 对象 → DAO 使用 Sort 查询 → 返回排序后的分页结果

## 4. 验收标准
- [ ] AC-01：GET /api/users?sortBy=createdAt&sortDir=desc 返回按注册时间降序的用户列表
- [ ] AC-02：GET /api/users（不传排序参数）默认按注册时间降序
- [ ] AC-03：sortBy 传入不支持的字段时返回 400

## 5. 影响范围
- 不影响: UserDao、用户创建/修改/删除接口、前端（前端可选择性使用新参数）
- 风险: 无。排序参数可选，不传时行为与旧接口一致

## 6. 业务可观测性
- 如何验证新功能正常: 对比新旧接口返回的用户列表顺序
- 回滚判断依据: 接口响应时间 > 500ms（排序带来性能退化）

## 7. 技术决策
| 决策 | 选择 | 原因 |
|------|------|------|
| 排序实现方式 | JpaRepository Sort 参数 | DAO 层已支持，无需额外代码 |

## 8. 确认记录（HARD-GATE）
- **确认时间**: 2026-05-27
- **确认人**: 用户
```
