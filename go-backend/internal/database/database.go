package database

import (
	"fmt"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"github.com/redis/go-redis/v9"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

var (
	DB    *gorm.DB
	Redis *redis.Client
)

// Init 初始化数据库连接
func Init(dsn string) error {
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("数据库连接失败：%w", err)
	}

	// 自动迁移
	if err := DB.AutoMigrate(
		&models.User{},
		&models.Homework{},
		&models.Student{},
		&models.Report{},
	); err != nil {
		return fmt.Errorf("数据库迁移失败：%w", err)
	}

	log.Println("✅ 数据库初始化成功")
	return nil
}

// InitRedis 初始化 Redis 连接
func InitRedis(redisURL string) error {
	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		return fmt.Errorf("Redis URL 解析失败：%w", err)
	}

	Redis = redis.NewClient(opt)

	// 测试连接
	if err := Redis.Ping(nil).Err(); err != nil {
		return fmt.Errorf("Redis 连接失败：%w", err)
	}

	log.Println("✅ Redis 初始化成功")
	return nil
}

// Close 关闭数据库连接
func Close() error {
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}
	
	if err := sqlDB.Close(); err != nil {
		return err
	}

	if Redis != nil {
		if err := Redis.Close(); err != nil {
			return err
		}
	}

	log.Println("✅ 数据库连接已关闭")
	return nil
}
