---
name: open-setup
description: "分析项目工程结构和编码风格，填充 ai-work/rules/ 配置文件"
---

# open-setup — 初始化项目上下文

分析工程结构、依赖、分层模式、编码习惯，填充 `ai-work/rules/` 下的配置文件。所有 AI 产物统一放在 `ai-work/` 目录下。

## ⚡ 技能激活确认（必须执行）

你的第一条回复**必须完全输出**以下内容：

```
[open-setup v2.0] 分析项目工程结构和编码风格，填充 ai-work/rules/ 配置文件
[加载] 构建文件: ✅/❌ · 项目目录: <路径>
[检测] 项目类型: <Java / Python / Frontend / Go / Node.js / Other>
```

输出此确认后，继续执行后续步骤。

## 执行步骤

### Step 1: 扫描项目 + 语言检测

1. **检测构建文件**，判断项目语言/框架：

   | 构建文件特征 | 判定项目类型 | 典型框架 |
   |-------------|-------------|---------|
   | `pom.xml` / `build.gradle` / `build.gradle.kts` | **Java** | Spring Boot, Micronaut, Quarkus |
   | `pyproject.toml` / `requirements.txt` / `setup.py` / `Pipfile` | **Python** | FastAPI, Django, Flask |
   | `package.json` + `vite.config.*` / `next.config.*` / `nuxt.config.*` / `vue.config.*` | **Frontend** | React(Vite/Next), Vue(Vite/Nuxt) |
   | `go.mod` | **Go** | Gin, Echo, Fiber |
   | `package.json` + `tsconfig.json` + 无前端框架特征文件 | **Node.js** | Express, NestJS, Koa |
   | `Cargo.toml` | **Rust** | Axum, Actix, Rocket |
   | 其他 | **Other** | 通用规则 |

2. 读取构建文件获取项目名、版本、依赖信息
3. 执行 `tree -d -L 3` 了解目录结构
4. 扫描 5-10 个核心源码文件，识别：
   - 分层架构模式 / 组件组织方式
   - 命名规范、异常处理风格、日志用法
   - 测试框架和风格、数据访问方式、API 风格
   - 特有约定（ORM、状态管理、CSS 方案、类型系统等）

### Step 2: 创建工作目录

在项目根目录创建以下目录（如已存在则跳过）：

```
ai-work/rules/        ← 存放 project-rules.md + domain-rules.md
ai-work/changes/      ← 存放每次变更的 spec.md + tasks.md + log.md
ai-work/archives/     ← 存放已完成变更的归档
ai-work/knowledge/    ← 存放踩坑记录、技术决策等沉淀知识
```

### Step 3: 填充 ai-work/rules/project-rules.md

根据 Step 1 检测到的项目类型，选择对应的模板填充。

---

#### 模板 A: Java / Spring 项目

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描构建文件填充）
- 简介: （一句话描述）
- 技术栈: （扫描 pom.xml / build.gradle 填充）
- 构建工具: Maven / Gradle

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

```
Controller (web/)       <- 入口层，参数校验 + 协议转换
   |
Service (service/)      <- 业务编排，事务边界
   |
DAO (dao/)              <- 纯数据访问
   |
Entity (entity/)        <- 数据模型
```

## 3. 命名规范

- 类名：大驼峰，见名知意（基于实际代码扫描）
- 方法名：小驼峰，动词开头（基于实际代码扫描）
- 常量：全大写下划线分隔（基于实际代码扫描）
- 测试类：被测类名 + Test 结尾（基于实际代码扫描）

## 4. 异常处理

- （基于实际代码扫描，如"业务异常使用自定义 BizException，携带错误码"）
- （基于实际代码扫描，如"禁止吞掉异常（空 catch），catch 中必须记录日志"）

## 5. 日志规范

- （基于实际代码扫描，如"Controller 入口打 INFO，异常打 ERROR 含完整堆栈"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 中间件/库 | 用途 | 备注 |
|-----------|------|------|
| （扫描构建文件填充） | | |

## 7. 其他约定

- （基于实际代码扫描）
```

---

#### 模板 B: Python 项目

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描构建文件填充）
- 简介: （一句话描述）
- 技术栈: （扫描 pyproject.toml / requirements.txt 填充，如 FastAPI + Pydantic + SQLAlchemy）
- 构建工具: Poetry / pip + venv / uv

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

根据框架类型选择对应结构：

**FastAPI / Flask 风格：**
```
app/
  api/         <- 路由层，请求/响应模型
  service/     <- 业务逻辑层
  model/       <- 数据模型（SQLAlchemy / Pydantic）
  core/        <- 配置、依赖、中间件
