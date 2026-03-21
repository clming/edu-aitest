# 🐳 EduAssistant Docker 部署指南

**项目**: EduAssistant Go 后端  
**创建日期**: 2026-03-20  
**版本**: v1.1

---

## 📋 目录结构

```
go-backend/
├── build/
│   ├── Dockerfile           # Docker 镜像构建文件
│   ├── docker-compose.yml   # Docker Compose 配置
│   ├── deploy.sh            # 一键部署脚本
│   └── docs/
│       └── INSTALL.md       # 本文档
├── cmd/
│   └── main.go              # 主入口
├── internal/
│   ├── config/              # 配置
│   └── database/            # 数据库
└── pkg/
    ├── handler/             # API 处理器
    ├── middleware/          # 中间件
    └── models/              # 数据模型
```

---

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- Go 1.21+ (仅开发需要)

### 一键部署

```bash
# 进入构建目录
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend/build

# 赋予执行权限
chmod +x deploy.sh

# 一键构建和部署
./deploy.sh
```

部署脚本会自动：
1. ✅ 构建 Docker 镜像
2. ✅ 停止旧容器
3. ✅ 启动新容器
4. ✅ 健康检查
5. ✅ 自动创建数据库和表

---

## 📦 手动部署

### 1. 构建 Docker 镜像

```bash
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend/build

# 构建镜像
docker build -t edu-assistant-backend:v1.1 -f Dockerfile ..
```

**构建说明**:
- 使用多阶段构建，最终镜像约 20MB
- 第一阶段：Go 1.21 Alpine 编译
- 第二阶段：Alpine 最新运行

### 2. 查看镜像

```bash
docker images | grep edu-assistant
```

**预期输出**:
```
edu-assistant-backend    v1.1    abc123def456    2 minutes ago    25.6MB
```

### 3. 启动容器

#### 方式 A: 使用 docker-compose（推荐）

```bash
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend/build
docker-compose up -d
```

#### 方式 B: 使用 docker run

```bash
docker run -d \
  --name edu-backend \
  --restart always \
  -p 8080:8080 \
  -e DATABASE_URL="openclaw-edutest:EZi3fxB9Kpqyap%Dm@tcp(mysql-2a840bd18e4b-public.rds.volces.com:33060)/edu_assistant?charset=utf8mb4&parseTime=True&loc=Local&interpolateParams=true" \
  -e JWT_SECRET="edu-assistant-production-secret-key-2026" \
  -e ENV=production \
  -e PORT=8080 \
  edu-assistant-backend:v1.1
```

### 4. 查看容器状态

```bash
# 查看运行中的容器
docker ps | grep edu

# 查看容器详情
docker inspect edu-backend
```

### 5. 查看日志

```bash
# 实时查看日志
docker logs -f edu-backend

# 查看最后 50 行
docker logs --tail 50 edu-backend
```

**预期日志**:
```
🔧 检查并创建数据库...
✅ 数据库 'edu_assistant' 已存在
🔧 执行数据库自动迁移...
✅ 数据库初始化成功（自动创建表 + 自动添加字段）
🚀 服务启动在端口 8080
```

### 6. 健康检查

```bash
# 检查服务健康状态
curl http://localhost:8080/health

# 或使用 docker inspect
docker inspect --format='{{.State.Health.Status}}' edu-backend
```

**预期响应**:
```json
{
  "status": "ok",
  "timestamp": "2026-03-20T14:30:00Z",
  "service": "edu-assistant-backend",
  "version": "1.0.0"
}
```

---

## 🗄️ 数据库自动创建

### 启动时自动执行

容器启动时会自动：

1. **创建数据库**（如果不存在）
   ```sql
   CREATE DATABASE IF NOT EXISTS `edu_assistant` 
   DEFAULT CHARACTER SET utf8mb4 
   COLLATE utf8mb4_unicode_ci;
   ```

2. **创建表**（如果不存在）
   - `users` - 用户表
   - `homeworks` - 作业表
   - `students` - 学生表
   - `reports` - 报告表

3. **自动迁移字段**（版本迭代时）
   - 新增字段自动添加
   - 不删除已有字段（安全）

### 验证数据库和表

```bash
# 连接 MySQL
mysql -h mysql-2a840bd18e4b-public.rds.volces.com -P 33060 -u openclaw-edutest -p

# 输入密码：EZi3fxB9Kpqyap%Dm

# 查看数据库
SHOW DATABASES LIKE 'edu_assistant';

# 使用数据库
USE edu_assistant;

# 查看表
SHOW TABLES;

# 查看表结构
DESCRIBE users;
DESCRIBE homeworks;
DESCRIBE students;
DESCRIBE reports;
```

