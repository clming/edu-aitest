#!/bin/bash
# EduAssistant Go 后端 Docker 构建和部署脚本

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="edu-assistant-backend"
IMAGE_TAG="v1.1"
CONTAINER_NAME="edu-backend"

echo "======================================"
echo "🐳 EduAssistant Docker 构建和部署"
echo "======================================"
echo ""

# 1. 构建 Docker 镜像
echo "1️⃣ 构建 Docker 镜像..."
cd "$SCRIPT_DIR"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile ..

if [ $? -eq 0 ]; then
    echo "✅ Docker 镜像构建成功！"
    echo "   镜像名：${IMAGE_NAME}:${IMAGE_TAG}"
else
    echo "❌ Docker 镜像构建失败！"
    exit 1
fi

echo ""

# 2. 查看镜像
echo "2️⃣ 本地 Docker 镜像："
docker images | grep ${IMAGE_NAME}

echo ""

# 3. 停止旧容器（如果存在）
echo "3️⃣ 停止旧容器（如果存在）..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

echo ""

# 4. 启动新容器
echo "4️⃣ 启动新容器..."
cd "$SCRIPT_DIR"
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "✅ 容器启动成功！"
else
    echo "❌ 容器启动失败！"
    exit 1
fi

echo ""

# 5. 查看容器状态
echo "5️⃣ 容器状态："
docker ps | grep edu

echo ""

# 6. 查看日志
echo "6️⃣ 最新日志（最后 20 行）："
docker logs --tail 20 ${CONTAINER_NAME}

echo ""

# 7. 健康检查
echo "7️⃣ 健康检查..."
sleep 5
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER_NAME} 2>/dev/null || echo "unknown")

if [ "$HEALTH_STATUS" = "healthy" ]; then
    echo "✅ 服务健康检查通过！"
else
    echo "⚠️  服务健康检查状态：$HEALTH_STATUS"
    echo "   等待服务启动..."
    sleep 10
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER_NAME} 2>/dev/null || echo "unknown")
    echo "   当前状态：$HEALTH_STATUS"
fi

echo ""
echo "======================================"
echo "🎉 部署完成！"
echo "======================================"
echo ""
echo "📊 服务信息："
echo "   容器名：${CONTAINER_NAME}"
echo "   镜像：${IMAGE_NAME}:${IMAGE_TAG}"
echo "   端口：http://localhost:8080"
echo "   健康检查：http://localhost:8080/health"
echo ""
echo "🔍 常用命令："
echo "   查看日志：docker logs -f ${CONTAINER_NAME}"
echo "   查看状态：docker ps | grep edu"
echo "   停止服务：docker-compose down"
echo "   重启服务：docker-compose restart"
echo ""
echo "🗄️ 数据库："
echo "   地址：mysql-2a840bd18e4b-public.rds.volces.com:33060"
echo "   数据库：edu_assistant（容器启动后自动创建）"
echo "   表：users, homeworks, students, reports（自动创建）"
echo ""
