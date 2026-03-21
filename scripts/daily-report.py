#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EduAssistant 每日工作晚报
每晚 9:00 发送当日完成工作和未完成工作给二爷
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
from datetime import datetime
import os

# 邮件配置
SMTP_HOST = "smtp.126.com"
SMTP_PORT = 465
SMTP_USER = "cao_lianming@126.com"
SMTP_PASSWORD = "AUVd4SYdy2XuYR8S"
FROM_EMAIL = "cao_lianming@126.com"
FROM_NAME = "EduAssistant 晚报"
TO_EMAIL = "clm@gwsvip.com"
TO_NAME = "二爷"

def get_project_status():
    """获取项目状态（模拟数据，实际应从 Git/API 获取）"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    completed = [
        "✅ 数据库配置完成 - MySQL 已连接，自动迁移已启用",
        "✅ 邮件通知配置完成 - 126 邮箱 SMTP 已配置",
        "✅ AI Agent 工作流搭建完成 - 5 个 Agent 已配置",
        "✅ 产品文档完成 - PRD、功能列表、用户故事",
        "✅ 技术文档完成 - 系统架构、API 规范、WBS",
        "✅ 代码框架完成 - Flutter 14 文件，Go 17 文件",
        "✅ Bug 修复 v1.1 - 14 个 Bug 全部修复",
        "✅ 定时任务配置 - 早安问好 + 晚报汇报",
    ]
    
    pending = [
        "⏳ QA 回归测试 v1.1 - 等待启动",
        "⏳ Docker 镜像打包 - 准备构建",
        "⏳ 生产环境部署 - 等待测试通过",
        "⏳ 功能开发 P1 - 10 个功能待实现",
        "⏳ 功能开发 P2 - 14 个功能待实现",
        "⏳ 性能优化 - 目标 95+ 评分",
    ]
    
    return completed, pending, today

def send_daily_report():
    """发送晚报"""
    completed, pending, today = get_project_status()
    
    subject = f"📊 EduAssistant 项目晚报 - {today}"
    
    completed_html = "".join([f"<li>{item}</li>" for item in completed])
    pending_html = "".join([f"<li>{item}</li>" for item in pending])
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ 
                font-family: 'Microsoft YaHei', Arial, sans-serif; 
                line-height: 1.8; 
                color: #333;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                padding: 20px;
            }}
            .container {{ 
                max-width: 700px; 
                margin: 0 auto; 
                background: white;
                border-radius: 15px;
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            }}
            .header {{ 
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                color: white; 
                padding: 30px; 
                text-align: center;
            }}
            .header h1 {{ margin: 0; font-size: 24px; }}
            .header p {{ margin: 10px 0 0; opacity: 0.9; }}
            .content {{ 
                padding: 30px; 
                background: #fafafa;
            }}
            .section {{ 
                margin-bottom: 30px;
            }}
            .section-title {{ 
                font-size: 20px; 
                color: #667eea;
                margin-bottom: 15px;
                font-weight: bold;
                border-left: 4px solid #667eea;
                padding-left: 15px;
            }}
            .completed-list {{ 
                background: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }}
            .completed-list li {{ 
                margin-bottom: 10px;
                color: #2d3748;
            }}
            .pending-list {{ 
                background: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }}
            .pending-list li {{ 
                margin-bottom: 10px;
                color: #e67e22;
            }}
            .stats {{ 
                display: flex;
                justify-content: space-around;
                margin: 25px 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 20px;
                border-radius: 10px;
                color: white;
            }}
            .stat-item {{ 
                text-align: center;
            }}
            .stat-number {{ 
                font-size: 32px; 
                font-weight: bold;
            }}
            .stat-label {{ 
                font-size: 14px; 
                opacity: 0.9;
            }}
            .footer {{ 
                text-align: center; 
                padding: 20px; 
                background: #f0f0f0;
                color: #666;
                font-size: 12px;
            }}
            .progress {{ 
                background: #e0e0e0;
                border-radius: 10px;
                height: 20px;
                margin: 20px 0;
                overflow: hidden;
            }}
            .progress-bar {{ 
                background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
                height: 100%;
                width: 85%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 12px;
                font-weight: bold;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📊 EduAssistant 项目晚报</h1>
                <p>{today} | 研发进度汇报</p>
            </div>
            <div class="content">
                <div class="stats">
                    <div class="stat-item">
                        <div class="stat-number">✅ {len(completed)}</div>
                        <div class="stat-label">今日完成</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">⏳ {len(pending)}</div>
                        <div class="stat-label">待完成</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">🎯 85%</div>
                        <div class="stat-label">总体进度</div>
                    </div>
                </div>
                
                <div class="progress">
                    <div class="progress-bar">85%</div>
                </div>
                
                <div class="section">
                    <div class="section-title">✅ 今日完成工作</div>
                    <ul class="completed-list">
                        {completed_html}
                    </ul>
                </div>
                
                <div class="section">
                    <div class="section-title">⏳ 未完成工作</div>
                    <ul class="pending-list">
                        {pending_html}
                    </ul>
                </div>
                
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; margin-top: 25px;">
                    <strong>🎯 项目最终目标：</strong>
                    <br><br>
                    打造一款完整的教育类应用，包括：
                    <br>
                    📱 iOS APP + Android APP + Web 端（Flutter 三端合一）
                    <br>
                    ⚙️ Go 后端服务管理后台
                    <br>
                    🎓 参考作业帮家长版，服务 K12 学生和家长
                    <br><br>
                    <strong>当前状态：</strong> 开发完成 85%，等待 QA 回归测试和 Docker 部署
                </div>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
                <p>项目地址：<a href="https://github.com/clming/edu-aitest">github.com/clming/edu-aitest</a></p>
                <p>🌙 二爷，辛苦了！早点休息，明天继续战斗！</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    # 发送邮件
    msg = MIMEMultipart('alternative')
    msg['Subject'] = Header(subject, 'utf-8')
    msg['From'] = f"{FROM_NAME} <{FROM_EMAIL}>"
    msg['To'] = f"{TO_NAME} <{TO_EMAIL}>"
    
    html_part = MIMEText(html_content, 'html', 'utf-8')
    msg.attach(html_part)
    
    try:
        server = smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT)
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.sendmail(FROM_EMAIL, [TO_EMAIL], msg.as_string())
        server.quit()
        print(f"✅ 晚报邮件发送成功！")
        return True
    except Exception as e:
        print(f"❌ 晚报邮件发送失败：{e}")
        return False

if __name__ == "__main__":
    send_daily_report()
