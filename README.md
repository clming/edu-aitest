# 🎓 教育助手 (EduAssistant)

> 全平台教育管理类应用 - 帮助学生、老师和家长更好地管理学习和作业

[![CI/CD](https://github.com/clming/edu-aitest/actions/workflows/ci.yml/badge.svg)](https://github.com/clming/edu-aitest/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 📱 项目简介

教育助手是一款全平台教育管理类应用，提供：

- **学生端**: 查看作业、提交作业、学习报告
- **老师端**: 布置作业、批改作业、学生管理
- **家长端**: 查看孩子学习情况、学习报告

## 🏗️ 技术架构

### 前端
- **框架**: Flutter 3.16+
- **状态管理**: Riverpod
- **路由**: GoRouter
- **网络**: Dio
- **本地存储**: Hive

### 后端
- **语言**: Go 1.21+
- **框架**: Gin
- **ORM**: GORM
- **数据库**: PostgreSQL 15+
- **缓存**: Redis 7+
- **认证**: JWT
- **文档**: Swagger

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Go >= 1.21
- PostgreSQL >= 15
- Redis >= 7
- Docker & Docker Compose (可选)

### 后端启动

```bash
cd go-backend

# 1. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置数据库连接

# 2. 安装依赖
go mod download

# 3. 生成 Swagger 文档
swag init -g cmd/main.go -o ./docs

# 4. 运行服务
go run cmd/main.go
```

访问 http://localhost:8080/swagger 查看 API 文档

### 前端启动

```bash
cd flutter-app

# 1. 获取依赖
flutter pub get

# 2. 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 运行应用
flutter run
```

### Docker 一键启动

```bash
# 启动后端服务
cd go-backend
docker-compose up -d

# 启动前端服务
cd flutter-app
docker-compose up -d
```

访问：
- 前端 Web: http://localhost
- 后端 API: http://localhost:8080
- Swagger 文档：http://localhost:8081

## 📁 项目结构

```
edu-aitest/
├── flutter-app/           # Flutter 前端
│   ├── lib/
│   │   ├── main.dart      # 应用入口
│   │   ├── models/        # 数据模型
│   │   ├── providers/     # Riverpod 状态管理
│   │   ├── screens/       # 页面
│   │   ├── services/      # 服务层
│   │   └── widgets/       # 组件
│   ├── test/              # 测试文件
│   ├── scripts/           # 构建脚本
│   └── Dockerfile
│
├── go-backend/            # Go 后端
│   ├── cmd/
│   │   └── main.go        # 应用入口
│   ├── internal/          # 内部包
│   │   ├── config/        # 配置
│   │   └── database/      # 数据库
│   ├── pkg/               # 公共包
│   │   ├── handler/       # HTTP 处理器
│   │   ├── middleware/    # 中间件
│   │   └── models/        # 数据模型
│   ├── scripts/           # 部署脚本
│   ├── docs/              # Swagger 文档
│   └── Dockerfile
│
└── .github/
    └── workflows/         # CI/CD 配置
```

## 🔌 API 接口

### 认证
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/logout` - 用户登出

### 作业管理
- `GET /api/v1/homework` - 获取作业列表
- `GET /api/v1/homework/:id` - 获取作业详情
- `POST /api/v1/homework` - 创建作业
- `PUT /api/v1/homework/:id` - 更新作业
- `DELETE /api/v1/homework/:id` - 删除作业

### 学生管理
- `GET /api/v1/students` - 获取学生列表
- `GET /api/v1/students/:id` - 获取学生详情
- `POST /api/v1/students` - 创建学生档案
- `PUT /api/v1/students/:id` - 更新学生信息

### 学习报告
- `GET /api/v1/reports/weekly` - 获取周报
- `GET /api/v1/reports/monthly` - 获取月报

## 🧪 测试

### 后端测试
```bash
cd go-backend
go test -v ./... -cover
```

### 前端测试
```bash
cd flutter-app
flutter test
```

## 📦 部署

### 生产环境部署

参考各目录下的部署脚本：

- 后端：`go-backend/scripts/deploy.sh`
- 前端：`flutter-app/scripts/build.sh`

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| DATABASE_URL | PostgreSQL 连接字符串 | postgres://localhost:5432/edu_assistant |
| REDIS_URL | Redis 连接字符串 | redis://localhost:6379 |
| JWT_SECRET | JWT 密钥 | edu-assistant-secret-key-2026 |
| PORT | 服务端口 | 8080 |
| ENV | 运行环境 | development |

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👥 团队

- **二爷** - 项目规划

---

**Made with ❤️ by OpenClaw**
