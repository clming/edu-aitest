package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// BUG-012: 请求 ID 追踪中间件
// 为每个请求生成唯一 ID，便于日志追踪和调试

// RequestID 请求 ID 中间件
func RequestID() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求头获取或生成新的请求 ID
		requestID := c.GetHeader("X-Request-ID")
		if requestID == "" {
			requestID = uuid.New().String()
		}
		
		// 设置到 context 和响应头
		c.Set("request_id", requestID)
		c.Writer.Header().Set("X-Request-ID", requestID)
		
		c.Next()
	}
}

// GetRequestID 从 context 获取请求 ID
func GetRequestID(c *gin.Context) string {
	if id, exists := c.Get("request_id"); exists {
		return id.(string)
	}
	return ""
}

// BUG-008: 统一错误处理中间件
// 防止泄露技术细节，返回友好的错误信息

// ErrorResponse 统一错误响应
type ErrorResponse struct {
	Error      string `json:"error"`
	RequestID  string `json:"request_id,omitempty"`
	Code       string `json:"code,omitempty"`
}

// ErrorMiddleware 错误处理中间件
func ErrorMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		
		// 如果有错误，统一处理
		if len(c.Errors) > 0 {
			requestID := GetRequestID(c)
			
			// 记录详细错误到日志 (不在响应中暴露)
			for _, err := range c.Errors {
				logError(requestID, err)
			}
			
			// 返回友好错误信息
			c.JSON(c.Writer.Status(), ErrorResponse{
				Error:     getFriendlyError(c.Writer.Status()),
				RequestID: requestID,
			})
		}
	}
}

// getFriendlyError 返回友好的错误信息
func getFriendlyError(statusCode int) string {
	switch statusCode {
	case http.StatusBadRequest:
		return "请求参数错误"
	case http.StatusUnauthorized:
		return "认证失败，请重新登录"
	case http.StatusForbidden:
		return "无权访问此资源"
	case http.StatusNotFound:
		return "请求的资源不存在"
	case http.StatusConflict:
		return "资源已存在或冲突"
	case http.StatusTooManyRequests:
		return "请求过于频繁，请稍后再试"
	case http.StatusInternalServerError:
		return "服务器内部错误，请稍后重试"
	case http.StatusServiceUnavailable:
		return "服务暂时不可用"
	default:
		return "请求处理失败"
	}
}

// logError 记录错误日志 (不暴露敏感信息)
func logError(requestID string, err *gin.Error) {
	// BUG-011: 日志脱敏，不记录敏感信息
	errMsg := err.Error()
	
	// 脱敏处理：移除可能的敏感信息
	errMsg = sanitizeLogMessage(errMsg)
	
	// 使用标准日志格式
	fmt.Printf("[ERROR] [RequestID: %s] %s\n", requestID, errMsg)
}

// sanitizeLogMessage 脱敏日志消息
// BUG-011: 移除敏感信息
func sanitizeLogMessage(msg string) string {
	// 替换可能的敏感信息
	sensitivePatterns := []struct {
		pattern     string
		replacement string
	}{
		{"password", "[REDACTED]"},
		{"secret", "[REDACTED]"},
		{"token", "[REDACTED]"},
		{"Authorization", "[REDACTED]"},
		{"Bearer ", "[REDACTED] "},
	}
	
	for _, p := range sensitivePatterns {
		msg = strings.ReplaceAll(msg, p.pattern, p.replacement)
	}
	
	return msg
}
