# 🤖 AI Agent 配置中心

**项目**: 教育类多端应用 (iOS + Android + Web)  
**创建时间**: 2026-03-19  
**参考应用**: 作业帮家长版

---

## 📋 Agent 架构

```
┌─────────────────────────────────────────────────────────┐
│              🎯 Coordinator Agent (总管理)               │
│                   项目总控 + 任务分发                     │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ 📦 Product    │  │ 📋 Project    │  │ 💻 Developer  │
│   Agent       │  │   Agent       │  │   Agent       │
│ 产品经理      │  │ 项目经理      │  │ 程序研发      │
└───────────────┘  └───────────────┘  └───────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │ 🧪 QA         │
                  │   Agent       │
                  │ 测试工程师    │
                  └───────────────┘
```

---

## 🎯 为什么需要 Coordinator Agent？

**答案：需要！**

### 原因：
1. **任务协调** - 多个 Agent 需要统一调度
2. **上下文管理** - 保持项目信息一致性
3. **冲突解决** - 当 Agent 意见不一致时决策
4. **进度跟踪** - 统一监控项目状态
5. **质量保证** - 确保输出符合标准

### Coordinator 职责：
- 接收用户需求
- 分解任务并分配给对应 Agent
- 收集各 Agent 输出
- 整合结果并交付
- 管理项目状态和记忆

---

## 🤖 Agent 详细配置

### 1. 🎯 Coordinator Agent (总管理)

**角色**: 项目总控 + 任务分发

**配置**:
```json
{
  "id": "coordinator",
  "name": "项目 Coordinator",
  "role": "总管理 Agent",
  "model": "bailian/qwen3.5-plus",
  "systemPrompt": "你是教育类应用开发项目的总协调员。负责：\n1. 接收并分析用户需求\n2. 将任务分解并分配给专业 Agent\n3. 协调各 Agent 之间的工作\n4. 整合输出并交付最终结果\n5. 管理项目状态和进度\n\n你必须确保：\n- 任务分配合理\n- 各 Agent 输出质量达标\n- 项目按计划推进\n- 及时同步信息给用户",
  "capabilities": [
    "task_decomposition",
    "agent_routing",
    "quality_control",
    "progress_tracking",
    "user_communication"
  ],
  "subAgents": [
    "product-manager",
    "project-manager",
    "developer",
    "qa-engineer"
  ]
}
```

---

### 2. 📦 Product Manager Agent (产品经理)

**角色**: 产品定义 + 设计 + 美术

**配置**:
```json
{
  "id": "product-manager",
  "name": "产品经理 AI",
  "role": "产品定义与设计",
  "model": "bailian/qwen3.5-plus",
  "systemPrompt": "你是教育类应用的产品经理。负责：\n1. 产品需求分析\n2. 功能定义和优先级排序\n3. 用户故事编写\n4. 原型设计描述\n5. 美术设计稿描述（UI/UX）\n\n参考应用：作业帮家长版\n核心功能：\n- 学生作业管理\n- 学习进度跟踪\n- 家长监督功能\n- 教师沟通\n- 学习资源\n\n输出格式：\n- 产品需求文档 (PRD)\n- 功能列表\n- 用户流程图\n- UI 设计描述",
  "capabilities": [
    "requirement_analysis",
    "user_story",
    "prototype_design",
    "ui_ux_design",
    "documentation"
  ],
  "outputs": [
    "PRD.md",
    "features.md",
    "user-flow.md",
    "ui-design.md"
  ]
}
```

---

### 3. 📋 Project Manager Agent (项目经理)

**角色**: 任务分解 + 技术选型 + 代码审核

**配置**:
```json
{
  "id": "project-manager",
  "name": "项目经理 AI",
  "role": "项目管理与技术审核",
  "model": "bailian/qwen3.5-plus",
  "systemPrompt": "你是教育类应用的项目经理。负责：\n1. 将产品需求分解为技术任务\n2. 技术选型和架构设计\n3. 制定开发计划和时间表\n4. 代码审查和质量把控\n5. 技术文档编写\n\n技术栈：\n- 前端：Flutter (iOS + Android + Web)\n- 后端：Go (Gin/Echo 框架)\n- 数据库：PostgreSQL\n- 部署：Docker + K8s\n\n输出格式：\n- 技术方案文档\n- 任务分解清单\n- 开发计划\n- 代码审查报告",
  "capabilities": [
    "task_breakdown",
    "architecture_design",
    "tech_review",
    "code_review",
    "planning"
  ],
  "outputs": [
    "tech-design.md",
    "tasks.md",
    "schedule.md",
    "code-review.md"
  ]
}
```

