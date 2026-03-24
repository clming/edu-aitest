#!/usr/bin/env python3
"""
生成 EduAssistant 应用图标和启动屏
使用 PIL/Pillow 库生成渐变色图标
"""

from PIL import Image, ImageDraw, ImageFont
import os

# 配置
OUTPUT_DIR = "/root/.openclaw/workspace/projects/edu-aitest/flutter-app/assets/icons"
COLORS = {
    'primary': '#667eea',
    'secondary': '#764ba2',
    'white': '#ffffff',
    'light': '#f0f0f0'
}

def create_gradient_background(size, color1, color2):
    """创建渐变背景"""
    base = Image.new('RGB', size, color1)
    top = Image.new('RGB', size, color2)
    mask = Image.new('L', size)
    mask_data = []
    for y in range(size[1]):
        for x in range(size[0]):
            mask_data.append(int(255 * (y / size[1])))
    mask.putdata(mask_data)
    base.paste(top, (0, 0), mask)
    return base

def draw_education_icon(draw, size, center_x, center_y, radius):
    """绘制教育相关图标 (书本 + 学位帽)"""
    # 书本形状
    book_points = [
        (center_x - radius, center_y + radius * 0.3),
        (center_x - radius, center_y - radius * 0.5),
        (center_x, center_y - radius * 0.3),
        (center_x + radius, center_y - radius * 0.5),
        (center_x + radius, center_y + radius * 0.3),
        (center_x, center_y + radius * 0.5),
    ]
    draw.polygon(book_points, fill=COLORS['white'])
    
    # 学位帽
    cap_base_y = center_y - radius * 0.5
    cap_points = [
        (center_x - radius * 0.8, cap_base_y),
        (center_x, cap_base_y - radius * 0.6),
        (center_x + radius * 0.8, cap_base_y),
        (center_x, cap_base_y + radius * 0.2),
    ]
    draw.polygon(cap_points, fill=COLORS['white'])
    
    # 帽穗
    draw.line([
        (center_x + radius * 0.8, cap_base_y),
        (center_x + radius * 1.2, cap_base_y + radius * 0.3)
    ], fill=COLORS['white'], width=3)
    draw.ellipse([
        center_x + radius * 1.1, cap_base_y + radius * 0.2,
        center_x + radius * 1.3, cap_base_y + radius * 0.4
    ], fill=COLORS['white'])

def generate_app_icon(size=1024):
    """生成应用图标"""
    print(f"📱 生成应用图标 ({size}x{size})...")
    
    # 创建渐变背景
    img = create_gradient_background((size, size), COLORS['primary'], COLORS['secondary'])
    draw = ImageDraw.Draw(img)
    
    # 绘制教育图标
    center_x = size // 2
    center_y = size // 2
    radius = size * 0.35
    
    draw_education_icon(draw, size, center_x, center_y, radius)
    
    # 保存
    output_path = os.path.join(OUTPUT_DIR, "app_icon.png")
    img.save(output_path, 'PNG')
    print(f"✅ 应用图标已保存：{output_path}")
    
    return output_path

def generate_splash_icon(size=288):
    """生成启动屏图标"""
    print(f"🚀 生成启动屏图标 ({size}x{size})...")
    
    # 创建透明背景
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制简化的教育图标
    center_x = size // 2
    center_y = size // 2
    radius = size * 0.35
    
    draw_education_icon(draw, size, center_x, center_y, radius)
    
    # 保存
    output_path = os.path.join(OUTPUT_DIR, "splash_icon.png")
    img.save(output_path, 'PNG')
    print(f"✅ 启动屏图标已保存：{output_path}")
    
    # 生成深色版本
    img_dark = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw_dark = ImageDraw.Draw(img_dark)
    draw_education_icon(draw_dark, size, center_x, center_y, radius)
    output_path_dark = os.path.join(OUTPUT_DIR, "splash_icon_dark.png")
    img_dark.save(output_path_dark, 'PNG')
    print(f"✅ 深色启动屏图标已保存：{output_path_dark}")
    
    return output_path, output_path_dark

def generate_brand_icon(size=200):
    """生成品牌标识"""
    print(f"🏷️ 生成品牌标识 ({size}x{size})...")
    
    # 创建渐变背景
    img = create_gradient_background((size, size), COLORS['primary'], COLORS['secondary'])
    draw = ImageDraw.Draw(img)
    
    # 绘制文字 "Edu"
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size // 3)
    except:
        font = ImageFont.load_default()
    
    text = "Edu"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    draw.text((x, y), text, fill=COLORS['white'], font=font)
    
    # 保存
    output_path = os.path.join(OUTPUT_DIR, "brand.png")
    img.save(output_path, 'PNG')
    print(f"✅ 品牌标识已保存：{output_path}")
    
    return output_path

def main():
    """主函数"""
    print("=" * 60)
    print("🎨 EduAssistant 图标和启动屏生成器")
    print("=" * 60)
    print()
    
    # 确保输出目录存在
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # 生成图标
    generate_app_icon(1024)
    generate_splash_icon(288)
    generate_brand_icon(200)
    
    print()
    print("=" * 60)
    print("✅ 所有图标生成完成！")
    print("=" * 60)
    print()
    print("生成的文件:")
    print(f"  - {OUTPUT_DIR}/app_icon.png (1024x1024)")
    print(f"  - {OUTPUT_DIR}/splash_icon.png (288x288)")
    print(f"  - {OUTPUT_DIR}/splash_icon_dark.png (288x288)")
    print(f"  - {OUTPUT_DIR}/brand.png (200x200)")
    print()
    print("下一步:")
    print("  1. 在 pubspec.yaml 中添加 flutter_launcher_icons 和 flutter_native_splash")
    print("  2. 运行：flutter pub run flutter_launcher_icons")
    print("  3. 运行：flutter pub run flutter_native_splash:create")

if __name__ == "__main__":
    main()
