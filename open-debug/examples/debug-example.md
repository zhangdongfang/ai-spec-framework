# Debug 推理链示例

## 输入

用户描述：`"用户登录后偶现 500 错误，大概 10% 的请求会报错"`

## Phase 1: 根因调查

### 复现
- 频率：约 10% 请求
- 触发条件：已登录用户访问 `/api/users/me`
- 错误日志：`NullPointerException at UserService.java:47`

### 定位代码
```bash
$ grep -n "47" src/main/java/com/example/service/UserService.java
47:     return user.getProfile().getDisplayName();
```

### 追踪调用链
```
UserController.java:23 — GET /api/users/me
  → UserService.java:45 — getCurrentUser(Long userId)
    → UserDao.java:8 — findById(userId) → 返回 User 对象
    → UserService.java:47 — user.getProfile().getDisplayName()  ← NPE 在此
```

### 收集证据
- `user` 不为 null（findById 能找到用户）
- `user.getProfile()` 偶尔为 null → **10% 用户没有 Profile 记录**
- 数据库确认：新注册但未完善资料的用户没有 profile 行

### 初步假设
**根因**：`user.getProfile()` 在未完善资料的用户上返回 null，直接调用 `.getDisplayName()` 导致 NPE。

**分类**：编码错误（缺少 null 检查）→ 继续 Phase 2-4

## Phase 2: 模式分析

### 项目中类似场景
```bash
$ grep -rn "getProfile()" src/main/java/
service/UserService.java:47: return user.getProfile().getDisplayName();
service/OrderService.java:82: String name = Optional.ofNullable(user.getProfile())
                                              .map(Profile::getDisplayName)
                                              .orElse(user.getUsername());
```
→ OrderService.java:82 已有安全处理模式：使用 `Optional` + fallback 到 username

### 修复方案

| 方案 | 做法 | 优缺点 |
|------|------|--------|
| A（推荐） | 使用 Optional + fallback 到 username | 复用项目已有模式，用户始终看到名字 |
| B | 在 Service 层加 null 检查，返回空字符串 | 简单但用户可能看到空白 |

## Phase 3: 假设验证

选择方案 A。验证：
1. 修改 UserService.java:47 使用 Optional 模式
2. 单元测试：传入无 Profile 的 User → 返回 username（不抛异常）
3. 传入有 Profile 的 User → 返回 displayName（原有行为不变）

→ 验证通过

## Phase 4: 实施修复

```java
// UserService.java:47 修复
return Optional.ofNullable(user.getProfile())
    .map(Profile::getDisplayName)
    .orElse(user.getUsername());
```

```bash
$ mvn test -pl user-service
Tests run: 48, Failures: 0, Errors: 0
BUILD SUCCESS
```

```bash
$ git commit -m "fix: 修复未完善资料用户访问 /api/users/me 时的 NPE"
```

知识沉淀 → `ai-work/knowledge/user-profile-nullable.md`：
> Profile 关联可能为 null（新注册未完善资料），所有 `getProfile()` 调用需做 null 安全处理。项目惯例用 `Optional.ofNullable` + fallback。
