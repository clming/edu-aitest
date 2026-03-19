package config

import (
	"os"
)

type Config struct {
	DatabaseURL string
	RedisURL    string
	JWTSecret   string
	Port        string
	Env         string
}

func Load() *Config {
	return &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgres://localhost:5432/edu_assistant?sslmode=disable"),
		RedisURL:    getEnv("REDIS_URL", "redis://localhost:6379"),
		JWTSecret:   getEnv("JWT_SECRET", "edu-assistant-secret-key-2026"),
		Port:        getEnv("PORT", "8080"),
		Env:         getEnv("ENV", "development"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
