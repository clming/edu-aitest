# Edu-AITest 项目完整资料汇总

**项目仓库**: https://github.com/clming/edu-aitest

**最后更新**: 2026-03-24

---

## 📁 项目结构

```
edu-aitest/
├── docs/                    # 产品文档和技术文档
│   ├── PRD.md              # 产品需求文档
│   ├── USER-STORIES.md     # 用户故事
│   ├── FEATURES.md         # 功能列表
│   ├── 01-system-architecture.md  # 系统架构
│   ├── 02-wbs.md           # 工作分解结构
│   ├── 03-development-plan.md     # 开发计划
│   ├── 04-api-specification.md    # API 规范
│   ├── UI-UX-DESIGN.md     # UI/UX 设计文档
│   ├── bugs.md             # Bug 跟踪
│   ├── test-cases.md       # 测试用例
│   ├── test-plan.md        # 测试计划
│   ├── test-report.md      # 测试报告
│   └── ...                 # 更多文档
├── flutter-app/            # 移动端/WEB 端 Flutter 应用
│   ├── lib/                # 源代码
│   │   ├── screens/        # 页面
│   │   ├── widgets/        # 组件
│   │   ├── models/         # 数据模型
│   │   ├── providers/      # 状态管理
│   │   ├── services/       # API 服务
│   │   └── utils/          # 工具函数
│   ├── test/               # 单元测试
│   ├── assets/             # 资源文件
│   └── scripts/            # 构建脚本
├── go-backend/             # Go 后端服务
│   ├── cmd/                # 主程序入口
│   ├── internal/           # 内部包
│   ├── pkg/                # 公共包
│   │   ├── handler/        # HTTP 处理器
│   │   ├── middleware/     # 中间件
│   │   └── models/         # 数据模型
│   └── scripts/            # 部署脚本
├── agents/                 # Agent 配置
│   ├── coordinator.py      # 协调器
│   └── *.json              # Agent 配置文件
├── .github/workflows/      # CI/CD 配置
└── scripts/                # 项目脚本
```

---

## 📋 Agent 分工说明

### 1. Coordinator (协调员)
**文件**: `agents/coordinator.py`, `agents/coordinator.json`
**职责**: 
- 协调整个开发流程
- 分配任务给各角色 Agent
- 跟踪进度和状态

### 2. Product Manager (产品经理)
**文件**: `agents/product-manager.json`
**职责**:
- 需求分析和文档编写
- 用户故事维护
- 功能优先级排序

### 3. Project Manager (项目经理)
**文件**: `agents/project-manager.json`
**职责**:
- 制定开发计划 (WBS)
- 跟踪任务进度
- 风险管理

### 4. Senior Developer (高级开发)
**文件**: `agents/developer.json`
**职责**:
- 系统架构设计
- 核心代码实现
- 代码审查

### 5. QA Engineer (测试工程师)
**文件**: `agents/qa-engineer.json`
**职责**:
- 编写测试用例
- 执行测试
- Bug 跟踪和验证

---

## 📄 产品文档清单

| 文档 | 路径 | 说明 |
|------|------|------|
| PRD | `docs/PRD.md` | 产品需求文档 (31KB) |
| 用户故事 | `docs/USER-STORIES.md` | 完整用户故事 (31KB) |
| 功能列表 | `docs/FEATURES.md` | 功能详细说明 (26KB) |
| 系统架构 | `docs/01-system-architecture.md` | 技术架构设计 |
| WBS | `docs/02-wbs.md` | 工作分解结构 |
| 开发计划 | `docs/03-development-plan.md` | 开发时间线 |
| API 规范 | `docs/04-api-specification.md` | API 接口文档 |
| UI/UX 设计 | `docs/UI-UX-DESIGN.md` | 设计稿和交互 (63KB) |

---

## 💻 代码统计

### Flutter 前端
- **页面**: 8 个主要页面 (登录、注册、主页、作业列表、作业详情、学生列表、报告、个人中心)
- **组件**: 通用组件库
- **测试**: 4 个测试文件 (auth, model, utils, widget)
- **代码行数**: ~3000+ 行 Dart 代码

### Go 后端
- **处理器**: 5 个 (auth, homework, report, student, health)
- **中间件**: 3 个 (error, middleware, ratelimit)
- **模型**: 5 个 (user, homework, report, student, security_test)
- **测试**: 多个单元测试文件

---

## 🧪 测试用例

**测试文档**:
- `docs/test-plan.md` - 测试计划
- `docs/test-cases.md` - 详细测试用例 (21KB)
- `docs/test-report.md` - 测试报告 (13KB)
- `docs/security-test.md` - 安全测试报告 (21KB)
- `docs/performance-test.md` - 性能测试报告 (12KB)

**单元测试**:
- `flutter-app/test/` - Flutter 单元测试
- `go-backend/pkg/handler/*_test.go` - Go 单元测试

---

## 🐛 Bug 记录

**Bug 跟踪文件**:
- `docs/bugs.md` - 主 Bug 列表 (14KB)
- `docs/BUG-FIX-REPORT.md` - Bug 修复报告
- `docs/bug/` - 版本 Bug 跟踪
  - `bugs-v1.0.md`
  - `BUG-FIX-REPORT-v1.1.md`
  - `QA-REPORT-v1.0.md`
  - `VERSION-TRACKING.md`

---

## 🚀 部署文档

- `flutter-app/DEPLOYMENT.md` - Flutter 部署指南
- `flutter-app/PROJECT_SUMMARY.md` - 项目总结
- `go-backend/docs/INSTALL.md` - 后端安装文档
- `README.md` - 项目总览
- `GITHUB-CONFIG.md` - GitHub 配置说明

---

## 📊 项目状态

- ✅ 产品需求文档完成
- ✅ 系统架构设计完成
- ✅ 前端核心功能实现
- ✅ 后端 API 实现
- ✅ 单元测试编写
- ✅ CI/CD 配置
- 🔄 持续集成和部署

---

## 🔗 相关链接

- GitHub 仓库：https://github.com/clming/edu-aitest
- 文档目录：`/docs/`
- 前端代码：`/flutter-app/`
- 后端代码：`/go-backend/`
- Agent 配置：`/agents/`
