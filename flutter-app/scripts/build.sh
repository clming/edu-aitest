#!/bin/bash

# Flutter 应用构建脚本
set -e

echo "🚀 开始构建教育助手 Flutter 应用..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Flutter 环境
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter 未安装，请先安装 Flutter${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Flutter 版本：$(flutter --version | head -n 1)${NC}"
}

# 获取依赖
get_deps() {
    echo -e "${YELLOW}📦 获取依赖...${NC}"
    flutter pub get
    echo -e "${GREEN}✅ 依赖获取完成${NC}"
}

# 运行代码生成
run_build() {
    echo -e "${YELLOW}🔨 运行代码生成...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✅ 代码生成完成${NC}"
}

# 运行测试
run_tests() {
    echo -e "${YELLOW}🧪 运行测试...${NC}"
    flutter test
    echo -e "${GREEN}✅ 测试完成${NC}"
}

# 代码分析
analyze_code() {
    echo -e "${YELLOW}🔍 代码分析...${NC}"
    flutter analyze
    echo -e "${GREEN}✅ 代码分析完成${NC}"
}

# 构建 Android
build_android() {
    echo -e "${YELLOW}📱 构建 Android APK...${NC}"
    flutter build apk --release
    echo -e "${GREEN}✅ Android APK 构建完成${NC}"
    echo -e "${YELLOW}输出位置：build/app/outputs/flutter-apk/app-release.apk${NC}"
}

# 构建 Android App Bundle
build_android_bundle() {
    echo -e "${YELLOW}📱 构建 Android App Bundle...${NC}"
    flutter build appbundle --release
    echo -e "${GREEN}✅ Android App Bundle 构建完成${NC}"
    echo -e "${YELLOW}输出位置：build/app/outputs/bundle/release/app-release.aab${NC}"
}

# 构建 iOS
build_ios() {
    echo -e "${YELLOW}🍎 构建 iOS...${NC}"
    flutter build ios --release
    echo -e "${GREEN}✅ iOS 构建完成${NC}"
    echo -e "${YELLOW}输出位置：build/ios/iphoneos/Runner.app${NC}"
}

# 构建 Web
build_web() {
    echo -e "${YELLOW}🌐 构建 Web...${NC}"
    flutter build web --release
    echo -e "${GREEN}✅ Web 构建完成${NC}"
    echo -e "${YELLOW}输出位置：build/web/${NC}"
}

# 清理
clean() {
    echo -e "${YELLOW}🧹 清理构建缓存...${NC}"
    flutter clean
    rm -rf build/
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 主流程
main() {
    echo "======================================"
    echo "  教育助手 Flutter 构建脚本"
    echo "======================================"
    echo ""
    
    check_flutter
    echo ""
    
    # 选择构建模式
    BUILD_MODE=${1:-"all"}
    
    case $BUILD_MODE in
        "android")
            echo -e "${YELLOW}📍 Android 构建模式${NC}"
            get_deps
            run_build
            run_tests
            analyze_code
            build_android
            ;;
        "android-bundle")
            echo -e "${YELLOW}📍 Android Bundle 构建模式${NC}"
            get_deps
            run_build
            run_tests
            analyze_code
            build_android_bundle
            ;;
        "ios")
            echo -e "${YELLOW}📍 iOS 构建模式${NC}"
            get_deps
            run_build
            run_tests
            analyze_code
            build_ios
            ;;
        "web")
            echo -e "${YELLOW}📍 Web 构建模式${NC}"
            get_deps
            run_build
            run_tests
            analyze_code
            build_web
            ;;
        "all")
            echo -e "${YELLOW}📍 全平台构建模式${NC}"
            get_deps
            run_build
            run_tests
            analyze_code
            build_android
            build_web
            ;;
        "clean")
            clean
            ;;
        "test")
            get_deps
            run_tests
            ;;
        *)
            echo -e "${RED}❌ 未知的构建模式：$BUILD_MODE${NC}"
            echo "用法：$0 [android|android-bundle|ios|web|all|clean|test]"
            exit 1
            ;;
    esac
    
    echo ""
    echo "======================================"
    echo -e "${GREEN}✅ 构建成功！${NC}"
    echo "======================================"
}

# 执行
main "$@"
