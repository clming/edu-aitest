package config

import (
	"log"
	"os"
)

// 安全常量配置
const (
	BcryptCost    = 12  // BUG-002: 密码加密成本因子 (推荐最低 12)
	JWTIssuer     = "edu-assistant"  // BUG-004: JWT 签发者
	TokenExpireHours = 24 * 7  // BUG-014: Token 有效期 (7 天)
)

type Config struct {
	DatabaseURL string
	RedisURL    string
	JWTSecret   string
	Port        string
	Env         string
}

func Load() *Config {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("FATAL: JWT_SECRET environment variable is required in production. Please set it before starting the service.")
	}
	
	env := getEnv("ENV", "development")
	
	return &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgres://localhost:5432/edu_assistant?sslmode=disable"),
		RedisURL:    getEnv("REDIS_URL", "redis://localhost:6379"),
		JWTSecret:   jwtSecret,  // BUG-001: 不允许默认值
		Port:        getEnv("PORT", "8080"),
		Env:         env,
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