```

**Django 风格：**
```
project/
  app1/
    views.py   <- 视图层
    models.py  <- 数据模型
    serializers.py  <- 序列化
    urls.py
  app2/
    ...
```

## 3. 命名规范

- 模块/包名：小写下划线（snake_case）（基于实际代码扫描）
- 类名：大驼峰（PascalCase）（基于实际代码扫描）
- 函数/变量名：小写下划线（snake_case）（基于实际代码扫描）
- 常量：全大写下划线（基于实际代码扫描）
- 测试文件：`test_*.py` / `*_test.py`（基于实际代码扫描）
- 类型注解：是否强制使用 type hints（基于实际代码扫描）

## 4. 异常处理

- （基于实际代码扫描，如"自定义异常继承自 Exception，定义在 exceptions.py"）
- （基于实际代码扫描，如"使用 try/except 包裹外部调用，异常统一转换为业务异常"）

## 5. 日志规范

- （基于实际代码扫描，如"使用 logging 模块，按模块名获取 logger"）
- （基于实际代码扫描，如"日志级别规范：INFO 记录业务流程，ERROR 记录异常含 traceback"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 库 | 用途 | 备注 |
|----|------|------|
| （扫描 pyproject.toml / requirements.txt 填充） | | |

## 7. 其他约定

- （基于实际代码扫描，如"配置管理使用 pydantic-settings"）
- （基于实际代码扫描，如"数据库迁移使用 Alembic"）
- （基于实际代码扫描，如"异步代码优先使用 async/await"）
```

---

#### 模板 C: 前端项目（React / Vue）

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描 package.json 填充）
- 简介: （一句话描述）
- 技术栈: React / Vue + TypeScript + （Vite / Next / Nuxt）
- 构建工具: Vite / Webpack / Turbopack / esbuild

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

**React 风格：**
```
src/
  components/   <- 通用组件
  pages/        <- 页面级组件（或 app/ 路由）
  hooks/        <- 自定义 Hooks
  stores/       <- 状态管理（Redux / Zustand / Jotai）
  api/          <- API 客户端
  styles/       <- 样式（CSS Modules / Tailwind / styled-components）
  types/        <- TypeScript 类型定义
```

**Vue 风格：**
```
src/
  views/        <- 页面级组件
  components/   <- 通用组件
  stores/       <- Pinia / Vuex 状态管理
  router/       <- 路由配置
  api/          <- API 客户端
  composables/  <- 组合式函数
  assets/       <- 静态资源
```

## 3. 命名规范

- 组件文件：大驼峰（`MyComponent.tsx`）（基于实际代码扫描）
- 非组件文件：小驼峰或短横线（`useAuth.ts` / `api-client.ts`）（基于实际代码扫描）
- CSS 类名：（基于实际代码扫描，如 Tailwind / CSS Modules / BEM）
- 测试文件：`*.test.ts` / `*.spec.ts` / `*.test.tsx`（基于实际代码扫描）
- 目录命名：（基于实际代码扫描，小写 / 小驼峰）
- 类型命名：大驼峰，`I` 前缀或纯大驼峰（基于实际代码扫描）

## 4. 异常处理

- （基于实际代码扫描，如"API 错误统一由拦截器处理，吐给全局 Error Boundary"）
- （基于实际代码扫描，如"异步操作使用 try/catch，错误转 UI 提示"）

## 5. 日志规范

- （基于实际代码扫描，如"开发环境使用 console，生产环境使用 sentry / 自定义 logger"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 库 | 用途 | 备注 |
|----|------|------|
| （扫描 package.json 填充） | | |

## 7. 代码风格

- （基于实际代码扫描，如"ESLint 规则集：standard / airbnb / custom"）
- （基于实际代码扫描，如"Prettier 配置：单引号 / 尾逗号 / 行宽"）
- （基于实际代码扫描，如"使用 Tailwind CSS 原子化样式"）

## 8. 其他约定

- （基于实际代码扫描，如"组件优先使用 Function Component + Hooks"）
- （基于实际代码扫描，如"API 请求使用 React Query / SWR / 自定义 hooks"）
```

---

#### 模板 D: Go 项目

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描 go.mod 填充）
- 简介: （一句话描述）
- 技术栈: Go + （Gin / Echo / Fiber / Chi）

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

```
cmd/              <- 主入口
internal/
  handler/        <- HTTP handler
  service/        <- 业务逻辑
  repository/     <- 数据访问
  model/          <- 数据模型 / DTO
  middleware/     <- 中间件
