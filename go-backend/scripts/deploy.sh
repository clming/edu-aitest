#!/bin/bash

# 教育助手后端部署脚本
set -e

echo "🚀 开始部署教育助手后端服务..."

# 配置变量
APP_NAME="edu-assistant-backend"
BUILD_DIR="./build"
BINARY_NAME="edu-assistant"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Go 环境
check_go() {
    if ! command -v go &> /dev/null; then
        echo -e "${RED}❌ Go 未安装，请先安装 Go${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Go 版本：$(go version)${NC}"
}

# 安装依赖
install_deps() {
    echo -e "${YELLOW}📦 安装依赖...${NC}"
    go mod download
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
}

# 生成 Swagger 文档
generate_swagger() {
    echo -e "${YELLOW}📝 生成 Swagger 文档...${NC}"
    if ! command -v swag &> /dev/null; then
        echo -e "${YELLOW}⚠️  Swag 未安装，正在安装...${NC}"
        go install github.com/swaggo/swag/cmd/swag@latest
    fi
    swag init -g cmd/main.go -o ./docs
    echo -e "${GREEN}✅ Swagger 文档生成完成${NC}"
}

# 编译
build() {
    echo -e "${YELLOW}🔨 编译应用...${NC}"
    mkdir -p $BUILD_DIR
    GOOS=linux GOARCH=amd64 go build -o $BUILD_DIR/$BINARY_NAME cmd/main.go
    echo -e "${GREEN}✅ 编译完成：$BUILD_DIR/$BINARY_NAME${NC}"
}

# 运行测试
run_tests() {
    echo -e "${YELLOW}🧪 运行测试...${NC}"
    go test -v ./... -cover
    echo -e "${GREEN}✅ 测试完成${NC}"
}

# 创建配置文件
create_config() {
    echo -e "${YELLOW}⚙️  创建配置文件...${NC}"
    if [ ! -f ".env" ]; then
        cat > .env << EOF
# 数据库配置
DATABASE_URL=postgres://postgres:password@localhost:5432/edu_assistant?sslmode=disable

# Redis 配置
REDIS_URL=redis://localhost:6379

# JWT 配置
JWT_SECRET=edu-assistant-secret-key-2026

# 服务端口
PORT=8080

# 环境
ENV=development
EOF
        echo -e "${GREEN}✅ 配置文件 .env 已创建${NC}"
    else
        echo -e "${YELLOW}⚠️  .env 文件已存在，跳过${NC}"
    fi
}

# Docker 部署
docker_deploy() {
    echo -e "${YELLOW}🐳 构建 Docker 镜像...${NC}"
    docker build -t $APP_NAME:latest .
    echo -e "${GREEN}✅ Docker 镜像构建完成${NC}"
    
    echo -e "${YELLOW}🚀 启动容器...${NC}"
    docker-compose up -d
    echo -e "${GREEN}✅ 容器启动完成${NC}"
}

# 系统服务部署（systemd）
systemd_deploy() {
    echo -e "${YELLOW}⚙️  配置 systemd 服务...${NC}"
    
    cat > /etc/systemd/system/$APP_NAME.service << EOF
[Unit]
Description=Edu Assistant Backend Service
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=www-data
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/$BUILD_DIR/$BINARY_NAME
Restart=on-failure
Environment=PATH=/usr/bin:/usr/local/go/bin
EnvironmentFile=$(pwd)/.env

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable $APP_NAME
    systemctl start $APP_NAME
    
    echo -e "${GREEN}✅ Systemd 服务配置完成${NC}"
    echo -e "${YELLOW}查看服务状态：systemctl status $APP_NAME${NC}"
}

# 主流程
main() {
    echo "======================================"
    echo "  教育助手后端部署脚本"
    echo "======================================"
    echo ""
    
    check_go
    echo ""
    
    # 选择部署模式
    DEPLOY_MODE=${1:-"local"}
    
    case $DEPLOY_MODE in
        "local")
            echo -e "${YELLOW}📍 本地部署模式${NC}"
            install_deps
            generate_swagger
            run_tests
            build
            create_config
            echo ""
            echo -e "${GREEN}🎉 部署完成！${NC}"
            echo -e "${YELLOW}启动服务：./$BUILD_DIR/$BINARY_NAME${NC}"
            ;;
        "docker")
            echo -e "${YELLOW}🐳 Docker 部署模式${NC}"
            install_deps
            generate_swagger
            build
            docker_deploy
            ;;
        "systemd")
            echo -e "${YELLOW}⚙️  Systemd 部署模式${NC}"
            install_deps
            generate_swagger
            build
            create_config
            systemd_deploy
            ;;
        *)
            echo -e "${RED}❌ 未知的部署模式：$DEPLOY_MODE${NC}"
            echo "用法：$0 [local|docker|systemd]"
            exit 1
            ;;
    esac
    
    echo ""
    echo "======================================"
    echo -e "${GREEN}✅ 部署成功！${NC}"
    echo "======================================"
}

# 执行
main "$@"
