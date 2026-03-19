# EduAssistant API 规范

## 1. 概述

本文档定义 EduAssistant 系统的 RESTful API 规范，所有服务遵循统一的设计原则。

### 1.1 基础信息

- **API 版本**: v1
- **基础路径**: `/api/v1`
- **协议**: HTTPS
- **数据格式**: JSON (UTF-8)
- **认证方式**: JWT Bearer Token

### 1.2 环境

| 环境 | 域名 | 用途 |
|------|------|------|
| 开发 | `dev-api.eduassistant.com` | 开发测试 |
| 测试 | `test-api.eduassistant.com` | 集成测试 |
| 预发 | `staging-api.eduassistant.com` | UAT 测试 |
| 生产 | `api.eduassistant.com` | 线上服务 |

---

## 2. 通用规范

### 2.1 请求规范

#### 请求头 (Headers)

```http
Content-Type: application/json
Authorization: Bearer <jwt_token>
X-Request-ID: <uuid>
X-Client-Version: 1.0.0
X-Platform: ios|android|web
```

#### 分页参数

```http
GET /api/v1/courses?page=1&pageSize=20
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| page | integer | 1 | 页码 (从 1 开始) |
| pageSize | integer | 20 | 每页数量 (最大 100) |
| sortBy | string | createdAt | 排序字段 |
| sortOrder | string | desc | 排序方向 (asc/desc) |

### 2.2 响应规范

#### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "meta": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": 1710864000000
  }
}
```

#### 分页响应

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  },
  "meta": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": 1710864000000
  }
}
```

#### 错误响应

```json
{
  "code": 1001,
  "message": "参数验证失败",
  "data": null,
  "meta": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": 1710864000000,
    "details": [
      {
        "field": "email",
        "message": "邮箱格式不正确"
      }
    ]
  }
}
```

### 2.3 状态码

#### HTTP 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 204 | 删除成功 (无内容) |
| 400 | 请求参数错误 |
| 401 | 未认证/Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

#### 业务状态码

| 范围 | 说明 |
|------|------|
| 0 | 成功 |
| 1000-1999 | 通用错误 |
| 2000-2999 | 用户相关 |
| 3000-3999 | 课程相关 |
| 4000-4999 | 学习相关 |
| 5000-5999 | AI 相关 |
| 6000-6999 | 通知相关 |

---

## 3. 认证授权

### 3.1 用户注册

```http
POST /api/v1/auth/register
```

**请求体**:
```json
{
  "username": "string (required, 3-20 chars)",
  "email": "string (required, email format)",
  "password": "string (required, 8-32 chars)",
  "phone": "string (optional)",
  "inviteCode": "string (optional)"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": "usr_xxx",
    "username": "xxx",
    "email": "xxx@example.com",
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 7200
  }
}
```

### 3.2 用户登录

```http
POST /api/v1/auth/login
```

**请求体**:
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": "usr_xxx",
    "username": "xxx",
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 7200
  }
}
```

### 3.3 刷新 Token

```http
POST /api/v1/auth/refresh
```

**请求头**:
```http
Authorization: Bearer <refresh_token>
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 7200
  }
}
```

### 3.4 登出

```http
POST /api/v1/auth/logout
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```

### 3.5 第三方登录 (微信)

```http
POST /api/v1/auth/wechat
```

**请求体**:
```json
{
  "code": "string (required, 微信授权码)",
  "state": "string (required, 防 CSRF)"
}
```

---

## 4. 用户服务

### 4.1 获取当前用户信息

```http
GET /api/v1/users/me
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": "usr_xxx",
    "username": "xxx",
    "email": "xxx@example.com",
    "phone": "+86 138****0000",
    "avatar": "https://...",
    "role": "student",
    "createdAt": 1710864000000,
    "profile": {
      "grade": "高三",
      "school": "xxx 中学",
      "learningStyle": "visual"
    }
  }
}
```

### 4.2 更新用户信息

```http
PUT /api/v1/users/me
```

**请求体**:
```json
{
  "username": "string (optional)",
  "avatar": "string (optional, URL)",
  "phone": "string (optional)",
  "profile": {
    "grade": "string (optional)",
    "school": "string (optional)",
    "learningStyle": "string (optional)"
  }
}
```

