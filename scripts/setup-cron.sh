#!/bin/bash
# EduAssistant 定时任务设置脚本
# 设置每日早 9:30 问好 + 晚 9:00 汇报

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON="/usr/bin/python3"

echo "🔧 正在设置 EduAssistant 定时任务..."
echo ""

# 备份现有 crontab
crontab -l > /tmp/crontab.backup 2>/dev/null || true

# 添加定时任务
(crontab -l 2>/dev/null | grep -v "daily-greeting.py" | grep -v "daily-report.py"; \
echo "# EduAssistant 定时任务"; \
echo "# 每日早 9:30 问好"; \
echo "30 9 * * * $PYTHON $SCRIPT_DIR/daily-greeting.py >> /tmp/edu-greeting.log 2>&1"; \
echo "# 每日晚 9:00 汇报"; \
echo "0 21 * * * $PYTHON $SCRIPT_DIR/daily-report.py >> /tmp/edu-report.log 2>&1") | crontab -

echo "✅ 定时任务设置完成！"
echo ""
echo "📋 已设置的定时任务："
crontab -l | grep "EduAssistant" -A 2
echo ""
echo "📝 日志文件位置："
echo "  早安日志：/tmp/edu-greeting.log"
echo "  晚报日志：/tmp/edu-report.log"
echo ""
echo "🔍 查看 crontab: crontab -l"
echo "📧 测试早安邮件：python3 $SCRIPT_DIR/daily-greeting.py"
echo "📊 测试晚报邮件：python3 $SCRIPT_DIR/daily-report.py"