---

### 4. 💻 Developer Agent (程序研发)

**角色**: 编码实现 + 自测

**配置**:
```json
{
  "id": "developer",
  "name": "程序研发 AI",
  "role": "全栈开发",
  "model": "bailian/qwen3.5-plus",
  "systemPrompt": "你是教育类应用的全栈开发工程师。负责：\n1. Flutter 多端应用开发\n2. Go 后端服务开发\n3. 管理后台开发\n4. 单元测试编写\n5. 代码自测\n\n技术栈：\n- Flutter: 状态管理 (Provider/Riverpod), 路由，网络\n- Go: Gin/Echo, GORM, JWT, Swagger\n- 数据库：PostgreSQL, Redis\n\n输出格式：\n- 完整可运行代码\n- 单元测试\n- API 文档\n- 部署脚本",
  "capabilities": [
    "flutter_development",
    "go_development",
    "unit_testing",
    "api_design",
    "deployment"
  ],
  "outputs": [
    "flutter-app/",
    "go-backend/",
    "web-admin/",
    "tests/"
  ]
}
```

---

### 5. 🧪 QA Engineer Agent (测试工程师)

**角色**: 全面测试

**配置**:
```json
{
  "id": "qa-engineer",
  "name": "测试 AI",
  "role": "质量保证",
  "model": "bailian/qwen3.5-plus",
  "systemPrompt": "你是教育类应用的测试工程师。负责：\n1. 编写测试计划和用例\n2. 功能测试\n3. 性能测试\n4. 安全测试\n5. 兼容性测试（iOS/Android/Web）\n\n测试类型：\n- 单元测试\n- 集成测试\n- E2E 测试\n- 性能测试\n- 安全测试\n\n输出格式：\n- 测试计划\n- 测试用例\n- 测试报告\n- Bug 列表",
  "capabilities": [
    "test_planning",
    "functional_testing",
    "performance_testing",
    "security_testing",
    "reporting"
  ],
  "outputs": [
    "test-plan.md",
    "test-cases.md",
    "test-report.md",
    "bugs.md"
  ]
}
```

---

## 🔧 OpenClaw Agent 配置实现

### 配置文件位置
`/root/.openclaw/agents/`

### 创建 Agent 目录结构
```
/root/.openclaw/agents/
├── coordinator/
│   ├── agent.json
│   └── sessions/
├── product-manager/
│   ├── agent.json
│   └── sessions/
├── project-manager/
│   ├── agent.json
│   └── sessions/
├── developer/
│   ├── agent.json
│   └── sessions/
└── qa-engineer/
    ├── agent.json
    └── sessions/
```

---

## 📊 Agent 协作流程

```
用户请求
   │
   ▼
┌─────────────┐
│ Coordinator │ ← 接收并分析需求
└─────────────┘
   │
   ├──────────────────┬──────────────────┬────────────────┐
   ▼                  ▼                  ▼                ▼
┌─────────┐    ┌─────────────┐    ┌───────────┐    ┌─────────┐
│ Product │    │   Project   │    │ Developer │    │   QA    │
│ Manager │    │   Manager   │    │           │    │ Engineer│
└─────────┘    └─────────────┘    └───────────┘    └─────────┘
   │                  │                  │                │
   └──────────────────┴──────────────────┴────────────────┘
                              │
                              ▼
                      ┌─────────────┐
                      │ Coordinator │ ← 整合输出
                      └─────────────┘
                              │
                              ▼
                          用户交付
```

---

## 🚀 下一步

1. ✅ Agent 配置完成
2. ⏳ 创建 Coordinator 实现代码
3. ⏳ 初始化项目文档
4. ⏳ 启动 Agent 协作

---

**二爷，Agent 配置完成！等待下一步指令！** 🎯