### 4.3 修改密码

```http
PUT /api/v1/users/me/password
```

**请求体**:
```json
{
  "oldPassword": "string (required)",
  "newPassword": "string (required, 8-32 chars)"
}
```

### 4.4 获取用户统计

```http
GET /api/v1/users/me/stats
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "totalLearningDays": 30,
    "totalLearningHours": 120,
    "completedCourses": 5,
    "totalNotes": 50,
    "totalMistakes": 100,
    "achievements": 10
  }
}
```

---

## 5. 课程服务

### 5.1 获取课程列表

```http
GET /api/v1/courses
```

**查询参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 分类筛选 |
| level | string | 难度 (beginner/intermediate/advanced) |
| keyword | string | 搜索关键词 |
| page | integer | 页码 |
| pageSize | integer | 每页数量 |

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "courseId": "crs_xxx",
        "title": "高中数学必修一",
        "description": "...",
        "coverImage": "https://...",
        "category": "math",
        "level": "intermediate",
        "chapterCount": 10,
        "lessonCount": 50,
        "enrolledCount": 1000,
        "rating": 4.8,
        "instructor": {
          "userId": "usr_xxx",
          "name": "张老师",
          "avatar": "https://..."
        },
        "createdAt": 1710864000000
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### 5.2 获取课程详情

```http
GET /api/v1/courses/{courseId}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "courseId": "crs_xxx",
    "title": "高中数学必修一",
    "description": "...",
    "coverImage": "https://...",
    "category": "math",
    "level": "intermediate",
    "tags": ["数学", "高中", "必修"],
    "chapters": [
      {
        "chapterId": "chp_xxx",
        "title": "第一章 集合",
        "order": 1,
        "lessons": [
          {
            "lessonId": "lsn_xxx",
            "title": "1.1 集合的概念",
            "order": 1,
            "duration": 1800,
            "isFree": true
          }
        ]
      }
    ],
    "instructor": {
      "userId": "usr_xxx",
      "name": "张老师",
      "avatar": "https://...",
      "bio": "..."
    },
    "enrolledCount": 1000,
    "rating": 4.8,
    "reviewCount": 200,
    "isEnrolled": false,
    "price": 99.00,
    "createdAt": 1710864000000,
    "updatedAt": 1710864000000
  }
}
```

### 5.3  enroll 课程

```http
POST /api/v1/courses/{courseId}/enroll
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "enrollmentId": "enr_xxx",
    "courseId": "crs_xxx",
    "enrolledAt": 1710864000000
  }
}
```

### 5.4 获取已 enroll 课程

```http
GET /api/v1/users/me/courses
```

---

## 6. 学习服务

### 6.1 创建学习计划

```http
POST /api/v1/learning/plans
```

**请求体**:
```json
{
  "courseId": "crs_xxx",
  "targetHours": 50,
  "startDate": "2026-03-20",
  "endDate": "2026-06-20",
  "dailyGoal": 1,
  "reminderTime": "20:00"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "planId": "pln_xxx",
    "courseId": "crs_xxx",
    "targetHours": 50,
    "startDate": "2026-03-20",
    "endDate": "2026-06-20",
    "dailyGoal": 1,
    "status": "active"
  }
}
```

### 6.2 记录学习进度

```http
POST /api/v1/learning/progress
```

**请求体**:
```json
{
  "courseId": "crs_xxx",
  "lessonId": "lsn_xxx",
  "action": "start|complete",
  "duration": 1800,
  "notes": "optional"
}
```

### 6.3 获取学习进度

```http
GET /api/v1/learning/progress/{courseId}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "courseId": "crs_xxx",
    "totalLessons": 50,
    "completedLessons": 20,
    "progressPercentage": 40,
    "totalDuration": 90000,
    "completedDuration": 36000,
    "lastLessonId": "lsn_xxx",
    "lastLearnedAt": 1710864000000,
    "lessons": [
      {
        "lessonId": "lsn_xxx",
        "title": "1.1 集合的概念",
        "status": "completed",
        "duration": 1800,
        "completedAt": 1710864000000
      }
    ]
  }
}
```

