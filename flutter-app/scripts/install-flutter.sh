#!/bin/bash
# Flutter SDK 安装脚本
# 适用于 Ubuntu/Debian 系统

set -e

echo "============================================================"
echo "🔧 Flutter SDK 安装脚本"
echo "============================================================"
echo ""

# 检查系统
if [ ! -f /etc/os-release ]; then
    echo "❌ 无法识别操作系统"
    exit 1
fi

source /etc/os-release
if [ "$ID" != "ubuntu" ] && [ "$ID" != "debian" ]; then
    echo "⚠️  此脚本仅支持 Ubuntu/Debian 系统"
    echo "   当前系统：$ID"
    exit 1
fi

# 检查是否已安装
if command -v flutter &> /dev/null; then
    echo "✅ Flutter 已安装"
    flutter --version
    exit 0
fi

echo "📦 开始安装 Flutter SDK..."
echo ""

# 1. 安装依赖
echo "1️⃣  安装系统依赖..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    > /dev/null 2>&1

echo "✅ 依赖安装完成"
echo ""

# 2. 下载 Flutter SDK
echo "2️⃣  下载 Flutter SDK..."
FLUTTER_VERSION="3.16.0"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_DIR="/opt/flutter"

if [ -d "$FLUTTER_DIR" ]; then
    echo "✅ Flutter SDK 已存在：$FLUTTER_DIR"
else
    echo "   下载版本：$FLUTTER_VERSION"
    echo "   下载地址：$FLUTTER_URL"
    echo "   安装目录：$FLUTTER_DIR"
    echo ""
    
    # 下载
    sudo mkdir -p /opt
    cd /tmp
    sudo curl -fsSL "$FLUTTER_URL" -o flutter.tar.xz
    
    # 解压
    echo "   解压中..."
    sudo tar xf flutter.tar.xz -C /opt/
    sudo rm flutter.tar.xz
    
    echo "✅ Flutter SDK 下载完成"
fi
echo ""

# 3. 配置环境变量
echo "3️⃣  配置环境变量..."
FLUTTER_BIN="$FLUTTER_DIR/bin"

# 添加到 ~/.bashrc
if ! grep -q "export PATH=.*flutter" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Flutter" >> ~/.bashrc
    echo "export PATH=\$PATH:$FLUTTER_BIN" >> ~/.bashrc
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
    echo "export ANDROID_SDK_ROOT=\$HOME/Android/Sdk" >> ~/.bashrc
fi

# 立即生效
export PATH=$PATH:$FLUTTER_BIN

echo "✅ 环境变量配置完成"
echo ""

# 4. 验证安装
echo "4️⃣  验证 Flutter 安装..."
flutter --version
echo ""

# 5. Flutter Doctor
echo "5️⃣  运行 Flutter Doctor..."
flutter doctor
echo ""

# 6. 接受 Android 许可证
echo "6️⃣  接受 Android 许可证..."
flutter doctor --android-licenses || echo "⚠️  许可证接受失败（可选）"
echo ""

# 7. 安装 Dart
echo "7️⃣  安装 Dart SDK..."
if ! command -v dart &> /dev/null; then
    sudo apt-get install -y -qq apt-transport-https > /dev/null 2>&1
    sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' > /dev/null 2>&1
    sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
    sudo apt-get update -qq > /dev/null 2>&1
    sudo apt-get install -y -qq dart > /dev/null 2>&1
    echo "✅ Dart SDK 安装完成"
else
    echo "✅ Dart SDK 已安装"
fi
echo ""

# 8. 配置 Git
echo "8️⃣  配置 Git (如果未配置)..."
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "EduAssistant Developer"
    git config --global user.email "dev@edu-assistant.com"
    echo "✅ Git 配置完成"
else
    echo "✅ Git 已配置"
fi
echo ""

echo "============================================================"
echo "✅ Flutter SDK 安装完成！"
echo "============================================================"
echo ""
echo "📍 安装目录：$FLUTTER_DIR"
echo "📍 Dart 目录：/usr/lib/dart"
echo ""
echo "🎯 下一步:"
echo "   1. 重新加载环境变量：source ~/.bashrc"
echo "   2. 验证安装：flutter doctor"
echo "   3. 安装 Android Studio (可选):"
echo "      https://developer.android.com/studio"
echo ""
echo "📱 编译 Android APP 需要安装 Android Studio"
echo "🌐 编译 Web 版本不需要 Android Studio"
echo ""
