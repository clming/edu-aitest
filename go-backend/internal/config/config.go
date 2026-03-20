package config

import (
	"fmt"
	"log"
	"os"
)

// 安全常量配置
const (
	BcryptCost    = 12  // BUG-002: 密码加密成本因子 (推荐最低 12)
	JWTIssuer     = "edu-assistant"  // BUG-004: JWT 签发者
	TokenExpireHours = 24 * 7  // BUG-014: Token 有效期 (7 天)
)

// 数据库配置常量
const (
	DBHost     = "mysql-2a840bd18e4b-public.rds.volces.com"
	DBPort     = "33060"
	DBName     = "edu_assistant"
	DBUser     = "openclaw-edutest"
	DBPassword = "EZi3fxB9Kpqyap%Dm"
)

type Config struct {
	DatabaseURL string
	DatabaseConfig DatabaseConfig
	RedisURL    string
	JWTSecret   string
	Port        string
	Env         string
}

// DatabaseConfig 数据库详细配置
type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
}

func Load() *Config {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("FATAL: JWT_SECRET environment variable is required in production. Please set it before starting the service.")
	}
	
	env := getEnv("ENV", "development")
	
	// 构建 MySQL 连接字符串
	// 格式：user:password@tcp(host:port)/dbname?charset=utf8mb4&parseTime=True&loc=Local
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local&interpolateParams=true",
		DBUser,
		DBPassword,
		DBHost,
		DBPort,
		DBName,
	)
	
	dbConfig := DatabaseConfig{
		Host:     DBHost,
		Port:     DBPort,
		User:     DBUser,
		Password: DBPassword,
		DBName:   DBName,
	}
	
	return &Config{
		DatabaseURL: dsn,
		DatabaseConfig: dbConfig,
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
