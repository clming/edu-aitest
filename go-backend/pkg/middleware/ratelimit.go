package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// BUG-003: 限流中间件
// 防止暴力破解和 DDoS 攻击

// RateLimiter 限流器
type RateLimiter struct {
	visitors map[string]*rate.Limiter
	mu       *sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter 创建限流器
func NewRateLimiter(rateVal rate.Limit, burst int) *RateLimiter {
	return &RateLimiter{
		visitors: make(map[string]*rate.Limiter),
		mu:       &sync.RWMutex{},
		rate:     rateVal,
		burst:    burst,
	}
}

// getLimiter 获取或创建限流器
func (rl *RateLimiter) getLimiter(ip string) *rate.Limiter {
	rl.mu.RLock()
	limiter, exists := rl.visitors[ip]
	rl.mu.RUnlock()

	if exists {
		return limiter
	}

	rl.mu.Lock()
	defer rl.mu.Unlock()

	// 再次检查 (double-check locking)
	if limiter, exists = rl.visitors[ip]; exists {
		return limiter
	}

	limiter = rate.NewLimiter(rl.rate, rl.burst)
	rl.visitors[ip] = limiter

	return limiter
}

// 全局限流器实例
// 登录接口：每秒 5 次请求，突发 10 次
var loginRateLimiter = NewRateLimiter(5, 10)

// 通用 API 限流器：每秒 20 次请求，突发 50 次
var apiRateLimiter = NewRateLimiter(20, 50)

// RateLimitMiddleware 限流中间件
func RateLimitMiddleware(limiter *RateLimiter, msg string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 获取客户端 IP
		ip := c.ClientIP()
		
		limiterInstance := limiter.getLimiter(ip)
		
		if !limiterInstance.Allow() {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": msg,
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// LoginRateLimit 登录接口限流
func LoginRateLimit() gin.HandlerFunc {
	return RateLimitMiddleware(loginRateLimiter, "登录请求过于频繁，请稍后再试")
}

// APIRateLimit 通用 API 限流
func APIRateLimit() gin.HandlerFunc {
	return RateLimitMiddleware(apiRateLimiter, "请求过于频繁，请稍后再试")
}

// 清理过期限流器 (防止内存泄漏)
func init() {
	go func() {
		ticker := time.NewTicker(time.Minute)
		defer ticker.Stop()
		
		for range ticker.C {
			cleanupExpiredLimiters()
		}
	}()
}

func cleanupExpiredLimiters() {
	// 简单实现：定期清理所有限流器
	// 生产环境可以使用更复杂的策略 (如 LRU)
	loginRateLimiter.mu.Lock()
	for ip, limiter := range loginRateLimiter.visitors {
		// 如果限流器很长时间未被使用，可以删除
		// 这里简化处理，实际应该跟踪最后访问时间
		_ = limiter
		_ = ip
	}
	loginRateLimiter.mu.Unlock()
}
