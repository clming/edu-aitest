package main

import (
	"fmt"
	"log"

	"github.com/clming/edu-aitest/go-backend/internal/config"
)

// 测试邮件发送
func main() {
	fmt.Println("📧 开始测试邮件发送...")

	// 测试 1: 基础邮件发送
	fmt.Println("\n1️⃣ 测试基础邮件发送...")
	emailConfig := config.GetEmailConfig()
	
	err := emailConfig.SendEmail(
		config.AdminEmail,
		"🎉 EduAssistant 邮件测试",
		`<h2>二爷，邮件测试成功！</h2>
		<p>这是 EduAssistant 系统的邮件通知测试。</p>
		<p>如果您收到这封邮件，说明 SMTP 配置正确。</p>
		<p><strong>配置信息：</strong></p>
		<ul>
			<li>SMTP 服务器：smtp.126.com</li>
			<li>发件人：cao_lianming@126.com</li>
			<li>收件人：clm@gwsvip.com</li>
		</ul>
		<p>✅ 邮件服务已就绪！</p>`,
	)
	
	if err != nil {
		log.Printf("❌ 邮件发送失败：%v", err)
		fmt.Println("❌ 测试失败")
		return
	}
	
	fmt.Println("✅ 基础邮件发送成功！")

	// 测试 2: 任务完成通知
	fmt.Println("\n2️⃣ 测试任务完成通知...")
	err = config.SendTaskCompleteNotification(
		"数据库配置",
		"数据库连接已配置完成，自动迁移功能已启用。",
	)
	
	if err != nil {
		log.Printf("⚠️ 任务通知发送失败：%v", err)
	} else {
		fmt.Println("✅ 任务完成通知发送成功！")
	}

	// 测试 3: Bug 通知
	fmt.Println("\n3️⃣ 测试 Bug 通知...")
	err = config.SendBugNotification(
		"BUG-TEST-001",
		"Medium",
		"这是一个测试 Bug，用于验证邮件通知功能。",
	)
	
	if err != nil {
		log.Printf("⚠️ Bug 通知发送失败：%v", err)
	} else {
		fmt.Println("✅ Bug 通知发送成功！")
	}

	// 测试 4: 里程碑通知
	fmt.Println("\n4️⃣ 测试里程碑通知...")
	err = config.SendMilestoneNotification(
		"v1.1",
		"Bug 修复版本发布，14 个 Bug 全部修复完成。",
	)
	
	if err != nil {
		log.Printf("⚠️ 里程碑通知发送失败：%v", err)
	} else {
		fmt.Println("✅ 里程碑通知发送成功！")
	}

	fmt.Println("\n🎉 所有邮件测试完成！")
	fmt.Println("\n📬 二爷，请检查邮箱 clm@gwsvip.com 是否收到测试邮件。")
}