pkg/              <- 外部可引用的公共包
api/              <- API 定义（protobuf / OpenAPI）
```

## 3. 命名规范

- 包名：小写单数（基于实际代码扫描）
- 类型/接口名：大驼峰，接口通常以 `er` 结尾（基于实际代码扫描）
- 函数/方法：大驼峰（导出）小驼峰（私有）（基于实际代码扫描）
- 变量：小驼峰（基于实际代码扫描）
- 测试文件：`*_test.go`（基于实际代码扫描）
- 错误处理：显式 `if err != nil`，不忽略错误（基于实际代码扫描）

## 4. 异常处理

- （基于实际代码扫描，如"错误使用哨兵错误 / 自定义 error 类型"）
- （基于实际代码扫描，如"handler 层统一错误响应格式"）

## 5. 日志规范

- （基于实际代码扫描，如"使用 log / slog / zap / logrus"）
- （基于实际代码扫描，如"结构化日志，包含 trace_id / request_id"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 库 | 用途 | 备注 |
|----|------|------|
| （扫描 go.mod 填充） | | |

## 7. 其他约定

- （基于实际代码扫描）
- （基于实际代码扫描，如"配置管理使用 viper"）
- （基于实际代码扫描，如"数据库操作使用 GORM / sqlx / sqlc"）
```

---

#### 模板 E: Node.js / Express / NestJS 项目

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描 package.json 填充）
- 简介: （一句话描述）
- 技术栈: Node.js + TypeScript + （Express / NestJS / Koa）
- 构建工具: tsx / ts-node / ts-jest / swc

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

**NestJS 风格：**
```
src/
  modules/      <- 模块组织
    user/
      controller.ts
      service.ts
      module.ts
  common/       <- 公共（guards, filters, pipes, interceptors）
  config/       <- 配置
```

**Express 风格：**
```
src/
  routes/       <- 路由定义
  controllers/  <- 控制器
  middleware/   <- 中间件
  services/     <- 业务逻辑
  models/       <- 数据模型（Mongoose / Prisma / TypeORM）
  utils/        <- 工具函数
```

## 3. 命名规范

- 文件命名：小驼峰 / 短横线（基于实际代码扫描）
- 类名：大驼峰（基于实际代码扫描）
- 函数/变量：小驼峰（基于实际代码扫描）
- 常量：全大写下划线 / 小驼峰（基于实际代码扫描）
- 测试文件：`*.test.ts` / `*.spec.ts`（基于实际代码扫描）
- 接口类型：大驼峰，可加 `I` 前缀或纯大驼峰（基于实际代码扫描）

## 4. 异常处理

- （基于实际代码扫描，如"NestJS 使用 Exception Filter 统一异常响应"）
- （基于实际代码扫描，如"Express 使用 error-handling middleware"）

## 5. 日志规范

- （基于实际代码扫描，如"使用 winston / pino / NestJS Logger"）
- （基于实际代码扫描，如"结构化日志 + 请求追踪"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 库 | 用途 | 备注 |
|----|------|------|
| （扫描 package.json 填充） | | |

## 7. 其他约定

- （基于实际代码扫描，如"装饰器验证使用 class-validator + class-transformer"）
- （基于实际代码扫描，如"数据库 ORM 使用 Prisma / TypeORM / Mongoose"）
```

---

#### 模板 F: Rust 项目

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描 Cargo.toml 填充）
- 简介: （一句话描述）
- 技术栈: Rust + （Axum / Actix / Rocket / Leptos）
- 构建工具: Cargo

## 2. 目录结构与分层架构

> 执行 `tree -d -L 3` 后填充。

```
src/
  main.rs       <- 入口
  lib.rs        <- 库根
  handler/      <- 请求处理
  model/        <- 数据模型
  service/      <- 业务逻辑
  db/           <- 数据库操作
  config/       <- 配置
