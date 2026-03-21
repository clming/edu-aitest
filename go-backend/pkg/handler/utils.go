package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/clming/edu-aitest/go-backend/pkg/middleware"
)

// getUserIDFromToken 从 JWT token 中获取用户 ID
func getUserIDFromToken(c *gin.Context) uint {
	return middleware.GetUserIDFromToken(c)
}

// getUserRoleFromToken 从 JWT token 中获取用户角色
func getUserRoleFromToken(c *gin.Context) string {
	if role, exists := c.Get("role"); exists {
		return role.(string)
	}
	return ""
}

// parseTime 解析时间字符串
func parseTime(timeStr string) (time.Time, error) {
	return time.Parse("2006-01-02", timeStr)
}

// ErrorResponse 统一错误响应
func ErrorResponse(c *gin.Context, code int, message string) {
	c.JSON(code, gin.H{
		"error":   message,
		"code":    code,
		"success": false,
	})
}

// SuccessResponse 统一成功响应
func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}
