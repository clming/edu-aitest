# Flutter Web Docker 镜像
FROM ghcr.io/cirruslabs/flutter:3.16.0 AS builder

WORKDIR /app

# 复制 pubspec 文件
COPY pubspec.yaml pubspec.lock* ./

# 获取依赖
RUN flutter pub get

# 复制源代码
COPY . .

# 运行代码生成
RUN flutter pub run build_runner build --delete-conflicting-outputs

# 构建 Web 版本
RUN flutter build web --release

# Nginx 镜像
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/build/web /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
