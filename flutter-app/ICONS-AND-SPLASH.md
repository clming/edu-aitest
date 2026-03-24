# Flutter 图标和启动屏配置

## 📱 应用图标配置

### 1. 添加依赖

在 `pubspec.yaml` 的 `dev_dependencies` 中添加：

```yaml
dev_dependencies:
  flutter_launcher_icons: "^0.13.1"
  flutter_native_splash: "^2.3.0"

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
    background_color: "#667eea"
    theme_color: "#667eea"
  windows:
    generate: true
    image_path: "assets/icons/app_icon.png"
  macos:
    generate: true
    image_path: "assets/icons/app_icon.png"
```

### 2. 准备图标源文件

准备一个 **1024x1024** 的 PNG 图标文件，放在：
```
assets/icons/app_icon.png
```

### 3. 生成图标

运行命令：
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### 4. 生成的图标位置

**Android**:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

**iOS**:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Web**:
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`

---

## 🚀 启动屏配置

### 1. 添加配置

在 `pubspec.yaml` 中添加：

```yaml
flutter_native_splash:
  color: "#667eea"
  color_dark: "#764ba2"
  image: "assets/icons/splash_icon.png"
  image_dark: "assets/icons/splash_icon_dark.png"
  
  # Android
  android: true
  android_12:
    image: "assets/icons/splash_icon.png"
    icon_background_color: "#667eea"
    image_dark: "assets/icons/splash_icon_dark.png"
    icon_background_color_dark: "#764ba2"
  
  # iOS
  ios: true
  
  # Web
  web: true
  web_image_mode: center
  web_color: "#667eea"
  web_color_dark: "#764ba2"
  
  # 全屏模式
  fullscreen: true
  
  # 品牌标识
  brand: "assets/icons/brand.png"
  brand_dark: "assets/icons/brand_dark.png"
```

### 2. 准备启动屏图标

准备一个 **288x288** 的 PNG 图标文件：
```
assets/icons/splash_icon.png
assets/icons/splash_icon_dark.png (深色模式)
```

### 3. 生成启动屏

运行命令：
```bash
flutter pub run flutter_native_splash:create
```

### 4. 生成的文件

**Android**:
- 自动修改 `AndroidManifest.xml`
- 生成启动屏主题

**iOS**:
- 修改 `LaunchScreen.storyboard`

**Web**:
- 修改 `web/index.html`

---

## 🎨 图标设计建议

### 应用图标 (1024x1024)
- 简洁明了
- 避免文字
- 使用品牌色 (#667eea, #764ba2)
- 圆角或方形均可 (系统会自动处理)

### 启动屏图标 (288x288)
- 可以是应用图标的简化版
- 白色或浅色背景
- 居中放置

---

## 📦 完整配置示例

```yaml
name: edu_assistant
description: EduAssistant - 教育助手

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_riverpod: ^2.4.9
  go_router: ^13.0.0
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: "^0.13.1"
  flutter_native_splash: "^2.3.0"

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/icons/splash_icon.png

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
    background_color: "#667eea"
    theme_color: "#667eea"

flutter_native_splash:
  color: "#667eea"
  color_dark: "#764ba2"
  image: "assets/icons/splash_icon.png"
  image_dark: "assets/icons/splash_icon_dark.png"
  android: true
  ios: true
  web: true
  fullscreen: true
```

---

## 🚀 一键生成脚本

创建 `scripts/generate_assets.sh`:

```bash
#!/bin/bash

echo "🎨 生成应用图标..."
flutter pub run flutter_launcher_icons

echo "🚀 生成启动屏..."
flutter pub run flutter_native_splash:create

echo "✅ 完成！"
```

运行：
```bash
chmod +x scripts/generate_assets.sh
./scripts/generate_assets.sh
```

---

## 📝 注意事项

1. **图标尺寸要求**:
   - 应用图标：1024x1024 PNG
   - 启动屏图标：288x288 PNG

2. **颜色配置**:
   - 主色：#667eea (渐变紫蓝)
   - 深色：#764ba2 (渐变紫)

3. **运行环境**:
   - 需要先安装 Flutter SDK
   - 运行 `flutter pub get` 获取依赖

4. **多端适配**:
   - Android: API 21+
   - iOS: iOS 12+
   - Web: 现代浏览器

---

**创建时间**: 2026-03-22  
**维护人**: AI Flutter Developer
