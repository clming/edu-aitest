# EduAssistant 系统架构设计

## 1. 系统概述

EduAssistant 是一个跨平台教育助手应用，支持 iOS、Android 和 Web 端，提供个性化的学习辅助功能。

## 2. 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   Flutter iOS   │  Flutter Android│      Flutter Web            │
│                 │                 │                             │
│  - 学习管理     │  - 学习管理     │  - 学习管理                 │
│  - 课程浏览     │  - 课程浏览     │  - 课程浏览                 │
│  - 进度追踪     │  - 进度追踪     │  - 进度追踪                 │
│  - AI 助手       │  - AI 助手       │  - AI 助手                  │
└────────┬────────┴────────┬────────┴──────────────┬──────────────┘
         │                 │                       │
         └─────────────────┼───────────────────────┘
                           │ HTTPS/WebSocket
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway                               │
│                    (OpenClaw Gateway)                            │
│  - 路由分发  - 认证授权  - 限流  - 日志  - 监控                   │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                           │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   User Service  │  Course Service │    Learning Service         │
│   (用户服务)    │   (课程服务)    │     (学习服务)              │
├─────────────────┼─────────────────┼─────────────────────────────┤
│   AI Service    │  Progress Svc   │    Notification Svc         │
│   (AI 服务)     │   (进度服务)    │     (通知服务)              │
└────────┬────────┴────────┬────────┴──────────────┬──────────────┘
         │                 │                       │
         └─────────────────┼───────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  PostgreSQL   │ │    Redis      │ │  File Store   │
│  (主数据库)   │ │  (缓存/会话)  │ │  (静态资源)   │
└───────────────┘ └───────────────┘ └───────────────┘
```

## 3. 技术栈

### 3.1 前端 (Flutter)
- **框架**: Flutter 3.x
- **状态管理**: Riverpod / Bloc
- **网络**: Dio + WebSocket
- **本地存储**: Hive / SharedPreferences
- **平台**: iOS 14+, Android 10+, Web (Chrome/Safari/Edge)

### 3.2 后端 (Go)
- **语言**: Go 1.21+
- **框架**: Gin / Echo
- **ORM**: GORM / sqlc
- **验证**: Go Play Validator
- **文档**: Swagger / OpenAPI 3.0

### 3.3 数据库
- **主数据库**: PostgreSQL 15+
- **缓存**: Redis 7+
- **会话**: Redis (JWT 黑名单)

### 3.4 基础设施
- **网关**: OpenClaw Gateway
- **容器**: Docker + Docker Compose
- **部署**: Kubernetes (可选)
- **CI/CD**: GitHub Actions / GitLab CI

## 4. 核心模块

### 4.1 用户服务 (User Service)
- 用户注册/登录
- 个人信息管理
- 角色权限 (学生/教师/管理员)
- 第三方登录 (微信/Google/Apple)

### 4.2 课程服务 (Course Service)
- 课程管理 (CRUD)
- 章节/课时管理
- 课程分类/标签
- 课程搜索/推荐

### 4.3 学习服务 (Learning Service)
- 学习计划制定
- 学习进度追踪
- 笔记/收藏管理
- 错题本管理

### 4.4 AI 服务 (AI Service)
- 智能问答
- 学习建议生成
- 个性化推荐
- 作业批改辅助

### 4.5 进度服务 (Progress Service)
- 学习数据统计
- 成就系统
- 学习报告生成
- 可视化图表

### 4.6 通知服务 (Notification Service)
- 推送通知
- 站内消息
- 邮件通知
- 学习提醒

## 5. 数据流

### 5.1 用户认证流程
```
Client → Gateway → User Service → PostgreSQL
                    ↓
                  Redis (Session/Token)
```

### 5.2 学习数据流程
```
Client → Gateway → Learning Service → PostgreSQL
                    ↓
                  Redis (Cache)
                    ↓
                  Progress Service → Analytics
```

### 5.3 AI 交互流程
```
Client → Gateway → AI Service → External AI API
                    ↓
                  PostgreSQL (History)
```

## 6. 安全设计

### 6.1 认证授权
- JWT Token 认证
- Refresh Token 机制
- RBAC 权限控制
- API 访问限流

### 6.2 数据安全
- HTTPS 传输加密
- 敏感数据加密存储
- SQL 注入防护
- XSS 防护

### 6.3 隐私保护
- 用户数据脱敏
- GDPR 合规
- 数据导出/删除支持

## 7. 可扩展性

### 7.1 水平扩展
- 无状态服务设计
- Redis 共享会话
- 数据库读写分离

### 7.2 微服务演进
- 当前：模块化单体
- 未来：按需拆分为微服务
- 服务间通信：gRPC / REST

## 8. 监控与日志

### 8.1 应用监控
- Prometheus + Grafana
- 关键指标：QPS、延迟、错误率
- 业务指标：DAU、留存率、学习时长

### 8.2 日志系统
- 结构化日志 (JSON)
- 日志聚合：ELK / Loki
- 分布式追踪：Jaeger / OpenTelemetry

### 8.3 告警
- 异常告警 (PagerDuty / 钉钉)
- 性能告警
- 业务告警

---

**版本**: v1.0  
**创建日期**: 2026-03-20  
**最后更新**: 2026-03-20
