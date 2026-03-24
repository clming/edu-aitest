# 📱 EduAssistant 部署指南

**项目**: EduAssistant (教育助手)  
**版本**: 1.0.0  
**平台**: Android + iOS + Web  
**创建日期**: 2026-03-22

---

## 📋 目录

1. [前置要求](#前置要求)
2. [生成图标和启动屏](#生成图标和启动屏)
3. [Android 编译和部署](#android-编译和部署)
4. [iOS 编译和部署](#ios-编译和部署)
5. [Web 编译和部署](#web-编译和部署)
6. [后端服务部署](#后端服务部署)
7. [生产环境配置](#生产环境配置)

---

## 🎯 前置要求

### Flutter 环境
```bash
# 安装 Flutter (如果未安装)
sudo snap install flutter --classic

# 或从官网下载
# https://flutter.dev/docs/get-started/install

# 验证安装
flutter doctor

# 接受 Android 许可证
flutter doctor --android-licenses
```

### Android 环境
```bash
# 安装 Android Studio
# https://developer.android.com/studio

# 设置 ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### iOS 环境 (仅 macOS)
```bash
# 安装 Xcode (macOS)
# App Store 下载 Xcode

# 安装 CocoaPods
sudo gem install cocoapods

# 设置 iOS 部署
flutter precache --ios
```

---

## 🎨 生成图标和启动屏

### 1. 获取依赖
```bash
cd /root/.openclaw/workspace/projects/edu-aitest/flutter-app
flutter pub get
```

### 2. 生成应用图标
```bash
flutter pub run flutter_launcher_icons
```

**输出**:
- ✅ Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- ✅ iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- ✅ Web: `web/icons/Icon-192.png`, `web/icons/Icon-512.png`

### 3. 生成启动屏
```bash
flutter pub run flutter_native_splash:create
```

**输出**:
- ✅ Android: 自动配置启动屏主题
- ✅ iOS: 自动配置 LaunchScreen
- ✅ Web: 自动修改 index.html

---

## 🤖 Android 编译和部署

### 1. 配置签名

**创建密钥库**:
```bash
keytool -genkey -v -keystore ~/edu-assistant-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias edu-assistant
```

**配置 `android/key.properties`**:
```properties
storePassword=<密钥库密码>
keyPassword=<密钥密码>
keyAlias=edu-assistant
storeFile=/home/<user>/edu-assistant-key.jks
```

**修改 `android/app/build.gradle`**:
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 2. 编译 APK

**Debug APK**:
```bash
flutter build apk --debug
```
输出：`build/app/outputs/flutter-apk/app-debug.apk`

**Release APK**:
```bash
flutter build apk --release
```
输出：`build/app/outputs/flutter-apk/app-release.apk`

**App Bundle (推荐)**:
```bash
flutter build appbundle --release
```
输出：`build/app/outputs/bundle/release/app-release.aab`

### 3. 发布到应用商店

**Google Play**:
1. 登录 [Google Play Console](https://play.google.com/console)
2. 创建应用
3. 上传 `app-release.aab`
4. 填写应用信息
5. 提交审核

**其他应用商店**:
- 华为应用市场
- 小米应用商店
- OPPO 软件商店
- vivo 应用商店

---

## 🍎 iOS 编译和部署

### 1. 配置证书

**在 Xcode 中**:
1. 打开 `ios/Runner.xcworkspace`
2. 选择 Team (Apple Developer Account)
3. 设置 Bundle Identifier
4. 配置 Signing Certificate

### 2. 编译 Archive

```bash
flutter build ios --release
```

**在 Xcode 中**:
1. 打开 `ios/Runner.xcworkspace`
2. 选择 `Generic iOS Device`
3. Product → Archive
4. 在 Organizer 中上传到 App Store

### 3. 发布到 App Store

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 创建新应用
3. 填写应用信息
4. 上传构建版本
5. 提交审核

---

## 🌐 Web 编译和部署

### 1. 编译 Web 版本

```bash
flutter build web --release
```

**输出目录**: `build/web/`

**优化选项**:
```bash
# 启用 CanvasKit (更好的渲染)
flutter build web --release --web-renderer canvaskit

# 启用代码分割
flutter build web --release --split-debug-info=info
```

### 2. 部署到服务器

#### 方案 A: Nginx 部署

**Nginx 配置** (`/etc/nginx/sites-available/edu-assistant`):
```nginx
server {
    listen 80;
    server_name edu-assistant.example.com;
    root /var/www/edu-assistant/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # 启用 Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
```

**部署步骤**:
```bash
# 1. 复制 Web 文件
sudo cp -r build/web/* /var/www/edu-assistant/web/

# 2. 设置权限
sudo chown -R www-data:www-data /var/www/edu-assistant
sudo chmod -R 755 /var/www/edu-assistant

# 3. 启用站点
sudo ln -s /etc/nginx/sites-available/edu-assistant /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 方案 B: Docker 部署

**Dockerfile** (`Dockerfile.web`):
```dockerfile
FROM nginx:alpine

COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**部署**:
```bash
docker build -t edu-assistant-web -f Dockerfile.web .
docker run -d -p 80:80 --name edu-web edu-assistant-web
```

#### 方案 C: 静态托管

**Vercel**:
```bash
npm install -g vercel
cd build/web
vercel --prod
```

**Netlify**:
```bash
npm install -g netlify-cli
cd build/web
netlify deploy --prod
```

**GitHub Pages**:
```bash
# 创建 gh-pages 分支
git checkout -b gh-pages
cp -r build/web/* .
git add .
git commit -m "Deploy web"
git push origin gh-pages
```

### 3. 配置 API 地址

**修改 `lib/services/api_service.dart`**:
```dart
class ApiService {
  // 开发环境
  static const String baseUrl = 'http://localhost:8080';
  
  // 生产环境
  // static const String baseUrl = 'https://api.edu-assistant.com';
}
```

---

## 🐳 后端服务部署

### Docker 部署

**已有配置**:
```bash
cd /root/.openclaw/workspace/projects/edu-aitest/go-backend/build

# 构建镜像
docker build -t edu-assistant-backend:v1.1 -f Dockerfile ..

# 启动容器
docker run -d \
  --name edu-backend \
  --restart always \
  -p 8080:8080 \
  -e DATABASE_URL="mysql://user:pass@host:33060/edu_assistant" \
  -e JWT_SECRET="your-secret-key" \
  -e ENV=production \
  edu-assistant-backend:v1.1
```

### Docker Compose 部署

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  backend:
    image: edu-assistant-backend:v1.1
    container_name: edu-backend
    restart: always
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=mysql://user:pass@db:3306/edu_assistant
      - JWT_SECRET=your-secret-key
      - ENV=production
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: edu-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root-pass
      MYSQL_DATABASE: edu_assistant
      MYSQL_USER: edu-user
      MYSQL_PASSWORD: edu-pass
    volumes:
      - mysql-data:/var/lib/mysql

  web:
    image: edu-assistant-web:v1.1
    container_name: edu-web
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  mysql-data:
```

**部署**:
```bash
docker-compose up -d
```

---

## 🔐 生产环境配置

### 环境变量

**创建 `.env.production`**:
```bash
# API 地址
API_URL=https://api.edu-assistant.com

# JWT 密钥
JWT_SECRET=your-production-secret-key-here

# 数据库
DATABASE_URL=mysql://user:pass@host:3306/edu_assistant

# 邮件通知
SMTP_HOST=smtp.126.com
SMTP_PORT=465
SMTP_USER=your-email@126.com
SMTP_PASSWORD=your-smtp-password
```

### HTTPS 配置

**Let's Encrypt 证书**:
```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d edu-assistant.com -d www.edu-assistant.com

# 自动续期
sudo certbot renew --dry-run
```

### 性能优化

**启用 CDN**:
- Cloudflare
- 阿里云 CDN
- 腾讯云 CDN

**启用缓存**:
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 📊 监控和日志

### 日志查看

**Docker 日志**:
```bash
docker logs -f edu-backend
docker logs -f edu-web
```

**Flutter 错误上报**:
- Sentry
- Firebase Crashlytics

### 性能监控

- Google Analytics
- 百度统计
- 自定义埋点

---

## ✅ 部署检查清单

### Android
- [ ] 生成签名密钥
- [ ] 配置签名
- [ ] 编译 Release APK
- [ ] 测试安装
- [ ] 提交应用商店

### iOS
- [ ] Apple Developer 账号
- [ ] 配置证书
- [ ] 编译 Archive
- [ ] 提交 App Store

### Web
- [ ] 编译 Web 版本
- [ ] 配置域名
- [ ] 配置 Nginx
- [ ] 启用 HTTPS
- [ ] 配置 CDN

### 后端
- [ ] Docker 镜像构建
- [ ] 数据库配置
- [ ] 环境变量配置
- [ ] 健康检查
- [ ] 日志配置

---

**文档版本**: v1.0  
**创建时间**: 2026-03-22  
**维护人**: AI Flutter Developer
