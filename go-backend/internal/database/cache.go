package database

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// BUG-010: 缓存工具函数，确保所有缓存都设置过期时间

const (
	// 默认缓存过期时间
	DefaultCacheTTL = 5 * time.Minute
	
	// 短期缓存 (1 分钟)
	ShortCacheTTL = 1 * time.Minute
	
	// 长期缓存 (1 小时)
	LongCacheTTL = 1 * time.Hour
	
	// 会话缓存 (24 小时)
	SessionCacheTTL = 24 * time.Hour
)

// CacheSet 设置缓存 (带过期时间)
// BUG-010: 强制要求设置过期时间
func CacheSet(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	if Redis == nil {
		return fmt.Errorf("Redis 未初始化")
	}
	
	if ttl <= 0 {
		return fmt.Errorf("缓存过期时间必须大于 0")
	}
	
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	
	return Redis.Set(ctx, key, data, ttl).Err()
}

// CacheGet 获取缓存
func CacheGet(ctx context.Context, key string, dest interface{}) error {
	if Redis == nil {
		return fmt.Errorf("Redis 未初始化")
	}
	
	data, err := Redis.Get(ctx, key).Bytes()
	if err != nil {
		if err == redis.Nil {
			return nil // 缓存不存在
		}
		return err
	}
	
	return json.Unmarshal(data, dest)
}

// CacheDelete 删除缓存
func CacheDelete(ctx context.Context, key string) error {
	if Redis == nil {
		return fmt.Errorf("Redis 未初始化")
	}
	
	return Redis.Del(ctx, key).Err()
}

// CacheExists 检查缓存是否存在
func CacheExists(ctx context.Context, key string) (bool, error) {
	if Redis == nil {
		return false, fmt.Errorf("Redis 未初始化")
	}
	
	result, err := Redis.Exists(ctx, key).Result()
	if err != nil {
		return false, err
	}
	
	return result > 0, nil
}

// LoginAttemptKey 生成登录尝试缓存键
func LoginAttemptKey(username string) string {
	return fmt.Sprintf("login_attempt:%s", username)
}

// CacheIncrement 增加计数器 (用于登录失败次数)
func CacheIncrement(ctx context.Context, key string, ttl time.Duration) (int64, error) {
	if Redis == nil {
		return 0, fmt.Errorf("Redis 未初始化")
	}
	
	val, err := Redis.Incr(ctx, key).Result()
	if err != nil {
		return 0, err
	}
	
	// 如果是第一次增加，设置过期时间
	if val == 1 {
		Redis.Expire(ctx, key, ttl)
	}
	
	return val, nil
}
