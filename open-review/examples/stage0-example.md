# Stage 0 幻觉检查报告示例

## 背景
变更名：用户列表排序功能
项目类型：Java/Spring
涉及文件：UserController.java, UserService.java

## AI 检查过程

### 🔴 幻影 import 检查
```bash
$ mvn compile
[INFO] BUILD SUCCESS
```
→ **PASS**：编译 0 错误

### 🔴 幻影 API 检查
```bash
# 检查 UserService 中调用的 findAll(Pageable, Sort) 是否存在
$ grep -n "findAll" src/main/java/com/example/dao/UserDao.java
12: // 继承 JpaRepository<User, Long>，findAll(Pageable) 由框架提供
```
AI 调用了 `userDao.findAll(PageRequest.of(page, size, sort))`。
PageRequest.of(int, int, Sort) 是 Spring Data 标准 API。
→ **PASS**：方法签名存在

### 🔴 幻影依赖 检查
```bash
$ grep "spring-boot-starter-data-jpa" pom.xml
<artifactId>spring-boot-starter-data-jpa</artifactId>
```
→ **PASS**：依赖已声明

### 🟡 幻影配置 检查
代码中未引用新配置项 → **PASS**：不适用

### 🟡 幻影类型/接口 检查
新增的 `SortDirection` 枚举：
```bash
$ grep -rn "enum SortDirection" src/
src/main/java/com/example/enums/SortDirection.java:3:public enum SortDirection {
```
→ **PASS**：类型存在

### 🟡 过度实现 检查
Spec 要求 2 个文件改动，实际：
- UserController.java ✅ 在 spec 范围内
- UserService.java ✅ 在 spec 范围内
- SortDirection.java ⚠️ **新增文件，spec 未提及**

→ **WARN**：新增了 spec 未列出的 SortDirection 枚举。建议确认是否需要更新 spec，或内联为字符串参数。

### 🟡 参数语义 检查
Spec 要求 sortDir 默认 `desc`：
```bash
$ grep -n "sortDir" src/main/java/com/example/controller/UserController.java
48: @RequestParam(defaultValue = "desc") String sortDir
```
→ **PASS**：默认值与 spec 一致

### 🟡 复制残留 检查
排序逻辑参考了 OrderController 的实现：
```bash
$ grep -n "createdAt\|orderDate" src/main/java/com/example/service/UserService.java
35: Sort sort = Sort.by(direction, "createdAt");
```
→ **PASS**：排序字段已从 `orderDate` 改为 `createdAt`，无残留

### 🟢 死代码 检查
```bash
$ mvn checkstyle:check
[INFO] BUILD SUCCESS
```
→ **PASS**：无 warning

## 最终报告

```
## AI 幻觉检查报告
### 🔴 必须修复
（无）
### 🟡 建议修复
- [WARN] 过度实现: 新增了 SortDirection.java，spec 未列出此文件
### 🟢 通过
- [PASS] 编译通过 0 错误
- [PASS] 所有 API 引用存在
- [PASS] 依赖已声明
- [PASS] 类型引用存在
- [PASS] 参数默认值与 spec 一致
- [PASS] 无复制残留
- [PASS] lint 0 warning
### 结论
PASS（1 个 🟡 建议修复项）
```