### 6.4 创建笔记

```http
POST /api/v1/learning/notes
```

**请求体**:
```json
{
  "courseId": "crs_xxx",
  "lessonId": "lsn_xxx",
  "content": "markdown content",
  "tags": ["重点", "公式"]
}
```

### 6.5 获取笔记列表

```http
GET /api/v1/learning/notes?courseId=xxx&lessonId=xxx
```

### 6.6 添加收藏

```http
POST /api/v1/learning/favorites
```

**请求体**:
```json
{
  "type": "course|lesson|note",
  "targetId": "xxx"
}
```

### 6.7 添加错题

```http
POST /api/v1/learning/mistakes
```

**请求体**:
```json
{
  "courseId": "crs_xxx",
  "question": "题目内容",
  "userAnswer": "错误答案",
  "correctAnswer": "正确答案",
  "analysis": "解析",
  "tags": ["三角函数", "易错"]
}
```

---

## 7. AI 服务

### 7.1 AI 问答

```http
POST /api/v1/ai/chat
```

**请求体**:
```json
{
  "message": "用户问题",
  "context": {
    "courseId": "crs_xxx (optional)",
    "lessonId": "lsn_xxx (optional)"
  },
  "stream": false
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "conversationId": "conv_xxx",
    "messageId": "msg_xxx",
    "answer": "AI 回答内容",
    "sources": [
      {
        "type": "course",
        "courseId": "crs_xxx",
        "title": "相关课程"
      }
    ],
    "suggestions": [
      "相关问题 1",
      "相关问题 2"
    ]
  }
}
```

### 7.2 AI 流式问答

```http
POST /api/v1/ai/chat/stream
```

**响应** (Server-Sent Events):
```
data: {"type": "start", "conversationId": "conv_xxx"}

data: {"type": "content", "content": "部"}
data: {"type": "content", "content": "分"}
data: {"type": "content", "content": "回"}
data: {"type": "content", "content": "答"}

data: {"type": "end", "messageId": "msg_xxx"}
```

### 7.3 获取对话历史

```http
GET /api/v1/ai/conversations/{conversationId}/messages
```

### 7.4 获取学习建议

```http
POST /api/v1/ai/recommendations/study
```

**请求体**:
```json
{
  "courseId": "crs_xxx",
  "currentProgress": 40,
  "targetDate": "2026-06-20"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "recommendations": [
      {
        "type": "lesson",
        "lessonId": "lsn_xxx",
        "title": "建议学习：二次函数",
        "reason": "这是后续章节的基础",
        "priority": "high"
      },
      {
        "type": "practice",
        "topic": "三角函数",
        "title": "建议练习：三角函数专题",
        "reason": "错题较多，需要加强",
        "priority": "medium"
      }
    ]
  }
}
```

---

## 8. 进度服务

### 8.1 获取学习统计

```http
GET /api/v1/stats/learning
```

