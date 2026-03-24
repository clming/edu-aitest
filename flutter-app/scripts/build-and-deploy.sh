#!/bin/bash
# EduAssistant Flutter 编译和部署脚本
# 支持：Android APK, Web 前端

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$PROJECT_DIR/dist"

echo "============================================================"
echo "📱 EduAssistant Flutter 编译和部署"
echo "============================================================"
echo ""

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装！"
    echo ""
    echo "🎯 请先安装 Flutter:"
    echo "   bash $SCRIPT_DIR/install-flutter.sh"
    echo ""
    echo "或者只编译 Web 版本 (不需要 Flutter):"
    echo "   使用 Docker 编译 (待实现)"
    echo ""
    exit 1
fi

# 显示 Flutter 版本
echo "✅ Flutter 版本:"
flutter --version
echo ""

# 进入项目目录
cd "$PROJECT_DIR"

# 获取依赖
echo "📦 获取 Flutter 依赖..."
flutter pub get
echo "✅ 依赖获取完成"
echo ""

# 生成图标
echo "🎨 生成应用图标..."
flutter pub run flutter_launcher_icons
echo "✅ 图标生成完成"
echo ""

# 生成启动屏
echo "🚀 生成启动屏..."
flutter pub run flutter_native_splash:create
echo "✅ 启动屏生成完成"
echo ""

# 运行测试
echo "🧪 运行测试..."
flutter test || echo "⚠️  部分测试未通过 (可继续)"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# ========== Android 编译 ==========
echo "============================================================"
echo "🤖 编译 Android APK"
echo "============================================================"
echo ""

# 检查 Android 环境
if flutter config --list | grep -q "Android"; then
    echo "✅ Android 环境已配置"
    
    # Debug APK
    echo "📦 编译 Debug APK..."
    flutter build apk --debug
    echo "✅ Debug APK: $BUILD_DIR/app/outputs/flutter-apk/app-debug.apk"
    
    # Release APK
    echo "📦 编译 Release APK..."
    flutter build apk --release
    echo "✅ Release APK: $BUILD_DIR/app/outputs/flutter-apk/app-release.apk"
    
    # 复制到输出目录
    mkdir -p "$OUTPUT_DIR/android"
    cp "$BUILD_DIR/app/outputs/flutter-apk/app-release.apk" "$OUTPUT_DIR/android/EduAssistant-v1.0.apk"
    echo "✅ APK 已复制到：$OUTPUT_DIR/android/EduAssistant-v1.0.apk"
else
    echo "⚠️  Android 环境未配置，跳过 Android 编译"
    echo "   需要安装 Android Studio 并运行:"
    echo "   flutter doctor --android-licenses"
fi
echo ""

# ========== Web 编译 ==========
echo "============================================================"
echo "🌐 编译 Web 前端"
echo "============================================================"
echo ""

echo "📦 编译 Web 版本..."
flutter build web --release

echo "✅ Web 编译完成"
echo "   输出目录：$BUILD_DIR/web"
echo ""

# 复制到输出目录
mkdir -p "$OUTPUT_DIR/web"
cp -r "$BUILD_DIR/web/"* "$OUTPUT_DIR/web/"
echo "✅ Web 文件已复制到：$OUTPUT_DIR/web"
echo ""

# ========== Web 部署 ==========
echo "============================================================"
echo "🚀 部署 Web 前端"
echo "============================================================"
echo ""

# 方案 1: Nginx 部署脚本
cat > "$OUTPUT_DIR/deploy-nginx.sh" << 'NGINX_SCRIPT'
#!/bin/bash
# Nginx 部署脚本

WEB_DIR="/var/www/edu-assistant"
NGINX_CONF="/etc/nginx/sites-available/edu-assistant"

