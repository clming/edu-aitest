# ⚡ EduAssistant 性能测试报告

**版本**: v1.0  
**测试日期**: 2026-03-20  
**测试工程师**: AI QA Agent  
**测试类型**: 性能测试规划 + 静态分析

---

## 📋 目录

1. [测试概述](#1-测试概述)
2. [测试环境](#2-测试环境)
3. [性能指标](#3-性能指标)
4. [测试场景](#4-测试场景)
5. [测试脚本](#5-测试脚本)
6. [预期基准](#6-预期基准)
7. [优化建议](#7-优化建议)

---

## 1. 测试概述

### 1.1 测试目标

- 评估系统在不同负载下的响应时间
- 确定系统瓶颈和最大承载能力
- 验证数据库查询性能
- 评估缓存效果
- 提供性能优化建议

### 1.2 测试范围

| 接口 | 测试类型 | 优先级 |
|------|---------|--------|
| `POST /api/v1/auth/login` | 负载测试 | P0 |
| `GET /api/v1/homework` | 负载测试 | P0 |
| `GET /api/v1/homework/:id` | 负载测试 | P1 |
| `POST /api/v1/homework` | 压力测试 | P1 |
| `GET /api/v1/reports/weekly` | 负载测试 | P2 |
| `GET /api/v1/students` | 负载测试 | P2 |

### 1.3 测试类型

| 测试类型 | 描述 | 目标 |
|---------|------|------|
| 负载测试 | 预期负载下的性能 | 验证 SLA |
| 压力测试 | 超出预期负载 | 找到瓶颈 |
| 耐久性测试 | 长时间运行 | 检测内存泄漏 |
| 并发测试 | 同时访问 | 检测竞态条件 |

---

## 2. 测试环境

### 2.1 硬件配置 (预期)

| 组件 | 配置 |
|------|------|
| CPU | 4 核 8 线程 |
| 内存 | 8GB |
| 存储 | SSD |
| 网络 | 1Gbps |

### 2.2 软件配置

| 组件 | 版本 |
|------|------|
| Go | 1.21+ |
| PostgreSQL | 15+ |
| Redis | 7+ |
| OS | Linux |

### 2.3 测试工具

| 工具 | 用途 |
|------|------|
| wrk | HTTP 基准测试 |
| ab (Apache Bench) | 简单负载测试 |
| JMeter | 复杂场景测试 |
| pg_stat_statements | PostgreSQL 性能分析 |
| pprof | Go 性能分析 |

---

## 3. 性能指标

### 3.1 关键指标 (KPI)

| 指标 | 目标值 | 警告值 | 临界值 |
|------|--------|--------|--------|
| 平均响应时间 | < 200ms | < 500ms | > 1000ms |
| P95 响应时间 | < 500ms | < 1000ms | > 2000ms |
| P99 响应时间 | < 1000ms | < 2000ms | > 5000ms |
| 吞吐量 | > 1000 req/s | > 500 req/s | < 100 req/s |
| 错误率 | < 0.1% | < 1% | > 5% |
| CPU 使用率 | < 70% | < 85% | > 95% |
| 内存使用率 | < 70% | < 85% | > 95% |

### 3.2 数据库指标

| 指标 | 目标值 |
|------|--------|
| 查询时间 (简单) | < 10ms |
| 查询时间 (复杂) | < 100ms |
| 连接池使用率 | < 80% |
| 慢查询比例 | < 1% |

---

## 4. 测试场景

### 4.1 场景 1: 登录接口负载测试

**目标**: 验证认证接口在并发下的性能

**配置**:
```bash
并发用户：10, 50, 100, 500
持续时间：30 秒
预热时间：5 秒
```

**预期结果**:
| 并发数 | 平均 RT | P95 RT | 吞吐量 | 错误率 |
|--------|--------|--------|--------|--------|
| 10 | < 100ms | < 200ms | > 100/s | 0% |
| 50 | < 150ms | < 300ms | > 300/s | 0% |
| 100 | < 200ms | < 500ms | > 500/s | < 0.1% |
| 500 | < 500ms | < 1000ms | > 800/s | < 1% |

---

### 4.2 场景 2: 作业列表查询

**目标**: 验证列表查询性能

**配置**:
```bash
数据量：1000 条作业记录
并发用户：10, 50, 100
筛选条件：无、按科目、按状态
```

**预期结果**:
| 筛选条件 | 平均 RT | P95 RT |
|---------|--------|--------|
| 无筛选 | < 50ms | < 100ms |
| 按科目 | < 30ms | < 60ms |
| 按状态 | < 30ms | < 60ms |

---

### 4.3 场景 3: 创建作业压力测试

**目标**: 验证写操作性能

**配置**:
```bash
并发用户：10, 50, 100
持续时间：60 秒
```

**关注点**:
- 数据库写入性能
- 事务锁竞争
- 连接池饱和

---

### 4.4 场景 4: 报告接口性能测试

**目标**: 验证复杂查询性能

**配置**:
```bash
数据量：10000 条作业记录
并发用户：5, 10, 20
```

**关注点**:
- 聚合查询性能
- 数据库索引效果
- 缓存命中率

---

### 4.5 场景 5: 耐久性测试

**目标**: 检测内存泄漏和资源耗尽

**配置**:
```bash
并发用户：50
持续时间：4 小时
检查间隔：15 分钟
```

**监控指标**:
- 内存使用趋势
- Goroutine 数量
- 数据库连接数
- 文件描述符使用

---

## 5. 测试脚本

### 5.1 wrk 测试脚本

创建文件 `scripts/performance/wrk_login.lua`:

```lua
-- wrk Lua 脚本 for 登录测试
wrk.method = "POST"
wrk.body = '{"username":"testuser","password":"password123"}'
wrk.headers["Content-Type"] = "application/json"

-- 可选：添加 token (如果需要)
-- wrk.headers["Authorization"] = "Bearer " .. token
```

运行命令:
```bash
# 基础测试
wrk -t4 -c100 -d30s http://localhost:8080/api/v1/auth/login -s scripts/performance/wrk_login.lua

# 高并发测试
wrk -t8 -c500 -d60s http://localhost:8080/api/v1/auth/login -s scripts/performance/wrk_login.lua
```

### 5.2 作业列表测试脚本

创建文件 `scripts/performance/wrk_homework.lua`:

```lua
wrk.method = "GET"
wrk.headers["Authorization"] = "Bearer " .. token

-- token 可以通过环境变量传入
```

运行命令:
```bash
export TOKEN="your_jwt_token_here"
wrk -t4 -c100 -d30s -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/homework
```

### 5.3 综合测试脚本

创建文件 `scripts/test_performance.sh`:

```bash
#!/bin/bash
# EduAssistant 性能测试脚本

set -e

BASE_URL="http://localhost:8080"
TOKEN=""

echo "========================================="
echo "EduAssistant 性能测试"
echo "========================================="

# 获取 token
echo "[1/6] 获取认证 token..."
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}')
TOKEN=$(echo "$RESPONSE" | jq -r '.token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo "❌ 获取 token 失败"
    exit 1
fi
echo "✓ Token 获取成功"

# 检查 wrk 是否安装
if ! command -v wrk &> /dev/null; then
    echo "❌ wrk 未安装，请先安装：sudo apt install wrk"
    exit 1
fi

echo ""
echo "[2/6] 健康检查接口测试..."
wrk -t2 -c10 -d10s "$BASE_URL/api/v1/health"

echo ""
echo "[3/6] 登录接口负载测试 (100 并发)..."
wrk -t4 -c100 -d30s "$BASE_URL/api/v1/auth/login" \
  -s scripts/performance/wrk_login.lua

echo ""
echo "[4/6] 作业列表查询测试 (100 并发)..."
wrk -t4 -c100 -d30s "$BASE_URL/api/v1/homework" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo "[5/6] 学生列表查询测试 (50 并发)..."
wrk -t2 -c50 -d30s "$BASE_URL/api/v1/students" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo "[6/6] 周报接口测试 (20 并发)..."
wrk -t2 -c20 -d30s "$BASE_URL/api/v1/reports/weekly?student_id=1" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo "========================================="
echo "性能测试完成!"
echo "========================================="
```

### 5.4 JMeter 测试计划

创建文件 `scripts/performance/edu-assistant.jmx` (JMeter XML 格式):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan>
  <!-- JMeter 测试计划配置 -->
  <!-- 由于 XML 较长，这里提供概要 -->
  
  Thread Group:
    - Number of Threads: 100
    - Ramp-up Period: 10
    - Loop Count: forever
  
  HTTP Request Defaults:
    - Protocol: http
    - Server: localhost
    - Port: 8080
  
  HTTP Request - Login:
    - POST /api/v1/auth/login
    - Body: {"username":"test","password":"test123"}
  
  JSON Extractor:
    - Extract token from response
  
  HTTP Request - Get Homework:
    - GET /api/v1/homework
    - Header: Authorization: Bearer ${token}
  
  View Results Tree (for debugging)
  Summary Report
</jmeterTestPlan>
```

---

## 6. 预期基准

### 6.1 代码审查发现的性能问题

基于对源代码的审查，识别以下潜在性能问题：

#### 问题 1: N+1 查询问题

**位置**: `GetHomeworkList` handler

**当前代码**:
```go
query := database.DB.Preload("Teacher").Preload("Student")
// ...
query.Find(&homeworkList)
```

**风险**: 如果作业数量大，会产生大量关联查询

**优化建议**:
```go
// 使用 Joins 或批量加载
database.DB.Joins("LEFT JOIN users teachers ON teachers.id = homework.teacher_id").
           Joins("LEFT JOIN users students ON students.id = homework.student_id").
           Find(&homeworkList)
```

---

#### 问题 2: 报告查询无缓存

**位置**: `GetWeeklyReport`, `GetMonthlyReport`

**风险**: 每次请求都重新计算统计数据

**优化建议**:
```go
// 使用 Redis 缓存结果
cacheKey := fmt.Sprintf("report:weekly:%d", studentID)
cached, err := redis.Get(cacheKey).Result()
if err == nil {
    // 返回缓存
    return cached
}

// 计算报告
report := calculateReport(studentID)

// 缓存 5 分钟
redis.Set(cacheKey, report, 5*time.Minute)
```

---

#### 问题 3: 缺少数据库索引

**建议添加的索引**:

```sql
-- 作业表索引
CREATE INDEX idx_homework_student_id ON homework(student_id);
CREATE INDEX idx_homework_teacher_id ON homework(teacher_id);
CREATE INDEX idx_homework_subject ON homework(subject);
CREATE INDEX idx_homework_is_completed ON homework(is_completed);
CREATE INDEX idx_homework_deadline ON homework(deadline);
CREATE INDEX idx_homework_created_at ON homework(created_at);

-- 组合索引
CREATE INDEX idx_homework_student_status ON homework(student_id, is_completed);
CREATE INDEX idx_homework_student_subject ON homework(student_id, subject);

-- 学生表索引
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_parent_id ON students(parent_id);
```

---

#### 问题 4: 连接池未配置

**建议配置**:

```go
// internal/database/database.go
sqlDB, err := db.DB()
if err != nil {
    return err
}

// 连接池配置
sqlDB.SetMaxIdleConns(10)      // 最大空闲连接
sqlDB.SetMaxOpenConns(100)     // 最大打开连接
sqlDB.SetConnMaxLifetime(time.Hour)  // 连接最大生命周期
```

---

### 6.2 预期性能基准

基于代码结构和架构，预期性能基准：

| 接口 | 数据量 | 并发 | 预期 RT | 预期 TPS |
|------|--------|------|--------|---------|
| POST /auth/login | - | 100 | 100ms | 500/s |
| GET /homework | 1000 条 | 100 | 50ms | 1000/s |
| GET /homework/:id | - | 100 | 20ms | 2000/s |
| POST /homework | - | 50 | 100ms | 300/s |
| GET /reports/weekly | 1000 条 | 20 | 200ms | 100/s |
| GET /students | 100 条 | 100 | 30ms | 1500/s |

---

## 7. 优化建议

### 7.1 紧急优化 (P0)

1. **添加数据库索引**
   - 外键字段索引
   - 常用查询字段索引
   - 组合索引

2. **实现缓存层**
   - 报告数据缓存 (Redis)
   - 热点数据缓存
   - 缓存失效策略

3. **配置连接池**
   - GORM 连接池参数
   - Redis 连接池参数

---

### 7.2 重要优化 (P1)

1. **优化 N+1 查询**
   - 使用 Joins 替代 Preload
   - 批量加载关联数据

2. **实现分页**
   - 所有列表接口强制分页
   - 限制最大页大小

3. **异步处理**
   - 报告生成异步化
   - 使用消息队列

---

### 7.3 长期优化 (P2)

1. **数据库优化**
   - 读写分离
   - 分库分表 (数据量大时)
   - 归档历史数据

2. **CDN 加速**
   - 静态资源 CDN
   - 图片/文件 CDN

3. **监控告警**
   - Prometheus + Grafana
   - 慢查询监控
   - 性能告警

---

## 8. 监控指标

### 8.1 应用监控

```go
// 使用 Prometheus 中间件
import "github.com/zsais/go-gin-prometheus"

p := ginprometheus.NewPrometheus("gin")
p.Use(r)
```

**监控指标**:
- HTTP 请求数
- 请求延迟分布
- 错误率
- Goroutine 数量

### 8.2 数据库监控

```sql
-- 启用慢查询日志
-- PostgreSQL: log_min_duration_statement = 1000

-- 查看慢查询
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### 8.3 系统监控

| 指标 | 工具 | 告警阈值 |
|------|------|---------|
| CPU 使用率 | Prometheus | > 80% |
| 内存使用率 | Prometheus | > 85% |
| 磁盘使用率 | Node Exporter | > 90% |
| 网络 IO | Node Exporter | - |

---

## 9. 测试检查清单

- [ ] 安装性能测试工具 (wrk, JMeter)
- [ ] 准备测试数据
- [ ] 配置测试环境
- [ ] 执行基准测试
- [ ] 执行负载测试
- [ ] 执行压力测试
- [ ] 执行耐久性测试
- [ ] 分析性能瓶颈
- [ ] 实施优化
- [ ] 回归测试
- [ ] 生成性能报告

---

## 10. 结论

由于测试环境限制，本报告提供了：

1. ✅ 完整的性能测试方案
2. ✅ 可执行的测试脚本
3. ✅ 预期性能基准
4. ✅ 代码审查发现的性能问题
5. ✅ 优化建议

**下一步行动**:

1. 搭建测试环境
2. 执行实际性能测试
3. 根据结果优化
4. 建立性能监控

---

**报告生成时间**: 2026-03-20 00:59 GMT+7  
**测试工程师**: AI QA Agent

---

*文档结束*
