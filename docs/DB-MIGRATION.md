# 🗄️ 数据库自动迁移指南

**项目**: EduAssistant (教育助手)  
**数据库**: MySQL  
**创建日期**: 2026-03-20  
**版本**: v1.1

---

## 📊 数据库信息

| 配置项 | 值 |
|--------|-----|
| **数据库类型** | MySQL 8.0 |
| **主机地址** | mysql-2a840bd18e4b-public.rds.volces.com |
| **端口** | 33060 |
| **数据库名** | edu_assistant |
| **用户名** | openclaw-edutest |
| **字符集** | utf8mb4 |
| **排序规则** | utf8mb4_unicode_ci |

---

## ✨ 自动迁移特性

### 1. 自动创建数据库

系统首次启动时，如果数据库不存在会自动创建：

```sql
CREATE DATABASE IF NOT EXISTS `edu_assistant` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

**实现位置**: `internal/database/database.go` - `createDatabaseIfNotExists()`

---

### 2. 自动创建表

系统启动时，如果模型对应的表不存在会自动创建：

```go
DB.AutoMigrate(&models.User{})
// 如果 users 表不存在，自动创建
```

**示例 - User 表结构**:
```sql
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'student',
  PRIMARY KEY (`id`),
  KEY `idx_users_deleted_at` (`deleted_at`),
  UNIQUE KEY `uni_users_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 3. 自动添加字段

版本迭代时，如果模型添加了新字段，会自动添加到现有表：

**v1.0 模型**:
```go
type User struct {
    ID       uint   `gorm:"primaryKey"`
    Username string `gorm:"unique;size:50"`
}
```

**v1.1 模型** (新增 email 字段):
```go
type User struct {
    ID       uint   `gorm:"primaryKey"`
    Username string `gorm:"unique;size:50"`
    Email    string `gorm:"size:100"`  // ← 新增字段
}
```

**自动执行的 SQL**:
```sql
ALTER TABLE `users` ADD COLUMN `email` varchar(100) DEFAULT NULL;
```

**实现原理**: GORM 的 `AutoMigrate` 会对比模型和表结构，自动添加缺失的字段。

---

### 4. 自动创建新表

版本迭代时，如果添加了新模型，会自动创建新表：

**v1.2 新增模型**:
```go
// pkg/models/course.go
type Course struct {
    ID          uint   `gorm:"primaryKey"`
    Title       string `gorm:"size:100"`
    Description string `gorm:"type:text"`
    TeacherID   uint
    CreatedAt   time.Time
    UpdatedAt   time.Time
}
```

**在 `database.go` 中添加**:
```go
DB.AutoMigrate(
    &models.User{},
    &models.Homework{},
    &models.Student{},
    &models.Report{},
    &models.Course{},  // ← 新增模型
)
```

**自动执行的 SQL**:
```sql
CREATE TABLE `courses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text,
  `teacher_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_courses_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔧 使用指南

### 添加新表

**步骤 1**: 在 `pkg/models/` 目录创建新模型

```go
// pkg/models/course.go
package models

import "time"

type Course struct {
    ID          uint   `gorm:"primaryKey"`
    Title       string `gorm:"size:100;not null"`
    Description string `gorm:"type:text"`
    TeacherID   uint   `gorm:"not null"`
    Credits     int    `gorm:"default:0"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   gorm.DeletedAt `gorm:"index"`
}
```

**步骤 2**: 在 `internal/database/database.go` 中注册

```go
// internal/database/database.go
func Init(dsn string) error {
    // ...
    
    if err := DB.AutoMigrate(
        &models.User{},
        &models.Homework{},
        &models.Student{},
        &models.Report{},
        &models.Course{},  // ← 添加新模型
    ); err != nil {
        return err
    }
    
    // ...
}
```

**步骤 3**: 重启服务

```bash
go run cmd/main.go
```

系统会自动创建 `courses` 表！

---

### 添加新字段

**步骤 1**: 在模型中添加字段

```go
// pkg/models/user.go
type User struct {
    ID        uint   `gorm:"primaryKey"`
    Username  string `gorm:"unique;size:50"`
    Email     string `gorm:"size:100"`  // ← 新增字段
    Phone     string `gorm:"size:20"`   // ← 新增字段
    Password  string `gorm:"size:255"`
    // ...
}
```

**步骤 2**: 重启服务

```bash
go run cmd/main.go
```

系统会自动执行：
```sql
ALTER TABLE `users` ADD COLUMN `email` varchar(100);
ALTER TABLE `users` ADD COLUMN `phone` varchar(20);
```

---

## ⚠️ 注意事项

### 1. 不会删除字段

GORM 的 `AutoMigrate` **不会删除**已存在的字段或表，这是安全的设计。

如果需要删除字段，需要手动执行 SQL：

```sql
ALTER TABLE `users` DROP COLUMN `old_field`;
```

### 2. 字段类型修改

如果修改字段类型（如 `int` → `string`），`AutoMigrate` 可能不会自动处理。

**建议做法**:
1. 添加新字段
2. 迁移数据
3. 删除旧字段

### 3. 索引和约束

`AutoMigrate` 会自动创建索引和约束，但修改索引需要手动处理。

**添加索引**:
```go
type User struct {
    Email string `gorm:"size:100;index"`  // ← 添加索引
}
```

**添加唯一约束**:
```go
type User struct {
    Username string `gorm:"size:50;unique"`  // ← 唯一约束
}
```

---

## 📝 版本迁移记录

### v1.0 → v1.1

**新增字段**:
- `users.password_hash` - 密码哈希
- `homeworks.teacher_id` - 布置作业的老师
- `students.parent_id` - 家长关联

**新增表**:
- `reports` - 学习报告表

**迁移 SQL**:
```sql
-- 新增字段
ALTER TABLE `users` ADD COLUMN `password_hash` varchar(255);
ALTER TABLE `homeworks` ADD COLUMN `teacher_id` bigint unsigned;
ALTER TABLE `students` ADD COLUMN `parent_id` bigint unsigned;

-- 新增表
CREATE TABLE `reports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `student_id` bigint unsigned,
  `week` int,
  `study_hours` int,
  `completed_homeworks` int,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 🔍 验证迁移

### 查看表结构

```bash
mysql -h mysql-2a840bd18e4b-public.rds.volces.com -P 33060 -u openclaw-edutest -p

USE edu_assistant;
SHOW TABLES;
DESCRIBE users;
```

### 查看迁移日志

启动服务时会看到：

```
🔧 检查并创建数据库...
✅ 数据库 'edu_assistant' 已存在
🔧 执行数据库自动迁移...
✅ 数据库初始化成功（自动创建表 + 自动添加字段）
```

---

## 🚀 最佳实践

1. **版本控制** - 每次修改模型都记录在文档中
2. **测试环境** - 先在测试环境验证迁移
3. **备份数据** - 生产环境迁移前备份数据
4. **回滚计划** - 准备回滚 SQL 脚本
5. **逐步发布** - 分批次发布，观察迁移效果

---

## 📞 相关文档

- `go-backend/.env.example` - 环境变量配置
- `docs/bug/VERSION-TRACKING.md` - 版本追踪
- `pkg/models/` - 数据模型定义

---

**文档版本**: v1.1  
**创建时间**: 2026-03-20  
**维护人**: AI Developer Agent