**查询参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| range | string | 时间范围 (day/week/month/year) |
| startDate | string | 开始日期 |
| endDate | string | 结束日期 |

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "summary": {
      "totalLearningDays": 30,
      "totalLearningHours": 120,
      "averageDailyHours": 4,
      "completedCourses": 5,
      "completedLessons": 100
    },
    "trend": [
      {
        "date": "2026-03-01",
        "learningHours": 3.5,
        "lessonsCompleted": 2
      },
      {
        "date": "2026-03-02",
        "learningHours": 4.0,
        "lessonsCompleted": 3
      }
    ],
    "byCategory": [
      {
        "category": "math",
        "hours": 50,
        "percentage": 41.7
      },
      {
        "category": "english",
        "hours": 40,
        "percentage": 33.3
      }
    ]
  }
}
```

### 8.2 获取成就列表

```http
GET /api/v1/stats/achievements
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "achievementId": "ach_xxx",
        "name": "学习达人",
        "description": "连续学习 30 天",
        "icon": "https://...",
        "unlockedAt": 1710864000000,
        "progress": 100
      },
      {
        "achievementId": "ach_yyy",
        "name": "课程终结者",
        "description": "完成 10 门课程",
        "icon": "https://...",
        "unlockedAt": null,
        "progress": 50
      }
    ]
  }
}
```

### 8.3 生成学习报告

```http
POST /api/v1/stats/reports
```

**请求体**:
```json
{
  "type": "weekly|monthly",
  "startDate": "2026-03-01",
  "endDate": "2026-03-31"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "reportId": "rpt_xxx",
    "type": "monthly",
    "period": "2026-03",
    "summary": "...",
    "highlights": [...],
    "suggestions": [...],
    "downloadUrl": "https://..."
  }
}
```

---

## 9. 通知服务

### 9.1 获取通知列表

```http
GET /api/v1/notifications
```

**查询参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 类型 (system/learning/promotion) |
| isRead | boolean | 是否已读 |
| page | integer | 页码 |
| pageSize | integer | 每页数量 |

### 9.2 标记通知已读

```http
PUT /api/v1/notifications/{notificationId}/read
```

### 9.3 批量标记已读

```http
PUT /api/v1/notifications/read-all
```

### 9.4 获取未读数量

```http
GET /api/v1/notifications/unread-count
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "count": 5
  }
}
```

---

## 10. WebSocket 实时通信

### 10.1 连接

```
wss://api.eduassistant.com/api/v1/ws
```

**连接参数**:
```
?token=<jwt_token>
```

### 10.2 消息类型

#### 服务器推送

```json
{
  "type": "notification",
  "data": {
    "notificationId": "ntf_xxx",
    "title": "学习提醒",
    "content": "该学习啦！",
    "createdAt": 1710864000000
  }
}
```

```json
{
  "type": "ai_response",
  "data": {
    "conversationId": "conv_xxx",
    "messageId": "msg_xxx",
    "content": "部分回答..."
  }
}
```

```json
{
  "type": "progress_update",
  "data": {
    "courseId": "crs_xxx",
    "progressPercentage": 45
  }
}
```

---

## 11. 错误码字典

### 11.1 通用错误 (1000-1999)

| 错误码 | 说明 |
|--------|------|
| 1000 | 未知错误 |
| 1001 | 参数验证失败 |
| 1002 | 请求过于频繁 |
| 1003 | 服务暂时不可用 |
| 1004 | 版本过低，请更新 |

### 11.2 用户错误 (2000-2999)

| 错误码 | 说明 |
|--------|------|
| 2000 | 用户未登录 |
| 2001 | Token 无效或过期 |
| 2002 | 用户名已存在 |
| 2003 | 邮箱已存在 |
| 2004 | 密码错误 |
| 2005 | 用户不存在 |
| 2006 | 账号已被禁用 |

### 11.3 课程错误 (3000-3999)

| 错误码 | 说明 |
|--------|------|
| 3000 | 课程不存在 |
| 3001 | 章节不存在 |
| 3002 | 课时不存在 |
| 3003 | 未 enroll 该课程 |
| 3004 | 课程已 enroll |

### 11.4 学习错误 (4000-4999)

| 错误码 | 说明 |
|--------|------|
| 4000 | 笔记不存在 |
| 4001 | 无权限访问 |
| 4002 | 学习计划已存在 |

### 11.5 AI 错误 (5000-5999)

| 错误码 | 说明 |
|--------|------|
| 5000 | AI 服务不可用 |
| 5001 | AI 请求超时 |
| 5002 | 超出 AI 使用配额 |
| 5003 | 问题过于敏感 |

---

## 12. 限流策略

| 接口类型 | 限流规则 |
|---------|---------|
| 认证接口 | 10 次/分钟/IP |
| 普通 API | 100 次/分钟/用户 |
| AI 接口 | 20 次/分钟/用户 |
| 文件上传 | 10 次/分钟/用户 |

**限流响应头**:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1710864060
```

---

## 13. 版本管理

- API 版本通过 URL 路径标识：`/api/v1/`
- 向后兼容的变更不升级版本号
- 破坏性变更需要升级版本号 (v2, v3...)
- 旧版本至少支持 6 个月

---

**版本**: v1.0  
**创建日期**: 2026-03-20  
**最后更新**: 2026-03-20  
**维护者**: Tech Lead