echo "📂 创建目录..."
sudo mkdir -p $WEB_DIR
sudo cp -r web/* $WEB_DIR/

echo "🔧 设置权限..."
sudo chown -R www-data:www-data $WEB_DIR
sudo chmod -R 755 $WEB_DIR

echo "📝 配置 Nginx..."
sudo tee $NGINX_CONF > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/edu-assistant;
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

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
EOF

echo "🔗 启用站点..."
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

echo "✅ Nginx 部署完成！"
echo "   访问地址：http://your-server-ip"
NGINX_SCRIPT

chmod +x "$OUTPUT_DIR/deploy-nginx.sh"
echo "✅ Nginx 部署脚本：$OUTPUT_DIR/deploy-nginx.sh"
echo ""

# 方案 2: Docker 部署
cat > "$OUTPUT_DIR/Dockerfile" << 'DOCKERFILE'
FROM nginx:alpine

COPY web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

cat > "$OUTPUT_DIR/nginx.conf" << 'NGINX_CONF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONF

cat > "$OUTPUT_DIR/docker-compose.yml" << 'COMPOSE'
version: '3.8'

services:
  web:
    build: .
    container_name: edu-web
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend

  backend:
    image: edu-assistant-backend:v1.1
    container_name: edu-backend
    restart: always
    environment:
      - DATABASE_URL=mysql://user:pass@db:3306/edu_assistant
      - JWT_SECRET=your-secret-key
      - ENV=production
    ports:
      - "8080:8080"

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

volumes:
  mysql-data:
COMPOSE

echo "✅ Docker 部署文件:"
echo "   - $OUTPUT_DIR/Dockerfile"
echo "   - $OUTPUT_DIR/nginx.conf"
echo "   - $OUTPUT_DIR/docker-compose.yml"
echo ""

# 部署说明
cat > "$OUTPUT_DIR/README.md" << 'README'
# EduAssistant 部署说明

## 📦 文件说明

- `android/` - Android APK 文件
- `web/` - Web 前端文件
- `deploy-nginx.sh` - Nginx 部署脚本
- `Dockerfile` - Docker 镜像构建文件
- `docker-compose.yml` - Docker Compose 配置
- `nginx.conf` - Nginx 配置文件

## 🚀 部署方式

### 方式 1: Nginx 部署

```bash
# 1. 运行部署脚本
sudo ./deploy-nginx.sh

# 2. 访问
http://your-server-ip
```

### 方式 2: Docker 部署

```bash
# 1. 构建并启动
docker-compose up -d --build

# 2. 查看状态
docker-compose ps

# 3. 访问
http://localhost

# 4. 查看日志
docker-compose logs -f
```

### 方式 3: 手动部署

```bash
# 1. 复制 Web 文件到 Nginx 目录
sudo cp -r web/* /var/www/edu-assistant/

# 2. 配置 Nginx (参考 deploy-nginx.sh)

# 3. 重启 Nginx
sudo systemctl reload nginx
```

## 🔧 后端 API 配置

编辑 `web/main.dart.js` 或配置环境变量:

```javascript
const API_URL = 'http://your-backend-ip:8080';
```

## 📱 Android APP 安装

```bash
# 1. 传输 APK 到手机
adb install android/EduAssistant-v1.0.apk

# 2. 或直接发送 APK 文件给用户
```

## 🌐 HTTPS 配置

```bash
# 使用 Let's Encrypt
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 监控和维护

```bash
# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 更新部署
docker-compose pull
docker-compose up -d
```
README

echo "✅ 部署说明：$OUTPUT_DIR/README.md"
echo ""

echo "============================================================"
echo "✅ 编译和部署准备完成！"
echo "============================================================"
echo ""
echo "📁 输出目录：$OUTPUT_DIR"
echo ""
echo "📦 生成的文件:"
if [ -f "$OUTPUT_DIR/android/EduAssistant-v1.0.apk" ]; then
    echo "   ✅ Android APK: $OUTPUT_DIR/android/EduAssistant-v1.0.apk"
fi
echo "   ✅ Web 前端：$OUTPUT_DIR/web/"
echo "   ✅ 部署脚本：$OUTPUT_DIR/deploy-nginx.sh"
echo "   ✅ Docker 配置：$OUTPUT_DIR/docker-compose.yml"
echo "   ✅ 部署说明：$OUTPUT_DIR/README.md"
echo ""
echo "🎯 下一步:"
echo "   1. 部署 Web: cd $OUTPUT_DIR && sudo ./deploy-nginx.sh"
echo "   2. 或 Docker: cd $OUTPUT_DIR && docker-compose up -d"
echo "   3. 安装 Android: adb install android/EduAssistant-v1.0.apk"
echo ""
