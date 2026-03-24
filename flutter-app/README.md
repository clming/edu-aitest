# EduAssistant - 教育助手

一个基于 Flutter 3.x 的教育类应用，支持 iOS、Android、Web 三端合一。

## 📱 项目简介

EduAssistant 是一款参考"作业帮家长版"设计的教育管理应用，帮助学生、老师和家长更好地管理学习和作业。

### 核心功能

- **用户认证**: 登录、注册、Token 管理
- **作业管理**: 创建、查看、提交、批改作业
- **学生管理**: 学生列表、详情、成绩查看
- **学习报告**: 周报、月报、统计分析
- **个人中心**: 个人信息、设置、退出登录

### 支持角色

- 👨‍🎓 **学生**: 查看和完成作业
- 👨‍🏫 **老师**: 布置和管理作业
- 👨‍👩‍👧 **家长**: 查看孩子的学习情况

## 🏗️ 技术架构

### 技术栈

- **Flutter**: 3.x (iOS + Android + Web)
- **状态管理**: Riverpod
- **路由管理**: GoRouter
- **网络请求**: Dio
- **本地存储**: Hive + SharedPreferences
- **后端 API**: Go (已部署在 http://localhost:8080)

### 项目结构

```
lib/
├── config/              # 配置文件
│   ├── theme_config.dart    # 主题配置
│   └── router_config.dart   # 路由配置
├── models/              # 数据模型
│   ├── user_model.dart      # 用户模型
│   └── homework_model.dart  # 作业模型
├── providers/           # 状态管理
│   ├── auth_provider.dart   # 认证状态
│   └── homework_provider.dart # 作业状态
├── screens/             # 页面
│   ├── login_screen.dart      # 登录页
│   ├── register_screen.dart   # 注册页
│   ├── home_screen.dart       # 首页
│   ├── homework_list_screen.dart  # 作业列表
│   ├── homework_detail_screen.dart # 作业详情
│   ├── student_list_screen.dart  # 学生列表
│   ├── report_screen.dart       # 学习报告
│   └── profile_screen.dart      # 个人中心
├── services/            # 服务层
│   ├── api_service.dart     # API 服务
│   └── storage_service.dart # 存储服务
├── widgets/             # 通用组件
│   └── common_widgets.dart  # 通用组件
├── utils/               # 工具函数
│   └── helpers.dart         # 辅助函数
└── main.dart            # 应用入口
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- 后端 API 服务运行在 http://localhost:8080

### 安装依赖

```bash
flutter pub get
```

### 运行应用

#### Android

```bash
flutter run -d android
```

#### iOS

```bash
flutter run -d ios
```

#### Web

```bash
flutter run -d chrome
```

### 构建发布

#### Android

```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

#### Web

```bash
flutter build web --release
```

## 📋 功能模块

### 1. 认证模块

- ✅ 登录
- ✅ 注册
- ✅ 登出
- ✅ Token 自动管理
- ✅ Token 自动刷新
- ⏳ 修改密码
- ⏳ 忘记密码

### 2. 作业模块

- ✅ 作业列表
- ✅ 作业详情
- ✅ 创建作业 (老师)
- ✅ 编辑作业 (老师)
- ✅ 删除作业 (老师)
- ✅ 提交作业 (学生)
- ✅ 批改查看 (老师)
- ⏳ 作业附件上传
- ⏳ 作业评语

### 3. 学生模块

- ✅ 学生列表
- ✅ 学生详情
- ✅ 成绩查看
- ✅ 作业完成率统计
- ⏳ 添加学生
- ⏳ 编辑学生信息

### 4. 报告模块

- ✅ 学习概览
- ✅ 周报
- ✅ 月报
- ✅ 科目分布
- ✅ 统计图表
- ⏳ 导出报告

### 5. 设置模块

- ✅ 个人信息查看
- ✅ 退出登录
- ⏳ 编辑资料
- ⏳ 修改密码
- ⏳ 消息通知设置
- ⏳ 关于我们

## 🎨 UI/UX 特性

- ✅ Material Design 3
- ✅ 响应式设计 (适配手机、平板、Web)
- ✅ 加载动画
- ✅ 错误提示
- ✅ 空状态处理
- ✅ 下拉刷新
- ✅ 上拉加载更多
- ✅ 主题配色 (教育蓝)

## 🔌 API 集成

### 基础配置

API 基础 URL 根据环境自动配置:

- **开发环境**: 
  - Android: http://10.0.2.2:8080/api/v1
  - iOS/Web: http://localhost:8080/api/v1
- **生产环境**: https://api.edu-assistant.com/api/v1

### API 特性

- ✅ Token 自动添加到请求头
- ✅ Token 自动刷新
- ✅ 错误处理和重试机制
- ✅ 请求/响应日志 (开发环境)
- ✅ 统一的错误处理

### 主要 API 端点

```
认证:
  POST /api/v1/auth/login      - 登录
  POST /api/v1/auth/register   - 注册
  POST /api/v1/auth/logout     - 登出
  POST /api/v1/auth/refresh    - 刷新 Token
  GET  /api/v1/auth/me         - 获取当前用户
  PUT  /api/v1/auth/password   - 修改密码

作业:
  GET    /api/v1/homework      - 获取作业列表
  GET    /api/v1/homework/:id  - 获取作业详情
  POST   /api/v1/homework      - 创建作业
  PUT    /api/v1/homework/:id  - 更新作业
  DELETE /api/v1/homework/:id  - 删除作业
  POST   /api/v1/homework/:id/submit - 提交作业

学生:
  GET    /api/v1/students      - 获取学生列表
  GET    /api/v1/students/:id  - 获取学生详情
  POST   /api/v1/students      - 创建学生

报告:
  GET /api/v1/reports/weekly   - 获取周报
  GET /api/v1/reports/monthly  - 获取月报
  GET /api/v1/reports/statistics - 获取统计报告
```

## 🧪 测试

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/model_test.dart
flutter test test/utils_test.dart
```

### 测试覆盖率

```bash
flutter test --coverage
```

## 📦 多端适配

### Android

- ✅ 权限配置
- ⏳ 应用图标
- ⏳ 启动屏
- ⏳ 签名配置

### iOS

- ✅ 权限配置
- ⏳ 应用图标
- ⏳ 启动屏
- ⏳ 签名配置

### Web

- ✅ 响应式布局
- ⏳ SEO 优化
- ⏳ PWA 支持

## 🛠️ 开发指南

### 代码规范

- 使用 Dart 官方代码规范
- 使用 `flutter_lints` 进行代码检查
- 所有公共 API 必须有文档注释

### 状态管理

使用 Riverpod 进行状态管理:

```dart
// 定义 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// 在 Widget 中使用
final authState = ref.watch(authProvider);
final authNotifier = ref.read(authProvider.notifier);
```

### 路由导航

使用 GoRouter 进行路由管理:

```dart
// 命名路由
context.goNamed('login');

// 路径路由
context.go('/home');

// 带参数
context.go('/home/homework/${homework.id}');
```

## 📝 待办事项

- [ ] 完善所有页面的 UI
- [ ] 实现所有 API 接口
- [ ] 添加更多单元测试
- [ ] 完善多端适配
- [ ] 添加国际化支持
- [ ] 性能优化
- [ ] 添加动画效果
- [ ] 完善错误处理

## 📄 许可证

本项目仅供学习参考使用。

## 👥 贡献

欢迎提交 Issue 和 Pull Request!

## 📧 联系方式

如有问题，请联系开发团队。
