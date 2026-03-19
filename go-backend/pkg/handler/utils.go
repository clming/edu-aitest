package handler

import (
	"reflect"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/clming/edu-aitest/go-backend/pkg/middleware"
)

// getUserIDFromToken 从 JWT token 中获取用户 ID
func getUserIDFromToken(c *gin.Context) uint {
	return middleware.GetUserIDFromToken(c)
}

// parseTime 解析时间字符串
func parseTime(timeStr string) (time.Time, error) {
	// 尝试多种格式
	formats := []string{
		time.RFC3339,
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
		"2006-01-02",
	}

	for _, format := range formats {
		if t, err := time.Parse(format, timeStr); err == nil {
			return t, nil
		}
	}

	return time.Time{}, &reflect.UnmarshalTypeError{
		Value: timeStr,
		Type:  reflect.TypeOf(time.Time{}),
	}
}
