package middleware_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/clming/edu-aitest/go-backend/internal/database"
)

// TestCacheWithTTL 测试缓存过期时间 (BUG-010)
func TestCacheWithTTL(t *testing.T) {
	ctx := context.Background()
	
	// 测试设置缓存必须带过期时间
	err := database.CacheSet(ctx, "test_key", "test_value", 0)
	assert.Error(t, err, "缓存过期时间必须大于 0")
	
	// 测试正常设置缓存
	err = database.CacheSet(ctx, "test_key", "test_value", database.DefaultCacheTTL)
	assert.NoError(t, err)
	
	// 测试获取缓存
	var result string
	err = database.CacheGet(ctx, "test_key", &result)
	assert.NoError(t, err)
	assert.Equal(t, "test_value", result)
	
	// 清理
	database.CacheDelete(ctx, "test_key")
}

// TestCacheTTLConstants 测试缓存时间常量 (BUG-010, BUG-014)
func TestCacheTTLConstants(t *testing.T) {
	assert.Greater(t, database.DefaultCacheTTL, time.Duration(0), "默认缓存时间应大于 0")
	assert.Greater(t, database.ShortCacheTTL, time.Duration(0), "短期缓存时间应大于 0")
	assert.Greater(t, database.LongCacheTTL, time.Duration(0), "长期缓存时间应大于 0")
	assert.Greater(t, database.SessionCacheTTL, time.Duration(0), "会话缓存时间应大于 0")
}

// TestLoginAttemptKey 测试登录尝试键生成
func TestLoginAttemptKey(t *testing.T) {
	key := database.LoginAttemptKey("testuser")
	assert.Equal(t, "login_attempt:testuser", key)
}
