#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EduAssistant 邮件测试脚本
使用 Python 发送测试邮件到二爷的邮箱
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
from datetime import datetime

# 邮件配置
SMTP_HOST = "smtp.126.com"
SMTP_PORT = 465
SMTP_USER = "cao_lianming@126.com"
SMTP_PASSWORD = "AUVd4SYdy2XuYR8S"  # SMTP 授权码
FROM_EMAIL = "cao_lianming@126.com"
FROM_NAME = "EduAssistant 通知"

# 收件人
TO_EMAIL = "clm@gwsvip.com"
TO_NAME = "二爷"

def send_email(subject, html_content):
    """发送 HTML 邮件"""
    print(f"📧 正在发送邮件：{subject}")
    
    # 创建邮件
    msg = MIMEMultipart('alternative')
    msg['Subject'] = Header(subject, 'utf-8')
    msg['From'] = f"{FROM_NAME} <{FROM_EMAIL}>"
    msg['To'] = f"{TO_NAME} <{TO_EMAIL}>"
    
    # 添加 HTML 内容
    html_part = MIMEText(html_content, 'html', 'utf-8')
    msg.attach(html_part)
    
    try:
        # 连接 SMTP 服务器 (SSL)
        server = smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT)
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.sendmail(FROM_EMAIL, [TO_EMAIL], msg.as_string())
        server.quit()
        
        print(f"✅ 邮件发送成功！")
        return True
    except Exception as e:
        print(f"❌ 邮件发送失败：{e}")
        return False

def test_basic_email():
    """测试 1: 基础邮件"""
    subject = "🎉 EduAssistant 邮件测试 - Python"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }}
            .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
            .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            .status {{ display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; background: #d4edda; color: #155724; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎓 EduAssistant 通知</h1>
            </div>
            <div class="content">
                <h2>二爷，邮件测试成功！</h2>
                <p>这是 EduAssistant 系统的 Python 邮件通知测试。</p>
                <p>如果您收到这封邮件，说明 SMTP 配置正确。</p>
                <p><strong>配置信息：</strong></p>
                <ul>
                    <li>SMTP 服务器：smtp.126.com</li>
                    <li>发件人：cao_lianming@126.com</li>
                    <li>收件人：clm@gwsvip.com</li>
                    <li>发送时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</li>
                </ul>
                <p><span class="status">✅ 邮件服务已就绪！</span></p>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
                <p>项目地址：<a href="https://github.com/clming/edu-aitest">github.com/clming/edu-aitest</a></p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return send_email(subject, html_content)

def test_task_complete():
    """测试 2: 任务完成通知"""
    subject = "✅ 任务完成通知：数据库配置"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }}
            .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
            .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            .status {{ display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; background: #d4edda; color: #155724; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎓 EduAssistant 通知</h1>
            </div>
            <div class="content">
                <h2>二爷，任务已完成！</h2>
                <p><strong>任务名称：</strong>数据库配置</p>
                <p><strong>详细信息：</strong></p>
                <ul>
                    <li>MySQL 数据库已连接</li>
                    <li>自动迁移功能已启用</li>
                    <li>数据库名：edu_assistant</li>
                </ul>
                <p><span class="status">✅ 已完成</span></p>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return send_email(subject, html_content)

def test_bug_notification():
    """测试 3: Bug 通知"""
    subject = "🐛 Bug 通知：BUG-TEST-001 - Medium"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }}
            .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
            .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            .status {{ display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; background: #fff3cd; color: #856404; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎓 EduAssistant 通知</h1>
            </div>
            <div class="content">
                <h2>二爷，发现新的 Bug！</h2>
                <p><strong>Bug ID:</strong> BUG-TEST-001</p>
                <p><strong>严重程度：</strong><span class="status">Medium</span></p>
                <p><strong>问题描述：</strong></p>
                <p>这是一个测试 Bug，用于验证邮件通知功能。</p>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return send_email(subject, html_content)

def test_milestone():
    """测试 4: 里程碑通知"""
    subject = "🎉 项目里程碑：v1.1 发布"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }}
            .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
            .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            .status {{ display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; background: #d4edda; color: #155724; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎓 EduAssistant 通知</h1>
            </div>
            <div class="content">
                <h2>二爷，项目达成新里程碑！</h2>
                <p><strong>版本：</strong>v1.1</p>
                <p><strong>版本摘要：</strong></p>
                <ul>
                    <li>✅ 14 个 Bug 全部修复</li>
                    <li>✅ 数据库配置完成</li>
                    <li>✅ 邮件通知已配置</li>
                    <li>✅ 安全评分：63→90 (+27)</li>
                </ul>
                <p><span class="status">✅ 已发布</span></p>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return send_email(subject, html_content)

def main():
    """主函数"""
    print("="*60)
    print("🎉 EduAssistant 邮件测试开始")
    print("="*60)
    print()
    
    # 测试 1
    print("1️⃣ 测试基础邮件...")
    test_basic_email()
    print()
    
    # 测试 2
    print("2️⃣ 测试任务完成通知...")
    test_task_complete()
    print()
    
    # 测试 3
    print("3️⃣ 测试 Bug 通知...")
    test_bug_notification()
    print()
    
    # 测试 4
    print("4️⃣ 测试里程碑通知...")
    test_milestone()
    print()
    
    print("="*60)
    print("🎉 所有邮件测试完成！")
    print("="*60)
    print()
    print("📬 二爷，请检查邮箱 clm@gwsvip.com 是否收到 4 封测试邮件！")
    print()

if __name__ == "__main__":
    main()
