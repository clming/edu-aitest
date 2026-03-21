package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// HealthCheck 健康检查
// @Summary 健康检查
// @Description 检查服务状态
// @Tags health
// @Success 200 {object} map[string]interface{}
// @Router /health [get]
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "ok",
		"timestamp": time.Now().Format(time.RFC3339),
		"service":   "edu-assistant-backend",
		"version":   "1.1.0",
	})
}

// 注意：其他 handler 函数已在各自的文件中定义
// - auth.go: Login, Register, Logout
// - homework.go: GetHomeworkList, GetHomeworkDetail, CreateHomework, UpdateHomework, DeleteHomework
// - student.go: GetStudentList, GetStudentDetail
// - report.go: GetWeeklyReport, GetMonthlyReport
