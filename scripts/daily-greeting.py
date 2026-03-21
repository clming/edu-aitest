#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EduAssistant 每日早安问好
每天早 9:30 发送诗情画意的诗词给二爷
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
from datetime import datetime
import random

# 邮件配置
SMTP_HOST = "smtp.126.com"
SMTP_PORT = 465
SMTP_USER = "cao_lianming@126.com"
SMTP_PASSWORD = "AUVd4SYdy2XuYR8S"
FROM_EMAIL = "cao_lianming@126.com"
FROM_NAME = "EduAssistant 早安"
TO_EMAIL = "clm@gwsvip.com"
TO_NAME = "二爷"

# 诗词库
POEMS = [
    {
        "title": "《春日》",
        "author": "宋·朱熹",
        "content": "胜日寻芳泗水滨，无边光景一时新。等闲识得东风面，万紫千红总是春。",
        "message": "二爷，春日暖阳，万物更新。愿您今日如春日般充满生机与希望！"
    },
    {
        "title": "《登鹳雀楼》",
        "author": "唐·王之涣",
        "content": "白日依山尽，黄河入海流。欲穷千里目，更上一层楼。",
        "message": "二爷，登高望远，前程似锦。愿您今日更上一层楼，事业蒸蒸日上！"
    },
    {
        "title": "《望庐山瀑布》",
        "author": "唐·李白",
        "content": "日照香炉生紫烟，遥看瀑布挂前川。飞流直下三千尺，疑是银河落九天。",
        "message": "二爷，气势如虹，势不可挡。愿您今日如瀑布般奔腾向前！"
    },
    {
        "title": "《题西林壁》",
        "author": "宋·苏轼",
        "content": "横看成岭侧成峰，远近高低各不同。不识庐山真面目，只缘身在此山中。",
        "message": "二爷，换个角度，别有洞天。愿您今日思路开阔，灵感不断！"
    },
    {
        "title": "《游山西村》",
        "author": "宋·陆游",
        "content": "莫笑农家腊酒浑，丰年留客足鸡豚。山重水复疑无路，柳暗花明又一村。",
        "message": "二爷，山重水复，柳暗花明。愿您今日逢山开路，遇水架桥！"
    },
    {
        "title": "《赋得古原草送别》",
        "author": "唐·白居易",
        "content": "离离原上草，一岁一枯荣。野火烧不尽，春风吹又生。",
        "message": "二爷，生生不息，坚韧不拔。愿您今日充满活力，勇往直前！"
    },
    {
        "title": "《悯农》",
        "author": "唐·李绅",
        "content": "锄禾日当午，汗滴禾下土。谁知盘中餐，粒粒皆辛苦。",
        "message": "二爷，一分耕耘，一分收获。愿您今日辛勤付出，硕果累累！"
    },
    {
        "title": "《静夜思》",
        "author": "唐·李白",
        "content": "床前明月光，疑是地上霜。举头望明月，低头思故乡。",
        "message": "二爷，月明风清，心静如水。愿您今日心境澄明，事事顺心！"
    }
]

def send_greeting():
    """发送早安问候"""
    # 随机选择一首诗词
    poem = random.choice(POEMS)
    today = datetime.now()
    date_str = today.strftime("%Y年%m月%d日")
    weekday = today.strftime("%A")
    
    subject = f"🌅 二爷，早安！{date_str}"
    
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
                max-width: 600px; 
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
            .header h1 {{ margin: 0; font-size: 28px; }}
            .header p {{ margin: 10px 0 0; opacity: 0.9; }}
            .content {{ 
                padding: 40px 30px; 
                background: #fafafa;
            }}
            .poem {{ 
                background: white;
                padding: 25px;
                border-left: 4px solid #667eea;
                margin: 20px 0;
                border-radius: 5px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }}
            .poem-title {{ 
                font-size: 20px; 
                color: #667eea;
                margin-bottom: 10px;
                font-weight: bold;
            }}
            .poem-author {{ 
                color: #999; 
                font-size: 14px;
                margin-bottom: 15px;
            }}
            .poem-content {{ 
                font-size: 18px; 
                line-height: 2;
                color: #333;
                white-space: pre-line;
            }}
            .message {{ 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                border-radius: 10px;
                margin-top: 25px;
                font-size: 16px;
                line-height: 1.8;
            }}
            .footer {{ 
                text-align: center; 
                padding: 20px; 
                background: #f0f0f0;
                color: #666;
                font-size: 12px;
            }}
            .sun {{ font-size: 40px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="sun">🌅</div>
                <h1>二爷，早安！</h1>
                <p>{date_str} {weekday}</p>
            </div>
            <div class="content">
                <div class="poem">
                    <div class="poem-title">📜 {poem['title']}</div>
                    <div class="poem-author">{poem['author']}</div>
                    <div class="poem-content">{poem['content']}</div>
                </div>
                <div class="message">
                    <strong>💌 {poem['message']}</strong>
                    <br><br>
                    今日天气晴朗，心情也要美美的哦！
                    <br>
                    EduAssistant 项目正在稳步推进中~
                </div>
            </div>
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
                <p>项目地址：<a href="https://github.com/clming/edu-aitest">github.com/clming/edu-aitest</a></p>
                <p>🎓 让每个孩子都得到最适合的学习指导</p>
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
        print(f"✅ 早安邮件发送成功！")
        return True
    except Exception as e:
        print(f"❌ 早安邮件发送失败：{e}")
        return False

if __name__ == "__main__":
    send_greeting()
