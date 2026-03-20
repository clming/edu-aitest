# 📧 邮件通知配置指南

**项目**: EduAssistant (教育助手)  
**配置日期**: 2026-03-20  
**版本**: v1.1

---

## ✅ 配置完成

**二爷，邮件通知服务已配置完成！**

---

## 📊 配置信息

### SMTP 配置

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **SMTP 服务器** | smtp.126.com | ✅ |
| **SMTP 端口** | 465 (SSL) | ✅ |
| **发件邮箱** | cao_lianming@126.com | ✅ |
| **SMTP 授权码** | AUVd4SYdy2XuYR8S | ✅ |
| **发件人名称** | EduAssistant 通知 | ✅ |

### 收件人配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **收件邮箱** | clm@gwsvip.com | 二爷的邮箱 |
| **收件人名称** | 二爷 | - |

---

## 🎯 通知类型

系统支持 4 种通知类型：

### 1. 任务完成通知 ✅

**触发场景**: Agent 完成任务时

**示例**:
```
主题：✅ 任务完成通知：数据库配置

内容：
二爷，任务已完成！
任务名称：数据库配置
详细信息：数据库连接已配置完成，自动迁移功能已启用。
状态：已完成
```

### 2. Bug 通知 🐛

**触发场景**: QA 发现 Bug 时

**示例**:
```
主题：🐛 Bug 通知：BUG-001 - Critical

内容：
二爷，发现新的 Bug！
Bug ID: BUG-001
严重程度：Critical
问题描述：JWT 密钥硬编码导致安全风险
状态：待修复
```

### 3. 里程碑通知 🎉

**触发场景**: 项目版本发布时

**示例**:
```
主题：🎉 项目里程碑：v1.1 发布

内容：
二爷，项目达成新里程碑！
版本：v1.1
版本摘要：Bug 修复版本，14 个 Bug 全部修复完成。
状态：已发布
```

### 4. 自定义通知 📬

**触发场景**: 需要通知二爷的任何其他情况

---

## 📝 使用示例

### Go 代码中使用

```go
package main

import (
    "github.com/clming/edu-aitest/go-backend/internal/config"
)

func main() {
    // 1. 发送任务完成通知
    config.SendTaskCompleteNotification(
        "数据库配置",
        "数据库连接已配置完成",
    )
    
    // 2. 发送 Bug 通知
    config.SendBugNotification(
        "BUG-001",
        "Critical",
        "JWT 密钥硬编码",
    )
    
    // 3. 发送里程碑通知
    config.SendMilestoneNotification(
        "v1.1",
        "14 个 Bug 全部修复",
    )
    
    // 4. 发送自定义通知
    config.SendNotification(
        "自定义主题",
        "自定义内容",
    )
}
```

### 测试邮件

```bash
# 进入项目目录
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend

# 运行测试脚本
go run cmd/test-email.go
```

测试会发送 4 封邮件：
1. 基础邮件测试
2. 任务完成通知
3. Bug 通知
4. 里程碑通知

---

## 🔧 环境变量配置

### .env 文件

```bash
# 邮件通知配置
SMTP_HOST=smtp.126.com
SMTP_PORT=465
SMTP_USER=cao_lianming@126.com
SMTP_PASSWORD=AUVd4SYdy2XuYR8S
FROM_EMAIL=cao_lianming@126.com
FROM_NAME=EduAssistant 通知
ADMIN_EMAIL=clm@gwsvip.com
ADMIN_NAME=二爷
```

### 生产环境

```bash
# 设置环境变量
export SMTP_HOST=smtp.126.com
export SMTP_PORT=465
export SMTP_USER=cao_lianming@126.com
export SMTP_PASSWORD=AUVd4SYdy2XuYR8S
```

---

## 📋 通知策略

### 立即通知

以下情况会**立即**发送邮件：

1. ✅ **任务完成** - 每个 Agent 完成任务后
2. 🐛 **Critical Bug** - 发现严重 Bug 时
3. 🎉 **版本发布** - 新版本发布时
4. ⚠️ **系统错误** - 服务异常时

### 批量通知

以下情况会**汇总后**发送：

1. 📊 **每日报告** - 每天 20:00 发送当日总结
2. 🐛 **普通 Bug** - 每发现 3 个 Medium/Low Bug 汇总发送
3. 📈 **周报** - 每周一发送上周总结

---

## 🎨 邮件模板

### HTML 样式

邮件使用精美的 HTML 模板：

- **渐变头部** - 紫色渐变背景
- **状态标签** - 不同颜色表示不同状态
- **响应式设计** - 适配手机和电脑
- **品牌标识** - EduAssistant Logo

### 示例效果

```
┌─────────────────────────────────────┐
│  🎓 EduAssistant 通知               │
│  (紫色渐变背景)                     │
├─────────────────────────────────────┤
│                                     │
│  二爷，任务已完成！                 │
│                                     │
│  任务名称：数据库配置               │
│  详细信息：...                      │
│                                     │
│  [✅ 已完成] (绿色标签)             │
│                                     │
├─────────────────────────────────────┤
│  此邮件由 EduAssistant 系统自动发送 │
│  github.com/clming/edu-aitest       │
└─────────────────────────────────────┘
```

---

## ⚠️ 注意事项

### SMTP 授权码

- **不是登录密码**！需要在 126 邮箱设置中生成
- 授权码会定期过期，过期后需要重新生成
- 不要泄露授权码，相当于密码

### 发送限制

126 邮箱 SMTP 发送限制：
- 每日发送上限：500 封
- 单封邮件大小：50MB
- 附件大小：50MB

### 故障排查

**如果邮件发送失败**：

1. 检查 SMTP 授权码是否正确
2. 检查网络连接
3. 检查收件邮箱地址
4. 查看日志中的错误信息

---

## 📞 测试验证

### 手动测试

```bash
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend
go run cmd/test-email.go
```

### 验证步骤

1. 运行测试脚本
2. 检查邮箱 `clm@gwsvip.com`
3. 应该收到 4 封测试邮件
4. 检查邮件格式和内容

---

## 🚀 下一步

1. ✅ 邮件配置完成
2. ⏳ 测试邮件发送
3. ⏳ 集成到 Agent 工作流
4. ⏳ 设置通知触发规则

---

**二爷，邮件通知服务已就绪！** 📧

**请检查邮箱 clm@gwsvip.com 是否收到测试邮件！**

---

**文档版本**: v1.1  
**创建时间**: 2026-03-20  
**维护人**: AI Developer Agent