**预期表结构**:
```
+---------------------+--------------+------+-----+---------+----------------+
| Field               | Type         | Null | Key | Default | Extra          |
+---------------------+--------------+------+-----+---------+----------------+
| id                  | bigint       | NO   | PRI | NULL    | auto_increment |
| created_at          | datetime(3)  | YES  |     | NULL    |                |
| updated_at          | datetime(3)  | YES  |     | NULL    |                |
| deleted_at          | datetime(3)  | YES  | MUL | NULL    |                |
| username            | varchar(50)  | YES  | UNI | NULL    |                |
| email               | varchar(100) | YES  |     | NULL    |                |
| password_hash       | varchar(255) | YES  |     | NULL    |                |
| role                | varchar(20)  | YES  |     | student |                |
+---------------------+--------------+------+-----+---------+----------------+
```

---

## 🔧 常用命令

### 容器管理

```bash
# 停止容器
docker-compose down

# 重启容器
docker-compose restart

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f backend

# 进入容器
docker exec -it edu-backend sh
```

### 镜像管理

```bash
# 查看镜像
docker images | grep edu

# 删除镜像
docker rmi edu-assistant-backend:v1.1

# 清理悬空镜像
docker image prune -f
```

### 日志管理

```bash
# 查看日志
docker logs edu-backend

# 实时日志
docker logs -f edu-backend

# 最近 100 行
docker logs --tail 100 edu-backend

# 带时间戳
docker logs -t edu-backend
```

---

## 🎯 环境变量配置

### .env 文件

在 `build/` 目录创建 `.env` 文件：

```bash
# 数据库配置
DATABASE_URL=openclaw-edutest:EZi3fxB9Kpqyap%Dm@tcp(mysql-2a840bd18e4b-public.rds.volces.com:33060)/edu_assistant?charset=utf8mb4&parseTime=True&loc=Local&interpolateParams=true

# JWT 配置
JWT_SECRET=edu-assistant-production-secret-key-2026-change-me

# 运行环境
ENV=production

# 服务端口
PORT=8080
```

### docker-compose.yml 中配置

已在 `docker-compose.yml` 中配置环境变量，直接启动即可。

---

## ⚠️ 故障排查

### 1. 容器启动失败

```bash
# 查看详细日志
docker logs edu-backend

# 检查配置文件
docker-compose config

# 重新构建
docker-compose build --no-cache
```

### 2. 数据库连接失败

**检查项**:
- 数据库地址是否正确
- 用户名密码是否正确
- 网络是否通畅
- 防火墙是否开放

```bash
# 测试数据库连接
docker exec -it edu-backend wget --spider mysql-2a840bd18e4b-public.rds.volces.com:33060
```

### 3. 数据库未自动创建

**可能原因**:
- 数据库权限不足
- 连接字符串错误

**解决方案**:
```bash
# 手动创建数据库
mysql -h mysql-2a840bd18e4b-public.rds.volces.com -P 33060 -u openclaw-edutest -p

CREATE DATABASE IF NOT EXISTS `edu_assistant` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

### 4. 端口冲突

```bash
# 查看端口占用
lsof -i :8080

# 修改端口
# 编辑 docker-compose.yml，修改 ports: "8081:8080"
```

---

## 📊 性能优化

### 1. 镜像大小优化

当前镜像大小：~25MB

优化措施：
- ✅ 多阶段构建
- ✅ 使用 Alpine 基础镜像
- ✅ CGO_ENABLED=0 静态编译

### 2. 启动速度优化

当前启动时间：~5 秒

优化措施：
- ✅ 减少依赖
- ✅ 并发初始化
- ✅ 健康检查配置

### 3. 资源限制

在 `docker-compose.yml` 中添加：

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

---

## 🎉 验证部署

### 1. 健康检查

```bash
curl http://localhost:8080/health
```

### 2. API 测试

```bash
# 注册
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"123456"}'

# 登录
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456"}'
```

### 3. 数据库验证

```bash
mysql -h mysql-2a840bd18e4b-public.rds.volces.com -P 33060 -u openclaw-edutest -p

USE edu_assistant;
SHOW TABLES;
SELECT * FROM users LIMIT 1;
```

---

## 📞 相关文档

- `../docs/DB-MIGRATION.md` - 数据库迁移指南
- `../docs/EMAIL-NOTIFICATION.md` - 邮件通知配置
- `../AGENT-WORKFLOW.md` - Agent 工作流

---

**文档版本**: v1.1  
**创建时间**: 2026-03-20  
**维护人**: AI Developer Agent
