package config

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
)

// 邮件配置
const (
	// 126 邮箱 SMTP 配置
	SMTPHost     = "smtp.126.com"
	SMTPPort     = 465
	SMTPUser     = "cao_lianming@126.com"
	SMTPPassword = "AUVd4SYdy2XuYR8S" // SMTP 授权码
	FromEmail    = "cao_lianming@126.com"
	FromName     = "EduAssistant 通知"
)

// 收件人配置
var (
	// 二爷的收件邮箱
	AdminEmail = "clm@gwsvip.com"
	AdminName  = "二爷"
)

// EmailConfig 邮件配置结构
type EmailConfig struct {
	SMTPHost     string
	SMTPPort     int
	SMTPUser     string
	SMTPPassword string
	FromEmail    string
	FromName     string
}

// GetEmailConfig 获取邮件配置
func GetEmailConfig() *EmailConfig {
	return &EmailConfig{
		SMTPHost:     SMTPHost,
		SMTPPort:     SMTPPort,
		SMTPUser:     SMTPUser,
		SMTPPassword: SMTPPassword,
		FromEmail:    FromEmail,
		FromName:     FromName,
	}
}

// SendEmail 发送邮件
func (c *EmailConfig) SendEmail(to, subject, body string) error {
	auth := smtp.PlainAuth("", c.SMTPUser, c.SMTPPassword, c.SMTPHost)

	// 构建邮件内容
	msg := []byte(fmt.Sprintf(
		"From: %s <%s>\r\n"+
			"To: %s\r\n"+
			"Subject: %s\r\n"+
			"Content-Type: text/html; charset=UTF-8\r\n"+
			"\r\n"+
			"%s\r\n",
		c.FromName, c.FromEmail,
		to,
		subject,
		body,
	))

	// 使用 SSL 连接
	addr := fmt.Sprintf("%s:%d", c.SMTPHost, c.SMTPPort)
	
	// 创建 TLS 配置
	tlsConfig := &tls.Config{
		InsecureSkipVerify: false,
		ServerName:         c.SMTPHost,
	}

	// 建立连接
	conn, err := tls.Dial("tcp", addr, tlsConfig)
	if err != nil {
		return fmt.Errorf("连接 SMTP 服务器失败：%w", err)
	}
	defer conn.Close()

	// 创建 SMTP 客户端
	client, err := smtp.NewClient(conn, c.SMTPHost)
	if err != nil {
		return fmt.Errorf("创建 SMTP 客户端失败：%w", err)
	}
	defer client.Close()

	// 认证
	if err := client.Auth(auth); err != nil {
		return fmt.Errorf("SMTP 认证失败：%w", err)
	}

	// 设置发件人
	if err := client.Mail(c.FromEmail); err != nil {
		return fmt.Errorf("设置发件人失败：%w", err)
	}

	// 设置收件人
	if err := client.Rcpt(to); err != nil {
		return fmt.Errorf("设置收件人失败：%w", err)
	}

	// 发送邮件内容
	w, err := client.Data()
	if err != nil {
		return fmt.Errorf("获取数据写入器失败：%w", err)
	}

	_, err = w.Write(msg)
	if err != nil {
		return fmt.Errorf("写入邮件内容失败：%w", err)
	}

	err = w.Close()
	if err != nil {
		return fmt.Errorf("关闭数据写入器失败：%w", err)
	}

	return client.Quit()
}

// SendNotification 发送通知邮件（便捷方法）
func SendNotification(subject, content string) error {
	config := GetEmailConfig()
	
	// 构建 HTML 邮件内容
	htmlBody := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        .button { display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin-top: 15px; }
        .status { display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; }
        .status-success { background: #d4edda; color: #155724; }
        .status-warning { background: #fff3cd; color: #856404; }
        .status-error { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎓 EduAssistant 通知</h1>
        </div>
        <div class="content">
            <h2>%s</h2>
            %s
            <div class="footer">
                <p>此邮件由 EduAssistant 系统自动发送</p>
                <p>项目地址：<a href="https://github.com/clming/edu-aitest">github.com/clming/edu-aitest</a></p>
            </div>
        </div>
    </div>
</body>
</html>
`, subject, content)

	return config.SendEmail(AdminEmail, subject, htmlBody)
}

// SendTaskCompleteNotification 发送任务完成通知
func SendTaskCompleteNotification(taskName, details string) error {
	subject := fmt.Sprintf("✅ 任务完成通知：%s", taskName)
	content := fmt.Sprintf(`
        <p><strong>二爷，任务已完成！</strong></p>
        <p>任务名称：%s</p>
        <p>详细信息：<br/>%s</p>
        <p><span class="status status-success">已完成</span></p>
    `, taskName, details)
	
	return SendNotification(subject, content)
}

// SendBugNotification 发送 Bug 通知
func SendBugNotification(bugID, severity, description string) error {
	subject := fmt.Sprintf("🐛 Bug 通知：%s - %s", bugID, severity)
	
	statusClass := "status-success"
	if severity == "Critical" || severity == "High" {
		statusClass = "status-error"
	} else if severity == "Medium" {
		statusClass = "status-warning"
	}
	
	content := fmt.Sprintf(`
        <p><strong>二爷，发现新的 Bug！</strong></p>
        <p>Bug ID: %s</p>
        <p>严重程度：<span class="status %s">%s</span></p>
        <p>问题描述：<br/>%s</p>
    `, bugID, statusClass, severity, description)
	
	return SendNotification(subject, content)
}

// SendMilestoneNotification 发送里程碑通知
func SendMilestoneNotification(version, summary string) error {
	subject := fmt.Sprintf("🎉 项目里程碑：%s", version)
	content := fmt.Sprintf(`
        <p><strong>二爷，项目达成新里程碑！</strong></p>
        <p>版本：%s</p>
        <p>版本摘要：<br/>%s</p>
        <p><span class="status status-success">已发布</span></p>
    `, version, summary)
	
	return SendNotification(subject, content)
}