```

## 3. 命名规范

- 文件/模块名：小写下划线（snake_case）（基于实际代码扫描）
- 类型/trait 名：大驼峰（基于实际代码扫描）
- 函数/变量：小写下划线（基于实际代码扫描）
- 常量：全大写下划线（基于实际代码扫描）
- 宏：小写下划线 + `!`（基于实际代码扫描）
- 错误类型：通常实现 `std::error::Error`（基于实际代码扫描）

## 4. 错误处理

- （基于实际代码扫描，如"使用 thiserror + anyhow 进行错误处理"）
- （基于实际代码扫描，如"Result 类型作为返回值惯例"）

## 5. 日志规范

- （基于实际代码扫描，如"使用 tracing / log + env_logger"）
- （基于实际代码扫描，如"结构化日志 + span 追踪"）
- 禁止在日志中打印用户敏感信息

## 6. 关键依赖

| 库 | 用途 | 备注 |
|----|------|------|
| （扫描 Cargo.toml 填充） | | |

## 7. 其他约定

- （基于实际代码扫描）
- （基于实际代码扫描，如"异步运行时使用 tokio"）
- （基于实际代码扫描，如"序列化使用 serde"）
```

---

#### 模板 G: 通用（Other）

```markdown
---
alwaysApply: true
---

# 项目规则

## 1. 应用概况

- 应用名: （扫描构建文件填充）
- 简介: （一句话描述）
- 技术栈: （扫描构建文件填充）

## 2. 目录结构

> 执行 `tree -d -L 3` 后填充。

## 3. 命名规范

（基于实际代码扫描填充）

## 4. 错误/异常处理

（基于实际代码扫描填充）

## 5. 关键依赖

| 库/工具 | 用途 | 备注 |
|---------|------|------|
| （扫描构建文件填充） | | |

## 6. 其他约定

（基于实际代码扫描填充）
```

---

### Step 4: 填充 ai-work/rules/domain-rules.md

使用以下模板结构，填充业务领域特定规则。此模板**语言无关**，适用于所有项目类型：

```markdown
---
alwaysApply: true
---

# 领域规则与安全红线

## 1. 业务领域约束

- （待填充，基于扫描的实际代码，如"所有金额使用 long 类型，单位为分"）
- （待填充，如"时间字段统一使用 xxx 类型"）
- （待填充，如"外部接口调用必须设置超时并做降级处理"）
- （待填充，如"状态变更必须通过状态机，禁止直接 set 状态字段"）

## 2. 代码安全

- 禁止在代码中硬编码密钥、AK/SK、数据库密码、API Token
- 禁止提交包含用户个人信息的测试数据
- 禁止在日志中打印手机号、身份证、银行卡等敏感信息
- 外部输入必须校验后使用，防止注入攻击
- 禁止使用未经校验的用户输入拼接命令或查询语句

## 3. 业务安全

- 涉及资金变更的逻辑，必须在 spec 中明确标注，人工审查后方可编码
- 涉及状态流转的逻辑，必须检查状态机合法性
- 涉及权限变更的逻辑，必须显式校验操作人权限

## 4. 依赖安全

- 新增依赖前需确认其安全性和维护状态
- 不引入已知存在安全漏洞的依赖版本
```

### Step 5: 生成 ai-work/AGENTS.md

rules 填充完成后，在 `ai-work/` 目录下生成 AGENTS.md：

1. 读取 `ai-work/rules/` 下所有 `.md` 文件
2. 合并写入 `ai-work/AGENTS.md`，结构如下：

```markdown
# <项目名> — AI 协作指南

## 规则（始终生效）

---
<ai-work/rules/project-rules.md 内容>
---

---
<ai-work/rules/domain-rules.md 内容>
---

## 可用 Skill

使用 skill 工具加载以下 skill：

- `open-spec` — 创建变更提案
- `open-understand` — 代码理解，产出 code-map.md
- `open-apply` — 按 Spec 逐步执行编码
- `open-review` — 两阶段审查
- `open-debug` — 系统化调试
- `open-archive` — 归档已完成变更
- `open-setup` — 初始化项目上下文
```

使用 Bash 工具读取 ai-work/rules/ 文件并写入 ai-work/AGENTS.md。

## 约束

- 所有结论基于实际代码，附带文件路径
- 反映项目"实际是怎么做的"，不生成理想化规范
- 无明确约定的标注"暂未统一，建议团队讨论"
- Step 5 必须执行，确保 ai-work/AGENTS.md 与 ai-work/rules/ 同步
- Step 5 必须执行，确保 ai-work/AGENTS.md 与 ai-work/rules/ 同步
- Step 5 必须执行，确保 ai-work/AGENTS.md 与 ai-work/rules/ 同步
- Step 5 必须执行，确保 ai-work/AGENTS.md 与 ai-work/rules/ 同步
